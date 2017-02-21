function amp = pick_amplitude(signal, times, ranges)
% Get averaged amplitude
%
% signal: erp signal, vector or matrix (let the row number of signal and
% the length of times be the same).
% times: erp time points
% ranges: the range of components
%

if nargin<3
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
amp = zeros(n_col,1);

for i = 1:n_col

    signal_one_col = subset(signal(:,i), idx_t);
    amp(i) = mean(signal_one_col);

end
