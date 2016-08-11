function [icawinv, icasphere, icaweights] = run_ica(EEG, isavg);

nChan = size(EEG.data, 1);
if isavg
    [wts, sph] = runica(EEG.data, 'extended', 1, 'pca', nChan-1);
else
    [wts, sph] = runica(EEG.data, 'extended', 1);
end

iWts = pinv(wts*sph);
scaling = repmat(sqrt(mean(iWts.^2))', [1 size(wts,2)]);
wts = wts.*scaling;

icawinv = pinv(wts*sph);
icasphere = sph;
icaweights = wts;
