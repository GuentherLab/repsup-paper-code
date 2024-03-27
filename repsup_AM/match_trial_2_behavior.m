 %%% determine which trials have analyzable ecog responses, then find the behavioral data for these trials
%
% called by stmf_classification
%
%% updated 2021/7/17 by Andrew Meier


filelist_xlsx = '/projectnb/busplab/Experiments/ECoG_Preprocessed_AM/filelist_for_classification.xlsx'; % list of relevant files for each subject
ecog_localprocessed_topdir = '/projectnb/busplab/Experiments/ECoG_Preprocessed/LocalProcessed'; % folder with ecog trial data folders for each sub
target_words_file = '/projectnb/busplab/Experiments/ECoG_fMRI_RS/RepSup_megan/Behavioral_Data/Target_Words.mat'; % list of target words to be pronounced
stim_index_key_filename = '/projectnb/busplab/Experiments/ECoG_Preprocessed_AM/stim_index_key.xlsx'; % numerical indices for stim features


nblocks = 4; % maximum number of block of experimental data per subject; must correspond to number of blocks in the xlsx filelist
vardefault('ntrials_per_trial_pair',2); % if only analyzing first trial of each pair, set  1; if using both, set to 2
    max_trials_per_block = 36 * ntrials_per_trial_pair; 
vardefault('get_useable_trials_from_LocalEpoched',1); % if true, get good trial inds from LocalEpoched data, rather than the excel filelist
    LocalEpoched_topdir = '/projectnb/busplab/Experiments/ECoG_Preprocessed_RD/LocalEpoched'; % get good trials from these folders
vardefault('align_con','onset'); % align condition: indicates which trial events file to load from LocalEpoched; set to 'onset' or 'stimuli'
%     vardefault('align_con','stimuli'); % align condition: indicates which trial events file to load from LocalEpoched; set to 'onset' or 'stimuli'
vars_to_expand = {'analyze_this_block', 'ntrials_by_block', 'missing_trials_by_block', 'block_name'}; % variables to be formatted

%%% import and organize the file table
filelist = readtable(filelist_xlsx);
nsubs = height(filelist); 
[~,~,var_row] = xlsread(filelist_xlsx);     var_row = var_row(1,:); 
nameinds = cellfun(@isstr,var_row);
filelist.Properties.VariableNames(nameinds) =  var_row(nameinds);   %%% plug in variable names
% convert all strings to numbers
cell_var_inds = false(1,length(nameinds)); 
for icol = 1:size(filelist,2)
    if iscell(filelist{1,icol})  && ischar(filelist{1,icol}{1})
        cell_var_inds(icol) = true; 
        filelist{:,icol} = cellfun(@str2num,filelist{:,icol},'UniformOutput',false);
    end
end
temptable = filelist; 
for ivar = 1:length(vars_to_expand) % group all blocks under one table variable
    thisvar = vars_to_expand{ivar};
    old_table_ind = find(strcmp(thisvar,var_row));
    new_table_ind = find(strcmp(thisvar, temptable.Properties.VariableNames)); 
    cellvars_this_group = cell_var_inds(old_table_ind:old_table_ind+nblocks-1);
    if any(cellvars_this_group) %%% if any vars to be grouped are cells, make all cells
        varinds_to_make_cells = new_table_ind - 1 + find(~cellvars_this_group); 
        for i = 1:length(varinds_to_make_cells)
            newcol =  num2cell(temptable{:,varinds_to_make_cells(i)});
            eval(['temptable.', temptable.Properties.VariableNames{varinds_to_make_cells(i)}, '=newcol;'])
        end
    end
    temptable = mergevars(temptable, new_table_ind:[new_table_ind+nblocks-1], 'NewVariableName',thisvar);
end
filelist = temptable; clear temptable

%%% make table of target words
load(target_words_file); % load vars: Word and Condition
cellcol = cell(max_trials_per_block,1); nancol = nan(max_trials_per_block,1); 
% stim table height is determined by whether we're using one or both members of each trial pair
stim = table(Word(1:2/ntrials_per_trial_pair:end), cellcol,  cellcol,        nancol,  nancol,     nancol, 'VariableNames',...
            {                        'word_name','consonants_name','vowel_name','word','consonants', 'vowel'});
chars = char(stim.word_name);
stim.consonants_name = string(chars(:,[1, 4])); % get the phonemes of each word
stim.vowel_name = string(chars(:,2));
if ntrials_per_trial_pair==2 % add info about repetition condition if relevant
    stim.pair_comparison = cell(size(Condition));
    stim.pair_comparison(Condition==1) = deal({'identical'});
    stim.pair_comparison(Condition==2) = deal({'flipped'});
    stim.pair_comparison(Condition==3) = deal({'different'});
end

%%% assign each stim feature an index
stim_index_key = readtable(stim_index_key_filename); % load preset value/index list
for istim = 1:max_trials_per_block
    stim.word(istim) = stim_index_key.index(strcmp(stim.word_name{istim}, stim_index_key.feature_val));
    stim.consonants(istim) = stim_index_key.index(strcmp(stim.consonants_name{istim}, stim_index_key.feature_val));
    stim.vowel(istim) = stim_index_key.index(strcmp(stim.vowel_name{istim}, stim_index_key.feature_val));
end

%%% get trials to use by excluding missing trials
%   usable trials are any that are not marked as NaN in subject's OnsetTable.mat within /projectnb/busplab/Experiments/ECoG_Preprocessed/LocalProcessed
%%%    the indices listed in usable_trials_by_block point to trial indices in the stim table
filelist.usable_trials_by_block = cell(size(filelist.missing_trials_by_block)); 

if get_useable_trials_from_LocalEpoched % load good trials for each subject
    for isub = 1:nsubs
        subname = num2str(filelist.subject(isub)); 
        load([LocalEpoched_topdir, filesep, 'S', subname, filesep, 'Epoch_', align_con, '_12_Hilbert_HG'], 'event_info')
        for iblock = 1:length(event_info.ids_no_nan)
            pair_inds = event_info.ids_no_nan{iblock}; % this is the pair index, which excludes every 2nd trial from each pair
            if ntrials_per_trial_pair == 1
                filelist.usable_trials_by_block{isub, iblock} = pair_inds; % don't need to reformat trial inds
            elseif ntrials_per_trial_pair == 2
                inds_1and2 = sort([ (2*pair_inds), (2*pair_inds - 1)]); % add back the inds for the second of each pair
                filelist.usable_trials_by_block{isub, iblock} = inds_1and2; % inds for both 1st and 2nd in pair
                filelist.ntrials_by_block(isub, iblock) = length(inds_1and2); %% correct the listed number of usable trials
            else
                error('ntrials_per_trial_pair must be 1 or 2')
            end
        end
    end
elseif ~get_useable_trials_from_LocalEpoched % if getting bad/useable trials from the excel list
    if ntrials_per_trial_pair ~= 1 % get_useable_trials_from_LocalEpoched must be used when getting both trials from a pair
            error('The option get_useable_trials_from_LocalEpoched must be used when ntrials_per_trial_pair ~= 1')
    end
    for iblock = 1:length(filelist.usable_trials_by_block(:))
        filelist.usable_trials_by_block{iblock} = 1:max_trials_per_block;
        if ~isempty(filelist.missing_trials_by_block{iblock}) &&  ~isnan(filelist.missing_trials_by_block{iblock}(1))  % if there are missing trials in this block
            missing_trials_this_block = filelist.missing_trials_by_block{iblock};
            filelist.usable_trials_by_block{iblock}(missing_trials_this_block) = [];  %%% exclude the missing trials from list of analyzable trials
        end
    end
end

% eliminate wrong variable if get_useable_trials_from_LocalEpoched == true
if get_useable_trials_from_LocalEpoched
    filelist.missing_trials_by_block = []; 
end

% match each usable trial to its stim features; find blocks to skip
filelist.trials = cell(nsubs, 1); %%% for each subject, create a table containing data about each usable trial
filelist.blocks_to_skip = cell(nsubs, 1);  %%% list of blocks to not analyze any trials from in subsequent analyses
for isub = 1:nsubs
    itrial_within_block = []; % initialize
    block = []; %%% initialize; this variable will label the block of each trial
    analyze = false(0,0); % initialize; this variable will indicate whether a trial should be analyzed (based on inclusion in good vs. bad blocks)
    for iblock = 1:nblocks
        itrial_within_block = [itrial_within_block; filelist.usable_trials_by_block{isub, iblock}']; % add the trial inds from this block, this subject
        block = [block; repmat(iblock, max([filelist.ntrials_by_block(isub,iblock), 0]), 1)]; %%% block labels to be assigned each trial within trials table
        analyze = [analyze; repmat(  logical(filelist.analyze_this_block(isub,iblock)), max([filelist.ntrials_by_block(isub,iblock), 0]), 1  )]; %  analyze these trials or not
    end
    trials = [table(block, itrial_within_block, analyze), stim([itrial_within_block], :)]; %%% get stim data for all trials for this sub
    filelist.trials{isub} = trials; clear itrial_within_block block analyze trials      %%% add trials data to filelist
end
clear nsubs
