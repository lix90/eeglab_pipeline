clear, close all, clc

input_dir = '~/Desktop/pes_data/first_pes/';
output_dir = fullfile(input_dir, 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

tmp = dir(fullfile(input_dir, '*.csv'));
files = {tmp.name};
filename = strtok(files, '.');

for iFile = 1:numel(filename)
    
    % tmp2 = csvread(fullfile(input_dir, files{iFile}));
    tmp2 = importdata(fullfile(input_dir, files{iFile}));
    % id = tmp2(:,1);
    % acc = tmp2(:,2);
    % rt = tmp2(:,3);
    % type = tmp2(:,4);
    id = tmp2.data(:,1);
    acc = tmp2.data(:,2);
    rt = tmp2.data(:,3);
    type = tmp2.data(:,4);
    % PE = rt(find(acc==0)+1);
    % ID = id(find(acc==0)+1);
    % TP = type(find(acc==0)+1);

    subj = [];
    PE = [];
    which = [];
    trial = [];
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
            % index_start = [];
            % index_end = [];
            % wrong_resp = [];
            % wrong_type = [];
            % pc_now = NaN;
            % abtain the range between two wrong responses
            index_start = wrong_index(i)+2;
            if i<n_wrong
                % if wrong_index(i+1)-wrong_index(i)>2
                index_end = wrong_index(i+1)-1;
                % end
            elseif i==n_wrong
                % if n_wrong-wrong_index(i)>1
                index_end = numel(acc_tmp);
                % end
            end
            try
                wrong_resp = type_tmp(index_start-1);
                wrong_type = type_tmp(index_start:index_end);
                wrong_rt = rt_tmp(index_start:index_end);
                pc_now = mean(wrong_rt(wrong_type==wrong_resp));
                fprintf('s%i, resp%i in %i, at %i, pc is %f\n',...
                        id_now, i, n_wrong, wrong_index(i), pc_now);
            catch
                pc_now = NaN;
            end
            subj = [subj; id_now];
            which = [which; wrong_resp];
            trial = [trial; wrong_index(i)];
            try
                PE = [PE; rt_tmp(index_start-1)];
            catch
                PE = [PE; NaN];
            end
            PC = [PC; pc_now];
        end
    end
    Pes.subj = subj;
    Pes.which = which;
    Pes.trial = trial;
    Pes.PE = PE;
    Pes.PC = PC;
    fn = sprintf('pes_%s.csv', filename{iFile});
    struct2csv(Pes, fullfile(output_dir, fn));
end
