clear, close all, clc

input_dir = '~/Desktop/pes_data/first_pes/';
output_dir = fullfile(input_dir, 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

tmp = dir(fullfile(input_dir, '*.csv'));
files = {tmp.name};
filename = strtok(files, '.');

for iFile = 1:numel(filename)
    % tmp2 = importdata(fullfile(input_dir, files{iFile}));
    % fid = fopen(fullfile(input_dir, files{iFile}));
    % M = textscan(fid, '%i%i%i%i', 'delimiter', ',');
    % fclose(fid)

    tmp2 = csvread(fullfile(input_dir, files{iFile}));
    % id, acc, rt, type
    id = tmp2(:,1);
    acc = tmp2(:,2);
    rt = tmp2(:,3);
    type = tmp2(:,4);

    PE = rt(find(acc==0)+1);
    ID = id(find(acc==0)+1);
    TP = type(find(acc==0)+1);
    % pre-allocation
    PC = [];
    id_unique = unique(id);
    for i_id = 1:numel(id_unique) % subject loop start

        id_now = id_unique(i_id);
        idx_id_now = id==id_now;
        acc_tmp = acc(idx_id_now); % current subject acc
        rt_tmp = rt(idx_id_now); % current subject rt
        type_tmp = type(idx_id_now); % current subject type of stimuli
        wrong_index = find(acc_tmp==0); % wrong response index of current
                                        % subject
        n_wrong = numel(wrong_index);
        for i = 1:n_wrong
            fprintf('s%i, resp%i in %i, at %i\n',...
                    i_id, i, n_wrong, wrong_index(i));
            index_start = [];
            index_end = [];
            wrong_resp = [];
            wrong_type = [];
            pc_now = NaN;
            % abtain the range between two wrong responses
            if i<n_wrong
                % if wrong_index(i+1)-wrong_index(i)>2
                % check if the distance
                % between former wrong
                % response and later
                % wrong response is
                % bigger than 2
                index_start = wrong_index(i)+2;
                index_end = wrong_index(i+1)-1;
                % end
            elseif i==n_wrong
                % if n_wrong-wrong_index(i)>1 % if wrong response
                % is at the end of acc_tmp
                index_start = wrong_index(i)+2;
                index_end = numel(acc_tmp);
                % end
            end
            try
                wrong_resp = type_tmp(index_start-1);
                wrong_type = type_tmp(index_start:index_end);
                wrong_rt = rt_tmp(index_start:index_end);
                pc_now = mean(wrong_rt(wrong_type==wrong_resp));
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
