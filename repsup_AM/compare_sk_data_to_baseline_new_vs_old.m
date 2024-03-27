% compare localprocessed kuzdeba data to data resulting from Rohan using -1000-500ms as baseline period....
%   .... vs -500-000ms as baseline period

%% load data to compare
load('/usr2/postdoc/amsmeier/ECoG_Preprocessed_RD/LocalEpoched/S372/Old/Epoch_onset_12_Hilbert_HG.mat')
rdold = preprocessed_data; clear preprocessed_data
load('/usr2/postdoc/amsmeier/ECoG_Preprocessed_RD/LocalEpoched/S372/Epoch_onset_12_Hilbert_HG.mat')
rdnew = preprocessed_data; clear preprocessed_data
load('/usr2/postdoc/amsmeier/ECoG_Preprocessed/LocalEpoched/S372/Epoch_onset_1_Hilbert_HG.mat')
sk = preprocessed_data; clear preprocessed_data

%%
% % % make sure that this corresponds to the same label in preprocessed_data.chan_ids in all 3 datasets! 
elecind = 1; % electrode to test.... 
trial = 1; 
subjectname = '372'; 
lwidth = 4; 

sktitle = 'Scott data';
rdoldtitle = 'Rohan data... baseline period =  -1000 to -500ms prestim '; 
rdnewtitle = 'Rohan data... baseline period =  -500 to 0ms prestim '; 

% % % % % subplot(2,2,1); 
% % % % % plot(squeeze(sk.data(elecind,:,trial)))
% % % % % ylabel('normalized HG amplitude')
% % % % % title(sktitle)
% % % % % 
% % % % % subplot(2,2,2); 
% % % % % plot(squeeze(rdold.data(elecind,:,trial)))
% % % % % title(rdoldtitle)
% % % % % 
% % % % % subplot(2,2,3); 
% % % % % plot(squeeze(rdnew.data(elecind,:,trial)))
% % % % % xlabel('time (ms)')
% % % % % ylabel('normalized HG amplitude')
% % % % % title(rdnewtitle)
% % % % % 
% % % % % subplot(2,2,4); 
% % % % % title('overlay')
hold on
plot(squeeze(sk.data(elecind,:,trial)),'-g', 'LineWidth',lwidth)
plot(squeeze(rdold.data(elecind,:,trial)), '-.r', 'LineWidth',lwidth-1)
plot(squeeze(rdnew.data(elecind,:,trial)), '-k', 'LineWidth',lwidth)
xlabel('time (ms)')
legend({sktitle, rdoldtitle, rdnewtitle},'FontSize',15)

suptitle(['Subject ', subjectname, ', electrode #', num2str(sk.chan_ids(elecind)), ', trial ', num2str(trial)])

