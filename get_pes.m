clear, close all, clc

input_dir = '~/Desktop/pes_data/';
output_dir = fullfile(input_dir, 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

tmp = dir(fullfile(input_dir, '*zz.csv'));
files = {tmp.name};
filename = strtok(files, '.');

for iFile = 1:numel(filename)
    tmp2 = importdata(fullfile(input_dir, files{iFile}));
    % id, acc, rt, type
    id = tmp2.data(:,1);
    acc = tmp2.data(:,2);
    rt = tmp2.data(:,3);
    type = tmp2.data(:,4);
    PE = rt(find(acc==0)+1);
    ID = id(find(acc==0)+1);
    TP = type(find(acc==0)+1);
    % pre-allocation
    PC = [];
    id_unique = unique(id);
    for i_id = 1:numel(id_unique)
        acc_tmp = acc(id==id_unique(i_id));
        rt_tmp = rt(id==id_unique(i_id));
        type_tmp = type(id==id_unique(i_id));
        wrong_index = find(acc_tmp==0);
        for i = 1:numel(wrong_index)
            if i<numel(wrong_index)
                index_start = wrong_index(i)+2;
                index_end = wrong_index(i+1)-1;
            elseif i==numel(wrong_index)
                index_start = wrong_index(i)+2;
                index_end = numel(acc_tmp);
            end
            try
                wrong_resp = type_tmp(index_start-1);
                wrong_type = (type_tmp==wrong_resp);
                wrong_type = wrong_type(index_start:index_end);
                wrong_rt = rt_tmp(index_start:index_end);
                pc_now = mean(wrong_rt(wrong_type));
            catch
                pc_now = NaN;
            end
            PC = [PC; pc_now];
        end
    end
    Pes.ID = ID;
    Pes.TP = TP;
    Pes.PE = PE;
    Pes.PC = PC;
    fn = sprintf('pes_%s.csv', filename{iFile});
    struct2csv(Pes, fullfile(output_dir, fn));
end
