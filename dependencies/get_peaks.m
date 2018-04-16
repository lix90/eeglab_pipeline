function [pkv, pki] = get_peaks()

% find local maxing
[lmaxv, imax] = lmax(v, FILT);
[lminv, imin] = lmin(v, FILT);

% check the number of peaks
if isempty(union(lmaxv, imax))
    lmaxv = max(v);
else
    lmaxv = mean(lmaxv);
end
if isempty(union(lminv, imin))
    frn_i = 0;
    frn_lat_i = erp_times(t2);
else
    frn_i = lmaxv - mean(lminv);
    frn_lat_i = mean(erp_times(samples(imin)));
end
