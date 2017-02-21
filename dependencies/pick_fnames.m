function [fnames, ids] = pick_fnames(input_dir, file_ext, matches, sep)
% Pick filenames from specified directory with specified file extension(s).

if ~isdir(input_dir)
    disp('Error: input directory is not a directory.');
    return;
end

if nargin < 2
    disp('Error: not enought input arguments.');
    return;
end

if ~exist('matches', 'var')
    matches = '[._+-]';
end

if ~exist('sep', 'var')
    sep = '_';
end

% Get filename
if ischar(file_ext)
    file_ext = {file_ext};
end

fnames = [];
for i = 1:length(file_ext)
    tmp = dir(fullfile(input_dir, strcat('*', file_ext{i})));
    fnames = [fnames, {tmp.name}];
end
fnames = natsort(fnames);

% Get ids
if nargout == 2
    n_fnames = length(fnames);
    outfnames = regexp(fnames, matches, 'split');
    unique_length = unique(cellfun(@length, outfnames));
    if length(unique_length)~=1
        unique_length = min(unique_length);
    end

    fn_parts = cell(length(fnames), unique_length);
    for j = 1:unique_length
        for k = 1:n_fnames
            tmp = outfnames{k}(j);
            fn_parts(k,j) = tmp;
        end
    end

    unique_value = [];
    for n = 1:unique_length
        unique_value = [unique_value, length(fn_parts(:,n))];
    end

    where_to_cut = find(unique_value == n_fnames);
    if isempty(where_to_cut)
        disp('Error: cannot split ids.');
        return;
    end

    ids = cellfun(@(x) str_join(x(1:where_to_cut(1)), sep), outfnames, ...
                  'UniformOutput', false);

    if length(ids)~=length(fnames)
        disp('Error: the lengths of output arguments do not match.');
        return;
    end

end
