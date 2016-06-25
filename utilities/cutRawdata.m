function EEG = cutRawdata(EEG, epochInterval)

if ~isnumeric(epochInterval)
    disp('epoch interval must be numeric');
end

trials = floor(EEG.pnts/(EEG.srate*epochInterval));
trialLength = epochInterval*EEG.srate;

eegdata = EEG.data;
nbchan = size(EEG.data, 1);
EEG.data = zeros(nbchan, trialLength, trials);

% cut tails
EEG.data(:, trials*trialLength+1:end) = [];
% reshape matrix into channel * time * trial
EEG.data = reshape(EEG.data, [nbchan, trialLength, trials]);

% for j = 1:trials
%    EEG.data(:,:,j) = eegdata(:,((j-1)*trialLength+1):j*trialLength);
% end

EEG.trials = trials
EEG.pnts = trialLength;
EEG.xmax = (epochInterval-1/EEG.srate);
EEG.times = EEG.times(1, 1:trialLength);

EEG = eeg_checkset(EEG);