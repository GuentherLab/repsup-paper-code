% draw raster plot of response timecourses for all trials of a single electrode
%%% ecog data must be loaded from LocalEpoched first
% behavioral data will take a minute to load the first time this is run
%
% updated 2021/7/11 by Andrew Meier

%% params
electrode_ind = 160; 

plot_conditions_separately = 1; % separate out the rasters for each of the repetition conditions vs. combine conditions

show_1sec_line = 1; % show line at 1 second 
show_2sec_line = 1; % show line at 2 seconds 

line_color_1sec = [0 1 0]; 
line_color_2sec = [0 0 1]; 
line_width = 1;
line_style = '--'; % dashed line
cmapname = 'pink'; % colormap


%% load stimdata
vardefault('align_con_old', []); % align condition of the stim data already loaded; if none yet loaded, this will be empty
[flist_out, align_out] = stimload(event_info.condition, align_con_old); % load stimdata for these responses if not already loaded
align_con_old = align_out; 
if ~isempty(flist_out) % if new stimdata was just loaded
    filelist = flist_out;
end

%% organize data
line_xloc_stim = 1000; 
line_xloc_voice = 2000; 

dat = squeeze(preprocessed_data.data(elecotrode_ind,:,:));
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
if plot_conditions_separately
    for icon = 1:ncons
        thiscon = repcons{icon};
        rowmatch = strcmp(trials1.pair_comparison, thiscon); % rows with this rep condition
        
        % word 1
        subplot(ncons, 2, 2*icon - 1)
        imagesc(trials1.dat(rowmatch, :));
        caxis([minval, maxval]); % use same color scale for all plots
        cbar = colorbar; 
        if icon == 1; title({'word 1',thiscon}); else title(thiscon); end 
        if icon == ncons; xlabel('Time (ms)'); end
        ylabel('Trial Index')
        if show_1sec_line
            hline_stim = line([line_xloc_stim, line_xloc_stim], ylim,'Color',line_color_1sec,'LineWidth',line_width,'LineStyle',line_style);
        end
        if show_2sec_line
            hline_stim = line([line_xloc_voice, line_xloc_voice], ylim,'Color',line_color_2sec,'LineWidth',line_width,'LineStyle',line_style);
        end
        
        % word 2
        subplot(ncons, 2, 2*icon)
        imagesc(trials2.dat(rowmatch, :));
        caxis([minval, maxval]); % use same color scale for all plots
        cbar = colorbar; 
        if icon == 1; title({'word 1',thiscon}); else title(thiscon); end
        if icon == ncons; xlabel('Time (ms)'); end
        ylabel('Trial Index')
        if show_1sec_line
            hline_stim = line([line_xloc_stim, line_xloc_stim], ylim,'Color',line_color_1sec,'LineWidth',line_width,'LineStyle',line_style);
        end
        if show_2sec_line
            hline_stim = line([line_xloc_voice, line_xloc_voice], ylim,'Color',line_color_2sec,'LineWidth',line_width,'LineStyle',line_style);
        end
    end
elseif ~plot_conditions_separately
           % word 1
        subplot(2, 1, 1)
        imagesc(trials1.dat);
        caxis([minval, maxval]); % use same color scale for all plots
        cbar = colorbar; 
        title('word 1')
        xlabel('Time (ms)')
        ylabel('Trial Index')
        if show_1sec_line
            hline_stim = line([line_xloc_stim, line_xloc_stim], ylim,'Color',line_color_1sec,'LineWidth',line_width,'LineStyle',line_style);
        end
        if show_2sec_line
            hline_stim = line([line_xloc_voice, line_xloc_voice], ylim,'Color',line_color_2sec,'LineWidth',line_width,'LineStyle',line_style);
        end
        
        % word 2
        subplot(2, 1, 2)
        imagesc(trials2.dat);
        caxis([minval, maxval]); % use same color scale for all plots
        cbar = colorbar; 
        title('word 2')
        xlabel('Time (ms)')
        ylabel('Trial Index')
        if show_1sec_line
            hline_stim = line([line_xloc_stim, line_xloc_stim], ylim,'Color',line_color_1sec,'LineWidth',line_width,'LineStyle',line_style);
        end
        if show_2sec_line
            hline_stim = line([line_xloc_voice, line_xloc_voice], ylim,'Color',line_color_2sec,'LineWidth',line_width,'LineStyle',line_style);
        end
    end

colormap(cmapname)




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