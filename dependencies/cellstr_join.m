function outcell = cellstr_join(cellstr1, cellstr2, sep)

outcell = [];

for i = 1:length(cellstr2)
    
    outcell = [outcell, strcat(cellstr1, sep, cellstr2{i})];
    
end