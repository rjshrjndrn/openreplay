import schemas
from chalicelib.core import events, metadata, events_mobile, \
    issues, assist, canvas, user_testing
from . import sessions_mobs, sessions_devtool
from chalicelib.core.errors.modules import errors_helper
from chalicelib.utils import pg_client, helper
from chalicelib.core.modules import MOB_KEY, get_file_key


def __is_mobile_session(platform):
    return platform in ('ios', 'android')


def __group_metadata(session, project_metadata):
    meta = {}
    for m in project_metadata.keys():
        if project_metadata[m] is not None and session.get(m) is not None:
            meta[project_metadata[m]] = session[m]
        session.pop(m)
    return meta


def get_pre_replay(project_id, session_id):
    return {
        **get_file_key(project_id=project_id, session_id=session_id),
        'domURL': [sessions_mobs.get_first_url(project_id=project_id, session_id=session_id, check_existence=False)]}


def get_replay(project_id, session_id, context: schemas.CurrentContext, full_data=False, include_fav_viewed=False,
               group_metadata=False, live=True):
    with pg_client.PostgresClient() as cur:
        extra_query = []
        if include_fav_viewed:
            extra_query.append("""COALESCE((SELECT TRUE
                                 FROM public.user_favorite_sessions AS fs
                                 WHERE s.session_id = fs.session_id
                                   AND fs.user_id = %(userId)s), FALSE) AS favorite""")
            extra_query.append("""COALESCE((SELECT TRUE
                                 FROM public.user_viewed_sessions AS fs
                                 WHERE s.session_id = fs.session_id
                                   AND fs.user_id = %(userId)s), FALSE) AS viewed""")
        query = cur.mogrify(
            f"""\
            SELECT
                s.*,
                s.session_id::text AS session_id,
                {MOB_KEY}
                (SELECT project_key FROM public.projects WHERE project_id = %(project_id)s LIMIT 1) AS project_key
                {"," if len(extra_query) > 0 else ""}{",".join(extra_query)}
                {(",json_build_object(" + ",".join([f"'{m}',p.{m}" for m in metadata.column_names()]) + ") AS project_metadata") if group_metadata else ''}
            FROM public.sessions AS s {"INNER JOIN public.projects AS p USING (project_id)" if group_metadata else ""}
            WHERE s.project_id = %(project_id)s
                AND s.session_id = %(session_id)s;""",
            {"project_id": project_id, "session_id": session_id, "userId": context.user_id}
        )
        cur.execute(query=query)

        data = cur.fetchone()
        if data is not None:
            data = helper.dict_to_camel_case(data)
            if full_data:
                if __is_mobile_session(data["platform"]):
                    data['mobsUrl'] = []
                    data['videoURL'] = sessions_mobs.get_mobile_videos(session_id=session_id, project_id=project_id,
                                                                       check_existence=False)
                else:
                    data['mobsUrl'] = sessions_mobs.get_urls_depercated(session_id=session_id, check_existence=False)
                    data['devtoolsURL'] = sessions_devtool.get_urls(session_id=session_id, project_id=project_id,
                                                                    context=context, check_existence=False)
                    data['canvasURL'] = canvas.get_canvas_presigned_urls(session_id=session_id, project_id=project_id)
                    if user_testing.has_test_signals(session_id=session_id, project_id=project_id):
                        data['utxVideo'] = user_testing.get_ux_webcam_signed_url(session_id=session_id,
                                                                                 project_id=project_id,
                                                                                 check_existence=False)
                    else:
                        data['utxVideo'] = []

                data['domURL'] = sessions_mobs.get_urls(session_id=session_id, project_id=project_id,
                                                        check_existence=False)
                data['metadata'] = __group_metadata(project_metadata=data.pop("projectMetadata"), session=data)
                data['live'] = live and assist.is_live(project_id=project_id, session_id=session_id,
                                                       project_key=data["projectKey"])
            data["inDB"] = True
            return data
        elif live:
            return assist.get_live_session_by_id(project_id=project_id, session_id=session_id)
        else:
            return None


def get_events(project_id, session_id):
    with pg_client.PostgresClient() as cur:
        query = cur.mogrify(
            f"""SELECT session_id, platform, start_ts, duration
                FROM public.sessions AS s
                WHERE s.project_id = %(project_id)s
                    AND s.session_id = %(session_id)s;""",
            {"project_id": project_id, "session_id": session_id}
        )
        cur.execute(query=query)

        s_data = cur.fetchone()
        if s_data is not None:
            s_data = helper.dict_to_camel_case(s_data)
            data = {}
            if __is_mobile_session(s_data["platform"]):
                data['events'] = events_mobile.get_by_sessionId(project_id=project_id, session_id=session_id)
                for e in data['events']:
                    if e["type"].endswith("_IOS"):
                        e["type"] = e["type"][:-len("_IOS")]
                    elif e["type"].endswith("_MOBILE"):
                        e["type"] = e["type"][:-len("_MOBILE")]
                data['crashes'] = events_mobile.get_crashes_by_session_id(session_id=session_id)
                data['userEvents'] = events_mobile.get_customs_by_session_id(project_id=project_id,
                                                                             session_id=session_id)
                data['userTesting'] = []
            else:
                data['events'] = events.get_by_session_id(project_id=project_id, session_id=session_id,
                                                          group_clickrage=True)
                all_errors = events.get_errors_by_session_id(session_id=session_id, project_id=project_id)
                data['stackEvents'] = [e for e in all_errors if e['source'] != "js_exception"]
                # to keep only the first stack
                # limit the number of errors to reduce the response-body size
                data['errors'] = [errors_helper.format_first_stack_frame(e) for e in all_errors
                                  if e['source'] == "js_exception"][:500]
                data['userEvents'] = events.get_customs_by_session_id(project_id=project_id,
                                                                      session_id=session_id)
                data['userTesting'] = user_testing.get_test_signals(session_id=session_id, project_id=project_id)

            data['issues'] = issues.get_by_session_id(session_id=session_id, project_id=project_id)
            data['issues'] = reduce_issues(data['issues'])
            return data
        else:
            return None


# To reduce the number of issues in the replay;
# will be removed once we agree on how to show issues
def reduce_issues(issues_list):
    if issues_list is None:
        return None
    i = 0
    # remove same-type issues if the time between them is <2s
    while i < len(issues_list) - 1:
        for j in range(i + 1, len(issues_list)):
            if issues_list[i]["type"] == issues_list[j]["type"]:
                break
        else:
            i += 1
            break

        if issues_list[i]["timestamp"] - issues_list[j]["timestamp"] < 2000:
            issues_list.pop(j)
        else:
            i += 1

    return issues_list
