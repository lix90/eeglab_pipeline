% cut continous data into segments
% epochInterval: s(econd)
function EEG = cut_continuous(EEG, epochInterval)

if ~isnumeric(epochInterval)
    disp('epoch interval must be numeric');
end

trials = floor(EEG.pnts/(EEG.srate*epochInterval));
trialLength = epochInterval*EEG.srate;

eegdata = EEG.data;
nbchan = EEG.nbchan;
EEG.data = zeros(nbchan, trialLength, trials);

% cut tails
eegdata(:, trials*trialLength+1:end) = [];
% reshape matrix into channel * time * trial
EEG.data = reshape(eegdata, [nbchan, trialLength, trials]);

% for j = 1:trials
%    EEG.data(:,:,j) = eegdata(:,((j-1)*trialLength+1):j*trialLength);
% end

EEG.trials = trials
EEG.pnts = trialLength;
EEG.xmax = (epochInterval-1/EEG.srate);
EEG.times = EEG.times(1, 1:trialLength);

EEG = eeg_checkset(EEG);
