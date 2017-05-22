function [filename, id] = get_fileinfo(input_dir, file_ext, sep)
% input_dir = input directory
% file_ext = file_extension of files; str or cellstr
% seprator
% lix <alexiangli@outlook.com>

if ~exist('sep', 'var')
    sep = '[^a-z0-9]';
    pos = 0;
else
    pos = 1;
end

get_files = @(ext) dir(fullfile(input_dir, strcat('*', ext)))
if iscellstr(file_ext)
    filename = [];
    for j = 1:numel(file_ext) % loop through file extensions
        tmp = get_files(file_ext{j});
        tmpfilename = natsort({tmp.name});
        filename = [filename, tmpfilename];
    end
elseif ischar(file_ext)
    tmp = get_files(file_ext);
    filename = natsort({tmp.name});
end

% get ids
id = [];
outstrs = regexp(filename, sep, 'split');
if pos == 1
    id = cellfun(@(x) x{pos}, outstrs, 'uniformoutput', false);
elseif pos == 0
    numstrs = cellfun(@(x) length(x), outstrs);
    minstr = min(numstrs);
    for i = 1:minstr
        tmpstr = cellfun(@(x) x{i}, outstrs, 'uniformoutput', false);
        id = strcat(id, tmpstr);
        if length(id) == length(unique(id))
            break
        end
    end
end
