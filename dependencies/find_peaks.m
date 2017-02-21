function [pkv, pki] = find_peaks(erp, range, direction, n_sample)
% Find peaks in ERP signals

if strcmpi(direction, 'n')
    erp = -1*erp;
end

[pki, pkv] = peakness(n_sample, erp, range);

if length(pki)==0
    pkv = max(erp(range(1):range(2)));
    pki = find(erp==pkv);
elseif length(pki)>1
    [pkv, w] = max(pkv);
    pki = pki(w);
end

if strcmpi(direction, 'n')
    pkv = -1*pkv;
end


