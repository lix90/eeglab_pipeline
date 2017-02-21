function [peaks_val, peaks_lat] = pick_peaks(signal, times, ranges, direction, n_sample)
% Find peaks
%
% signal: erp signal, vector or matrix (let the row number of signal and
% the length of times be the same).
% times: erp time points
% ranges: the range to find peaks
% direction: 'n' or 'p' ===> 'negative' or 'positive'
%

if nargin<4
    disp('Error: not enough arguments.');
    return;
end

if ndims(signal)~=2
    disp('Error: input signal must be a two dimensional numeric array.');
    return;
end

if ~any(size(signal)==length(times))
    disp(['Error: One dimension of signal must has the same length with ' ...
          'times.']);
    return
end

if ~any(size(times)==1)
    disp('Error: times must be a vector.');
    return;
end

if ~length(ranges)==2 || ranges(2)<ranges(1)
    disp(['Error: ranges must has two element and the first element is smaller ' ...
          'than the second one.']);
    return;
end

if ~ischar(direction)
    disp('Error: the argument of `direction` must be `n` or `p`.');
    return;
end

if round(n_sample)~=n_sample
    disp('Error: n_sample must be an integer.');
    return;
end


if ~exist('n_sample', 'var')
    n_sample = 0;
end

subset = @(x,r) x(r(1):r(2));

idx_t = pick_time(times, ranges);
times_sub = subset(times, idx_t);

if any(size(signal)==1)
    signal = to_col_vector(signal);
else
    if size(signal,2)==length(times)
        signal = signal';
    end
end

% loop through the columns
n_col = size(signal,2);
peaks_val = zeros(n_col,1);
peaks_lat = peaks_val;

for i = 1:n_col

    signal_one_col = subset(signal(:,i), idx_t);
    [peak_val, peak_lat] = peaking(signal_one_col, direction);
    peaks_lat(i) = times_sub(peak_lat);

    if isempty(n_sample) || n_sample==0
        peaks_val(i) = peak_val;
    else
        if 2*n_sample+1 > length(signal_one_col)
            disp('Error: the n_sample is too big.');
            return;
        end
        % averaged peaks value in a range between left and right n_sample to
        % the peak
        % find where the peak is in the whole signal vector
        peak_lat_pos = find(times==times_sub(peak_lat));
        % find the range
        peak_range = [peak_lat_pos-n_sample, peak_lat_pos+n_sample];
        % calculate the mean
        peaks_val(i) = mean(subset(signal(:,i), peak_range));
    end
end


% function to find peaks
function [pk_vl, pk_lt] = peaking(s, d)

[xmax, imax, xmin, imin] = extrema(s);
switch d
  case 'p'
    if ~isempty(xmax)
        pk_vl = max(xmax);
        pk_lt = imax(xmax==pk_vl);
    else
        pk_vl = max(s);
        pk_lt = find(s==max(s));
    end
  case 'n'
    if ~isempty(xmin)
        pk_vl = min(xmin);
        pk_lt = imin(xmin==pk_vl);
    else
        pk_vl = min(s);
        pk_lt = find(s==pk_val);
    end
end
