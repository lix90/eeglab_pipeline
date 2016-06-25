badChanLabels = {'Fpz'};
% chanLabels = {EEG.chanlocs.labels};
% badIdx = ismember(chanLabels, badChanName);
EEG.etc.badChanLabels = badChanLabels;
EEG = pop_saveset( EEG, 'savemode', 'resave');
