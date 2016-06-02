function outCellStr = merge_cellstr(str1st, str2nd, delimiter)

% 
N1st = numel(str1st);
N2nd = numel(str2nd);
outCellStr = cell(N1st, N2nd);
for i1st = 1:N1st
    for i2nd = 1:N2nd
        outCellStr{i1st, i2nd} = [str1st{i1st}, delimiter, str2nd{i2nd}];
    end
end