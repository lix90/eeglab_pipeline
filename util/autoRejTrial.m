function [EEG, rejSubj] = autoRejTrial(EEG, thresh, prob, kurt, threshTrialPerChan, threshTrialPerSubj)

lowThresh = thresh(1);
upThresh = thresh(2);
probE = prob(1);
probW = prob(2);
kurtE = kurt(1);
kurtW = kurt(2);

nTrial = EEG.trials;
% identify epoch
EEG = autoRejEpoch(EEG, lowThresh, upThresh, probE, probW, kurtE, kurtW);
if ~isempty(EEG.reject.rejglobalE) && exist('threshTrialPercentage', 'var')
    perBadEpochInChannels = 100*sum(EEG.reject.rejglobalE, 2)/ ...
        size(EEG.reject.rejglobalE, 2);
    rejChannels = find(perBadEpochInChannels > threshTrialPerChan);
    if any(rejChannels)
        EEG = pop_select(EEG, 'nochannel', rejChannels);
        EEG = eeg_checkset(EEG);
        % identify epoch again
        EEG = autoRejEpoch(EEG, lowThresh, upThresh, probE, probW, kurtE, ...
                           kurtW);
    end
end
indexRej = find(EEG.reject.rejglobal);
EEG = pop_rejepoch(EEG, find(EEG.reject.rejglobal) ,0);

% whether or not to reject subject
if ceil(100*length(indexRej)/nTrial) > threshTrialPerSubj
    rejSubj = 1;
else
    rejSubj = 0;
end

function EEG = autoRejEpoch(EEG, lowThresh, upThresh, probE, probW, kurtE, ...
                            kurtW)

EEG = pop_eegthresh(EEG,1,1:EEG.nbchan,lowThresh,upThresh,EEG.xmin,EEG.xmax, 0, 0);
EEG = pop_jointprob(EEG,1,1:EEG.nbchan,probE,probW,0,0);
EEG = pop_rejkurt(EEG,1,1:EEG.nbchan,kurtE,kurtW,0,0);
EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);