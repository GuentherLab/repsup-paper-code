%%%% conclusion from this script: scott's electrodes.electrode indices don't match with projectnb/busplab/UserData/adaliri/RepSup/ProcessedDataset
%%% .... because s357 and s362 both have channels which ayoub marked in EEG.badChan, but which ARE included in electrodes.electrode
%%% .... (ie bad_ak_not_sk contain at least one electrode label)
%%%% .... so these these EEG.badChan lists are not simply an initial stage of bad channel removal that Scott worked from.
%
% AM 2021/8/16


fullset = 1:256; % full set of possible electrode indices to include
load('/usr2/postdoc/amsmeier/ECoG_Preprocessed_AM/electrodes.mat') % electrode list from scott kuzdeba

sub = 357; 
load('/projectnb/busplab/UserData/adaliri/RepSup/ProcessedDataset/S357_1.mat')
% load('/projectnb/busplab/UserData/adaliri/RepSup/ProcessedDataset/S357.mat')
bad_ad = unique([EEGALL{1}.badChan, EEGALL{2}.badChan, EEGALL{3}.badChan]); % all bad elecs in ayoub daliri's ProcessedDataset
good_sk = unique(electrodes.electrode(electrodes.subject==sub))'; % elecs listed in sk electrode list
missing_sk = fullset(~ismember(fullset,good_sk)); % electrodes missing from scott's electrode list
% the following list is 'Unused_chans' from sk's /projectnb2/busplab/UserData/skuzdeba/dataAnalysis/highgamma_dataextraction.m
sk_dataextraction_unused = [5 6 61:64 71:76 95 104 105 161:224]; 
bad_ad_not_sk = bad_ad(~ismember(bad_ad, missing_sk));   % electrodes in ad's bad elec list, not in sk's
% following is elecs in Unused which are missing from electrodes.electrode
unused_not_missing_from_electrodes_list = sk_dataextraction_unused(~ismember(sk_dataextraction_unused, missing_sk))

sub = 362; 
load('/projectnb/busplab/UserData/adaliri/RepSup/ProcessedDataset/S362.mat')
bad_ad = unique([EEGALL{1}.badChan, EEGALL{2}.badChan, EEGALL{3}.badChan, EEGALL{4}.badChan]); % all bad elecs in ayoub daliri's ProcessedDataset
good_sk = uniqu(electrodes.electrode(electrodes.subject==sub))'; % elecs listed in sk electrode list
missing_sk = fullset(~ismember(fullset,good_sk)); % electrodes missing from scott's electrode list
% the following list is 'Unused_chans' from sk's /projectnb2/busplab/UserData/skuzdeba/dataAnalysis/highgamma_dataextraction.m
sk_dataextraction_unused = [5,6,63,64,93:96,207:224]; % for s362, this list corresponds to subjects S362_1 and S362_Sess2
bad_ad_not_sk = bad_ad(~ismember(bad_ad, missing_sk));   % electrodes in ad's bad elec list, not in sk's
% following is elecs in Unused which are missing from electrodes.electrode
unused_not_missing_from_electrodes_list = sk_dataextraction_unused(~ismember(sk_dataextraction_unused, missing_sk))

sub = 372; 
load('/projectnb/busplab/UserData/adaliri/RepSup/ProcessedDataset/S372.mat')
bad_ad = unique([EEGALL{1}.badChan, EEGALL{2}.badChan, EEGALL{3}.badChan, EEGALL{4}.badChan]); % all bad elecs in ayoub daliri's ProcessedDataset
good_sk = unique(electrodes.electrode(electrodes.subject==sub))'; % elecs listed in sk electrode list
missing_sk = fullset(~ismember(fullset,good_sk)); % electrodes missing from scott's electrode list
% the following list is 'Unused_chans' from sk's /projectnb2/busplab/UserData/skuzdeba/dataAnalysis/highgamma_dataextraction.m
sk_dataextraction_unused = [1:66 85:96 109:128];
bad_ad_not_sk = bad_ad(~ismember(bad_ad, missing_sk));   % electrodes in ad's bad elec list, not in sk's
% following is elecs in Unused which are missing from electrodes.electrode
unused_not_missing_from_electrodes_list = sk_dataextraction_unused(~ismember(sk_dataextraction_unused, missing_sk))


