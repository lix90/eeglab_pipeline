function [pkv, pki] = find_peaks(erp, times, range, direction, n_sample)
% Find peaks in ERP signals

if ~exist('n_sample', 'var')
    n_sample = [];
end

if strcmpi(direction, 'n')
   mode = 'troughs'; 
elseif strcmpi(direction, 'p')
    mode = 'peaks';
end

t = pick_time(times, range);
samples = t(1):t(2);
erpp = erp(samples);

[v, i] = pickpeaks(erpp, 1, 1, mode);

if ~isempty(v)
    if strcmpi(direction, 'n')
        [mv, mi] = min(v);
    elseif strcmpi(direction, 'p')
        [mv, mi] = max(v);
    end
    pki = times(samples(i(mi)));
else
   if strcmpi(direction, 'n')
        [mv, mi] = min(erpp);
    elseif strcmpi(direction, 'p')
        [mv, mi] = max(erpp);
   end
    pki = times(samples(mi));
end
pkv = mv;


% if ~isempty(n_sample) && i > n_sample && length(erpp)>= (i+n_sample)
%     pkv = mean(erpp((i-n_sample):(i+n_sample)));
% else
%     pkv = v; 
% end
    
    
