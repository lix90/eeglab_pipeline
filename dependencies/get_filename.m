function filename = get_filename(inputdir, ext)

get_files = @(ext) dir(fullfile(inputdir, strcat('*', ext)));
if iscellstr(ext)
    filename = [];
    for j = 1:numel(ext) % loop through file extensions
        tmp = get_files(ext{j});
        tmpfilename = natsort({tmp.name});
        filename = [filename, tmpfilename];
    end
elseif ischar(ext)
    tmp = get_files(ext);
    filename = natsort({tmp.name});
end
