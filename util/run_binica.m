function EEG = runBINICA(EEG, offlineRef);

nChan = size(EEG.data, 1);
if strcmp(offlineRef, 'average')
    [wts, sph] = binica(EEG.data, 'extended', 1, 'pca', nChan-1);
else
    [wts, sph] = binica(EEG.data, 'extended', 1);
end

iWts = pinv(wts*sph);
scaling = repmat(sqrt(mean(iWts.^2))', [1 size(wts,2)]);
wts = wts.*scaling;

EEG.icawinv = pinv(wts*sph);
EEG.icasphere = sph;
EEG.icaweights = wts;
EEG.icaact = [];
EEG = eeg_checkset(EEG);
