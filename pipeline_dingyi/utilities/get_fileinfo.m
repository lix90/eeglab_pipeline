function [filename, id] = get_fileinfo(indir, ext, varargin)

% if varargin
% 	disp('the least number of input parameters is two')
% 	return
% end


switch nargout
case 1
	tmp = dir(fullfile(indir, strcat('*', ext)));
	filename = natsort({tmp.name});
case 2
  pos = varargin{1};
	tmp = dir(fullfile(indir, strcat('*', ext)));
	filename = natsort({tmp.name});
	id = get_prefix(filename, pos);
	id = natsort(unique(id));
end

% if nargout==1
% 	out1 = filename;
% elseif nargout==2
% 	out1 = filename;
% 	out2 = id;
% end