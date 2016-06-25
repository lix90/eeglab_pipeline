function [filename, id] = getFileInfo(inputDir, ext, pos)

tmp = dir(fullfile(inputDir, strcat('*', ext)));

filename = natsort({tmp.name});

% get id
id = cell(size(filename));
for i = 1:numel(filename)
	ind1 = strfind(filename{i}, '-');
	ind2 = strfind(filename{i}, '.');
	ind3 = strfind(filename{i}, '_');
	ind = union(ind1, ind2);
	ind = union(ind, ind3);
	ind_need = ind(pos);
	id{i} = filename{i}(1:ind_need-1);
end

id = natsort(unique(id));