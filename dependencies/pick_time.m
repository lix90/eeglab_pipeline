function idx = pick_time(times, time_range)

nl = length(time_range);

if nl>2
    disp('Error: The length of time_range must be 1 or 2.');
    return;
end

if nl==2 && time_range(1) > time_range(2)
    disp('Error: time_range(1) shouldn''t be bigger than time_range(2).')
end

times = to_col_vector(times);
time_range = to_col_vector(time_range);
idx = dsearchn(times, time_range);

