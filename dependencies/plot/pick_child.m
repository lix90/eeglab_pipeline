function c = pick_child(h, n)
% Aim: wrapper function to pick child(ren) from a graphic handle
% if n = []/'all'/not specified ==> pick all children
% otherwise, pick one child

if ~exist('n', 'var')
    n = [];
end

if ~ishandle(h)
    disp('Error: input argument (h) must be a handle.');
    return;
end

c_tmp = get(h, 'children');

if isempty(n) || strcmpi(n, 'all')
    c = c_tmp;
    return;
end

if round(n)~=n && n < 0
    disp('Error: input argument (n) must be a positve integer.');
    return;
end

if n > length(c_tmp)
    disp('Error: input argument (n) exceeds the number of children.');
    return;
end

c = c_tmp(n);
