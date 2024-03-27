% draw raster plot of response timecourses for all trials of a single electrode
%%% ecog data must be loaded from LocalEpoched first
% behavioral data will take a minute to load the first time this is run
%
% updated 2021/7/11 by Andrew Meier
%%
close all;

sub_str_all = {'S357'; 'S362'; 'S369'; 'S372'; 'S376'};
data_type = {'stimuli_12'};
base_data_path = '/projectnb/busplab/Experiments/ECoG_Preprocessed_RD/LocalEpoched/';
load('/projectnb/busplab/Experiments/ECoG_Preprocessed_RD/filelist.mat', 'filelist');

addpath('/project/busplab/software/ecog/classification_RD');
addpath('/project/busplab/software/ecog/repsup_AM')
addpath('/project/busplab/software/ecog/util/')


%% params
for i_sub = 1:length(sub_str_all)
    load(fullfile('/projectnb/busplab/Experiments/ECoG_Preprocessed_RD/LocalEpoched/', sub_str_all{i_sub}, '/Epoch_stimuli_12_Hilbert_HG.mat'))
    data = preprocessed_data.data;
    s = SubjectClass(sub_str_all{i_sub}, data_type, data, filelist);
    
    %% load stimdata
    vardefault('align_con_old', []); % align condition of the stim data already loaded; if none yet loaded, this will be empty
    [flist_out, align_out] = stimload(event_info.condition, align_con_old); % load stimdata for these responses if not already loaded
    align_con_old = align_out; 
    if ~isempty(flist_out) % if new stimdata was just loaded
        filelist = flist_out;
    end
    
    %% Plot twice, active first then inactive
    for i_ae = 1:2
        if i_ae == 2
            s.AE = ~s.AE;
        end

        electrode_ind = find(s.AE);

        %% organize data
        dat = squeeze(mean(preprocessed_data.data(electrode_ind,:,:),1, 'omitnan'));
        maxval = max(dat(:)); % for scaling
        minval = min(dat(:)); % for scaling

        % identify subject from number of trials
        ntrials_list = cellfun(@height,filelist.trials);
        subind = ntrials_list == size(dat,2); 
        assert(nnz(subind==1), 'Could not identify subject from number of trials');
        subname = filelist.subject(subind);
        trials = filelist.trials{subind};
        trials.dat = dat'; clear dat; % assign ecog responses to behavioral data
        repcons = unique(trials.pair_comparison); % list of repetition conditions
        ncons = length(repcons); 

        % remove trials marked as NaN
        nantrials = any(isnan(trials.dat),2);
        trials = trials(~nantrials,:);
        trials1 = trials(1:2:end,:); % word 1
        trials2 = trials(2:2:end,:); % word 2

        %% plotting
        % Plot all combined
        plot_raster(trials1.dat, trials2.dat, 'All Conditions', minval, maxval, mod(i_ae,2), 4*i_sub - 3);

        % Plot separate conditions
        for icon = 1:ncons
            thiscon = repcons{icon};
            rowmatch = strcmp(trials1.pair_comparison, thiscon); % rows with this rep condition
            data1 = trials1.dat(rowmatch,:);
            data2 = trials2.dat(rowmatch,:);
            plot_raster(data1, data2, thiscon, minval, maxval, mod(i_ae,2), 4*i_sub - 3 + icon);
        end

    end
end


%% subfunction for plotting
function plot_raster(data1, data2, thiscon, minval, maxval, ae, fighandle)    
    line_xloc_stim = 1000; 
    line_xloc_voice = 2000; 

    line_color_1sec = [0 1 0]; 
    line_color_2sec = [0 0 1]; 
    line_width = 1;
    line_style = '--'; % dashed line
    cmapname = 'pink'; % colormap
    
    if ae
        figure;
    else
        figure(fighandle)
    end
    
    subplot(2,2,2 - ae)
    imagesc(data1);
    caxis([minval, maxval]); % use same color scale for all plots
    cbar = colorbar; 
    if ae
        title({'word 1',thiscon, 'Active'})
    else
        title({'word 1',thiscon, 'Non-Active'})
    end
    xlabel('Time (ms)')
    ylabel('Trial Index')
    
    hline_stim = line([line_xloc_stim, line_xloc_stim], ylim,'Color',line_color_1sec,'LineWidth',line_width,'LineStyle',line_style);    
    hline_stim = line([line_xloc_voice, line_xloc_voice], ylim,'Color',line_color_2sec,'LineWidth',line_width,'LineStyle',line_style);
    
    
    subplot(2,2,4-ae)
    imagesc(data2);
    caxis([minval, maxval]); % use same color scale for all plots
    cbar = colorbar; 
    if ae
        title({'word 2',thiscon, newline, 'Active'})
    else
        title({'word 2',thiscon, newline, 'Non-Active'})
    end
    xlabel('Time (ms)')
    ylabel('Trial Index')

    hline_stim = line([line_xloc_stim, line_xloc_stim], ylim,'Color',line_color_1sec,'LineWidth',line_width,'LineStyle',line_style);
    hline_stim = line([line_xloc_voice, line_xloc_voice], ylim,'Color',line_color_2sec,'LineWidth',line_width,'LineStyle',line_style);
  
    colormap(cmapname)
end



%% subfunction for loading behavioral data
function  [flist_out, align_out] = stimload(align_con_current, align_con_previous)
    ntrials_per_trial_pair = 2; 
    get_useable_trials_from_LocalEpoched = 1; 
    if contains(align_con_current,'stimuli')
        align_con_current = 'stimuli';
    elseif contains(align_con_current,'onset')
        align_con_current = 'onset';
    end
    align_out = align_con_current;
    
    % if some stimdata were already loaded and they are same align condition as current condition, keep old stimdata
    if ~isempty(align_con_previous) && strcmp(align_con_current, align_con_previous)  % if ok to use old data
            flist_out = [];
    else % data either not loaded or not same align condition.... load data
        align_con = align_con_current;
        match_trial_2_behavior(); % load stimdata based on most recent epoched ecog data; may take a little while
        flist_out = filelist; 
    end
end