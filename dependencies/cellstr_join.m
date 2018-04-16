function outcell = cellstr_join(cellstr1, cellstr2, sep)

if ~exist('sep', 'var')
    sep = ',';
end

outcell = [];

for i = 1:length(cellstr1)
    outcell = [outcell, strcat(cellstr1{i}, sep, cellstr2)]; 
end
