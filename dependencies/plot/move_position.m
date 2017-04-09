function varargout = move_position(h, varargin)
% input arguments: name-value
% 'left',
% 'bottom',
% 'width',
% 'height',

if mod(length(varargin),2)==1
    disp('Error: input argument error.')
    return;
end

try
    pos_old = get(h, 'position');
catch err
    throw(err);
    return;
end

if isemptyr(varargin)
    varargout{1} = pos_old;
    return;
end

names = varargin{1:2:end-1};
values = varargin{2:2:end};


values_default = [0,0,0,0];
names_default =  {'left', 'bottom', 'width', 'height'};
in_default = find(ismember(names_default, names));
for i = 1:length(in_default)
    values_default(in_default(i)) = values(i);
end
pos_new = pos_old+values_default;

set(h, 'position', pos_new);

if nargout == 1
    varargout{1} = pos_new;
elseif nargout == 2
    varargout{1} = pos_new;
    varargout{2} = pos_old;
end
