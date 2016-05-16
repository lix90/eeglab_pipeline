function p = findPeak(data, indices, range);

if ndims(data)~=2
    disp('only for two dims')
    return
end
if size(data,1)>1 && size(data, 2) >1
    disp('only for vector')
    return
end

% find index of range
i1 = find(indices>=range(1), 1);
i2 = find(indices<=range(2), 1, 'last');
s = i1:i2;

% subset data
subdata = data(i1:i2);

% find peak index
[~, ip] = max(subdata);
% get peak values
p = indices(s(ip));

if p<range(1) || p>range(2)
    p = 10;
end

