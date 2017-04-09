function set_property(h, name, value)

if ~ishandle(h)
    disp('Error: input argument are not graphic handles.');
    return;
end

if nargin < 2
    get(h);
    return;
end

if length(h) < length(value)
    value = value(1:length(h));
end

if length(h) > 1 && length(value)==1
    set(h, name, value{:});
    return;
end

for i = 1:length(h)
    set(h(i), name, value{i});
end
