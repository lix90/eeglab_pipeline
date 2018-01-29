function [filename, id] = get_fileinfo(input_dir, file_ext, sep)
% input_dir = input directory
% file_ext = file_extension of files; str or cellstr
% seprator
% lix <alexiangli@outlook.com>

if ~exist('sep', 'var')
    sep = '[^A-Za-z0-9]';
    pos = 0;
else
    pos = 1;
end

if ischar(file_ext)
   file_ext = {file_ext}; 
end

get_files = @(ext) dir(fullfile(input_dir, strcat('*', ext)));
filename = [];
for j = 1:numel(file_ext) % loop through file extensions
    tmp = get_files(file_ext{j});
    tmpfilename = natsort({tmp.name});
    filename = [filename, tmpfilename];
end

% get ids
id = [];
outstrs = regexp(filename, sep, 'split');
if pos == 1
    id = cellfun(@(x) x{sep}, outstrs, 'uniformoutput', false);
elseif pos == 0
    numstrs = cellfun(@(x) length(x), outstrs);
    minstr = min(numstrs) - 1;
    for i = 1:minstr
        tmpstr = cellfun(@(x) x{i}, outstrs, 'uniformoutput', false);
        if isempty(id)
            id = strcat(id, tmpstr);
        else
            id = strcat(id, '_', tmpstr);
        end
        if length(id) == length(unique(id))
            break
        end
    end
end
