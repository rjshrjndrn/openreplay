import React, { useEffect, useState } from 'react';
import { Loader, Icon } from 'UI';
import { connect } from 'react-redux';
import { fetchSessionClickmap } from 'Duck/sessions';
import SelectorsList from './components/SelectorsList/SelectorsList';
import { PlayerContext } from 'App/components/Session/playerContext';
import { compareJsonObjects } from 'App/utils';

import Select from 'Shared/Select';
import SelectDateRange from 'Shared/SelectDateRange';
import Period from 'Types/app/period';

const JUMP_OFFSET = 1000;
interface Props {
    filters: any;
    fetchSessionClickmap: (sessionId: string, filters: Record<string, any>) => void;
    insights: any;
    events: Array<any>;
    urlOptions: Array<any>;
    loading: boolean;
    host: string;
    setActiveTab: (tab: string) => void;
    sessionId: string;
}

function PageInsightsPanel({ filters, fetchSessionClickmap, events = [], insights, urlOptions, host, loading = true, setActiveTab, sessionId }: Props) {
    const { player: Player } = React.useContext(PlayerContext)
    const markTargets = (t: any) => Player.markTargets(t)
    const defaultValue = urlOptions && urlOptions[0] ? urlOptions[0].value : '';
    const [insightsFilters, setInsightsFilters] = useState({ ...filters, url: host + defaultValue });
    const prevInsights = React.useRef<any>();

    const period = Period({
        start: insightsFilters.startDate,
        end: insightsFilters.endDate,
        rangeName: insightsFilters.rangeValue,
    });

    const onDateChange = (e: any) => {
        const { startDate, endDate, rangeValue } = e.toJSON();
        setInsightsFilters({ ...insightsFilters, startDate, endDate, rangeValue });
    };

    useEffect(() => {
        markTargets(insights.toJS());
        return () => {
            markTargets(null);
        };
    }, [insights]);

    useEffect(() => {
        const changed = !compareJsonObjects(prevInsights.current, insightsFilters);
        if (!changed) { return }

        if (urlOptions && urlOptions[0]) {
            const url = insightsFilters.url ? insightsFilters.url : host + urlOptions[0].value;
            Player.pause();
            fetchSessionClickmap(sessionId, { ...insightsFilters, sessionId, url });
            markTargets([]);
        }
        prevInsights.current = insightsFilters;
    }, [insightsFilters]);

    const onPageSelect = ({ value }: any) => {
        const event = events.find((item) => item.url === value.value);
        Player.jump(event.time + JUMP_OFFSET);
        setInsightsFilters({ ...insightsFilters, url: host + value.value });
    };

    return (
        <div className="p-4 bg-white">
            <div className="pb-3 flex items-center" style={{ maxWidth: '241px', paddingTop: '5px' }}>
                <div className="flex items-center">
                    <span className="mr-1 text-xl">Clicks</span>
                </div>
                <div
                    onClick={() => {
                        setActiveTab('');
                    }}
                    className="ml-auto flex items-center justify-center bg-white cursor-pointer"
                >
                    <Icon name="close" size="18" />
                </div>
            </div>
            <div className="mb-4 flex items-center">
                <div className="mr-2 flex-shrink-0">In Page</div>
                <Select
                    isSearchable={true}
                    right
                    placeholder="change"
                    options={urlOptions}
                    name="url"
                    defaultValue={defaultValue}
                    onChange={onPageSelect}
                    id="change-dropdown"
                    className="w-full"
                    style={{ width: '100%' }}
                />
            </div>
            <Loader loading={loading}>
                <SelectorsList />
            </Loader>
        </div>
    );
}

export default connect(
    (state: any) => {
        const events = state.getIn(['sessions', 'visitedEvents']);
        return {
            filters: state.getIn(['sessions', 'insightFilters']),
            host: state.getIn(['sessions', 'host']),
            insights: state.getIn(['sessions', 'insights']),
            events: events,
            urlOptions: events.map(({ url, host }: any) => ({ label: url, value: url, host })),
            loading: state.getIn(['sessions', 'fetchInsightsRequest', 'loading']),
            sessionId: state.getIn(['sessions', 'current']).sessionId,
        };
    },
    { fetchSessionClickmap }
)(PageInsightsPanel);
