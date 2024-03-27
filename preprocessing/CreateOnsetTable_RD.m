clear all; clc

all_sub_str = {'S357', 'S362_sess01_', 'S369', 'S372', 'S376'}; 
% all_sub_str = {'S357', 'S362_sess01_', 'S362_sess02_', 'S369', 'S372'};
sess_str = ''; % {'', '2'}
add_str = '';

% trig_Fs = 24400; % trigger sampled at 24kHz
for i = 1:length(all_sub_str)
    sub_str = all_sub_str{i};
    switch sub_str
        case 'S352'
            trig_Fs = 24000;
        case 'S357'
            trig_Fs = 24000;
        case 'S362'
            trig_Fs = 24000;
        case 'S369'
            trig_Fs = 16000;
        case 'S372'
            trig_Fs = 16000;
        case 'S376'
            trig_Fs = 16000;
    end

    % base_path = error('Enter data directory path here');
    base_path = '/projectnb/busplab/Experiments/ECoG_Preprocessed';

    try
        load(fullfile(base_path, 'ProcessedDataset', [sub_str add_str 'OnsetTime.mat']));
    catch
        load(fullfile(base_path, 'LocalProcessed', sub_str, [sub_str add_str 'OnsetTime.mat']));
    end

    OnsetTable = cell(0);
    for ii=1:length(stimuliOnset)

        stimuli_t = stimuliOnset(ii).VisualOnset;
        onset_t = stimuliOnset(ii).SpeechOnset;

        % Convert to ms (speech and trigger sampled at 24.4kHz)
        stimuli_t = round(1000 * stimuli_t/trig_Fs);
        onset_t = round(1000 * onset_t/trig_Fs);

        % Line up speech with triggers/stimuli
        matched_onset_t = nan(size(stimuli_t));
        for k=1:length(stimuli_t)
            if k ~= length(stimuli_t)
            match_ind = find(onset_t > stimuli_t(k) & onset_t < stimuli_t(k+1));
            else
                avg_interval = mean(stimuli_t(end:-1:2) - stimuli_t(end-1:-1:1));
                match_ind = find(onset_t > stimuli_t(k) & onset_t < stimuli_t(k) + avg_interval);
            end
            if isempty(match_ind) || length(match_ind) > 1
                matched_onset_t(k) = nan;
            else
                matched_onset_t(k) = onset_t(match_ind);
            end
        end

        onset_table = [stimuli_t(1:2:end)' stimuli_t(2:2:end)' ...
            matched_onset_t(1:2:end)' matched_onset_t(2:2:end)'];

        bad_trial_1 = find(isnan(onset_table(:,3)));
        bad_trial_2 = find(isnan(onset_table(:,4)));

        % First speech is bad, entire trial bad
        onset_table(bad_trial_1, 1) = nan;
        onset_table(bad_trial_1, 2) = nan;
        % Second speech is bad, keep first part (no repetition though)
        onset_table(bad_trial_2, 2) = nan;

        OnsetTable{ii} = onset_table;
    end

    save_path = fullfile([base_path '_RD'], 'LocalProcessed', sub_str);
    if ~exist(save_path,'dir')
        mkdir(save_path)
    end
    save_file = fullfile(save_path, ['LocalOnsetTable' sess_str '.mat']);
    save(save_file, 'OnsetTable');
end

disp('Finished')
