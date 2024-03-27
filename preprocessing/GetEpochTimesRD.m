function [events, sess_event_info, ids, bl_events, bl_sess_event_info] = GetEpochTimesRD(onsetTable, condition, baseline_from_1)

bl_events = [];
bl_sess_event_info = [];

switch condition
    case 'stimuli_1'
        events = onsetTable(:, 1);
    case 'stimuli_2'
        events = onsetTable(:, 2);
        sess_event_info = onsetTable - repmat(events, [1, size(onsetTable,2)]);
        if baseline_from_1
            bl_events = onsetTable(:, 1);
        else
            bl_events = onsetTable(:,2);
        end
    case 'onset_1'
        events = onsetTable(:, 3);
    case 'onset_2'
        events = onsetTable(:, 4);
        if baseline_from_1
            bl_events = onsetTable(:, 3);
        else
            bl_events = onsetTable(:,3);
        end
    case 'stimuli_12'
        events = onsetTable(:, [1 2])';
        [events, ids] = remove_nan_pair(events);
        events = events(:);
        if baseline_from_1
            bl_events = [onsetTable(:,1), onsetTable(:,1)];
        else
            bl_events = [onsetTable(:,1), onsetTable(:,2)];
        end
        bl_events = bl_events(ids,:)';
        bl_events = bl_events(:);

    case 'onset_12'
        events = onsetTable(:, [3 4])';
        [events, ids] = remove_nan_pair(events);
        events = events(:);
        if baseline_from_1
            bl_events = [onsetTable(:,3), onsetTable(:,3)];
        else
            bl_events = [onsetTable(:,3), onsetTable(:,4)];
        end
        bl_events = bl_events(ids,:)';
        bl_events = bl_events(:);
        
    otherwise
        error('Condition %s not supported', condition);
end

switch condition
    case {'stimuli_1', 'stimuli_2', 'onset_1', 'onset_2'}
        sess_event_info = onsetTable - repmat(events, [1, size(onsetTable,2)]);
        if baseline_from_1
            bl_sess_event_info = onsetTable - repmat(events, [1, size(onsetTable,2)]);
        end
    case 'stimuli_12'
        sess_event_info = nan(2*size(onsetTable, 1), size(onsetTable,2));
        sess_event_info(1:2:end, :) = onsetTable - repmat(onsetTable(:,1), [1, size(onsetTable,2)]);
        sess_event_info(2:2:end, :) = onsetTable - repmat(onsetTable(:,2), [1, size(onsetTable,2)]);
        if baseline_from_1
            bl_sess_event_info = onsetTable - repmat(onsetTable(:,1), [1, size(onsetTable,2)]);
        end
    case 'onset_12'
        sess_event_info = nan(2*size(onsetTable, 1), size(onsetTable,2));
        sess_event_info(1:2:end, :) = onsetTable - repmat(onsetTable(:,3), [1, size(onsetTable,2)]);
        sess_event_info(2:2:end, :) = onsetTable - repmat(onsetTable(:,4), [1, size(onsetTable,2)]);
        if baseline_from_1
            bl_sess_event_info = onsetTable - repmat(onsetTable(:,3), [1, size(onsetTable,2)]);
        end
    otherwise
        error('Condition %s not supported', condition);
end


% Remove nans
events = events(~isnan(events));
% if baseline_from_1
    bl_events = bl_events(~isnan(bl_events));
% end

end

function [events, ids] = remove_nan_pair(events)
    ids = 1:max(size(events));
    ids(any(isnan(events))) = [];
    events(:,any(isnan(events))) = [];    
end