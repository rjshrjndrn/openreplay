import { useModal } from 'Components/Modal';
import CreateNote from 'Components/Session_/Player/Controls/components/CreateNote';
import React from 'react';
import { Icon } from 'UI';
import { tagProps, Note } from 'App/services/NotesService';
import { formatTimeOrDate } from 'App/date';
import { useStore } from 'App/mstore';
import { observer } from 'mobx-react-lite';
import { ItemMenu } from 'UI';
import copy from 'copy-to-clipboard';
import { toast } from 'react-toastify';
import { session } from 'App/routes';
import { confirm } from 'UI';
import { TeamBadge } from 'Shared/SessionsTabOverview/components/Notes';
import { Tag } from 'antd'

interface Props {
  note: Note;
  noEdit: boolean;
  filterOutNote: (id: number) => void;
}

function NoteEvent(props: Props) {
  const { settingsStore, notesStore } = useStore();
  const { timezone } = settingsStore.sessionSettings;
  const { showModal, hideModal } = useModal();

  const onEdit = () => {
    showModal(
      <CreateNote
        hideModal={hideModal}
        isEdit
        time={props.note.timestamp}
        editNote={{
          timestamp: props.note.timestamp,
          tag: props.note.tag,
          isPublic: props.note.isPublic,
          message: props.note.message,
          noteId: props.note.noteId.toString(),
        }}
      />,
      { right: true, width: 380 }
    );
  };

  const onCopy = () => {
    copy(
      `${window.location.origin}/${window.location.pathname.split('/')[1]}${session(
        props.note.sessionId
      )}${
        props.note.timestamp > 0
          ? `?jumpto=${props.note.timestamp}&note=${props.note.noteId}`
          : `?note=${props.note.noteId}`
      }`
    );
    toast.success('Note URL copied to clipboard');
  };

  const onDelete = async () => {
    if (
      await confirm({
        header: 'Confirm',
        confirmButton: 'Yes, delete',
        confirmation: `Are you sure you want to delete this note?`,
      })
    ) {
      notesStore.deleteNote(props.note.noteId).then((r) => {
        props.filterOutNote(props.note.noteId);
        toast.success('Note deleted');
      });
    }
  };
  const menuItems = [
    { icon: 'pencil', text: 'Edit', onClick: onEdit, disabled: props.noEdit },
    { icon: 'link-45deg', text: 'Copy URL', onClick: onCopy },
    { icon: 'trash', text: 'Delete', onClick: onDelete },
  ];
  return (
    <div className="flex items-start flex-col p-2 border rounded ps-4" style={{ background: '#FFFEF5' }}>
      <div className="flex items-center w-full relative">
        <div className="p-3 bg-gray-light rounded-full">
          <Icon name="quotes" color="main" />
        </div>
        <div className="ml-2">
          <div
            className="text-base"
            style={{
              maxWidth: 150,
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
            }}
          >
            {props.note.userName}
          </div>
          <div className="text-disabled-text text-xs">
            {formatTimeOrDate(props.note.createdAt as unknown as number, timezone)}
          </div>
        </div>
        <div className="cursor-pointer absolute" style={{ right: -5 }}>
          <ItemMenu bold items={menuItems} />
        </div>
      </div>
      <div
        className="text-base capitalize-first my-3 overflow-y-scroll overflow-x-hidden"
        style={{ maxHeight: 200, maxWidth: 220 }}
      >
        {props.note.message}
      </div>
      <div>
        <div className="flex items-center flex-wrap w-full">
          {props.note.tag ? (
            <Tag color={tagProps[props.note.tag]} bordered={false} className='rounded-lg'>
              {props.note.tag}
            </Tag>
          ) : null}
          {!props.note.isPublic ? null : <TeamBadge />}
        </div>
      </div>
    </div>
  );
}

export default observer(NoteEvent);
