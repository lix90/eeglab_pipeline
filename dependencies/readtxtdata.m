function data = readtxtdata(txt, format, del, ignore, outputformat)
% data = readtxtdata(txt, format, del, ignore, outputformat)

if ~exist('ignore', 'var')
    ignore = 0;
end

if ~exist('format', 'var')
    format = '%s';
end

if ~exist('del', 'var')
    del = '\n';
end

if ~exist('outputformat', 'var')
   outputformat = 'str';
end

fid = fopen(txt, 'r');
content = textscan(fid, format, 'Delimiter', del);

content = content{:};
content(ignore,:) = [];

if strcmpi(outputformat, 'num')
    data = cellfun(@str2num, content, 'UniformOutput', false);
    data(cellfun(@isempty, data)) = [];
    data = cell2mat(data);
elseif strcmpi(outputformat, 'str')
    data = cellfun(@(x) strtrim(x), content, 'UniformOutput', false);
end
