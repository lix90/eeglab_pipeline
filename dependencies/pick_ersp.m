function ersp = pick_ersp(signal, times, freqs, time_ranges, freq_ranges)

subset = @(x,t,f) x(f(1):f(2), t(1):t(2));

idx_t = pick_time(times, time_ranges);
idx_f = pick_freq(freqs, freq_ranges);

% loop through the columns --> subj
n_col = size(signal,3);
ersp = zeros(n_col,1);

for i = 1:n_col

    signal_one_col = subset(signal(:,:,i), idx_t, idx_f);
    ersp(i) = mean(signal_one_col(:));

end
