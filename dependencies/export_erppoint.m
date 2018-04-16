function STUDY = export_erppoint(STUDY, ALLEEG, cfg)



prefix = cfg.prefix;

lowpass_filter = cfg.lowpass_filter;
chan = [];
time = [];
output_dir = cfg.output_dir;

if ~isfield('cfg', 'subj_excluded')
    subj_excluded = 'xxxxxxxxxx';
else
    subj_excluded = cfg.subj_excluded;
end

[STUDY, ~, ~] = ...
    compute_erp(STUDY, ALLEEG, ...
                chan, ...
                lowpass_filter, ...
                []);

[design_types, design_vars] = pick_design_type(STUDY);
[types, vars] = pick_design_variable(STUDY);
chanlabels = [STUDY.changrp.channels];
erpdata = {STUDY.changrp.erpdata};

if any(design_vars==0)
    ngroup = 1;
    group_tags = {'group'};
else
    ngroup = length(vars{design_vars==2});
    group_tags = vars{design_vars==2};
end

ncond = length(vars{design_vars==1});
cond_tags = vars{design_vars==1};

if ~iscellstr(group_tags)
    group_tags_ = cellfun(@(x) num2cellstr(x), group_tags);
    group_tags = group_tags_;
end

if ~iscellstr(cond_tags)
    cond_tags_ = cellfun(@(x) num2cellstr(x), cond_tags);
    cond_tags = cond_tags_;
end


    % two way mixed
    if design_types(1)==2 && design_types(2)==3
        for i = 1:ngroup
            grpsubj_ = pick_design_subject(STUDY, i);
            isubj_ = ~ismember(grpsubj_, subj_excluded);
            grpsubj = grpsubj_(isubj_);
            nsubj = length(grpsubj);
            pkv = cell(nsubj, ncond);
            pki = pkv;
            for isubj = 1:numel(grpsubj)
                for j = 1:ncond
                    for ielec = 1:numel(chanlabels)
                        if find(design_vars == 2)==1
                             erpp_ = erpdata{ielec}{i,j}(:,isubj);
                        elseif find(design_vars == 2)==2
                             erpp_ = erpdata{ielec}{j,i}(:,isubj);
                        end
                        erpp(ielec,:) = erpp_;
                    end
                    output_fn = fullfile(output_dir, strcat(grpsubj{isubj}, '_', group_tags{i} ,'_', cond_tags{j}, '.txt'));
                    %header_str =[{'pnts'}, chanlabels];
                    data_cell = num2cellstr(erpp');
                    data_index = transpose(num2cellstr(1:size(data_cell, 1)));
                    %output_data = [header_str; [data_index, data_cell]];
                    output_data = [data_index, data_cell];
                    cell2csv(output_fn, output_data, ' ');
                end
            end
        end
        % two way within
    elseif design_types(1)==2 && design_types(2)==1
        subj = pick_design_subject(STUDY);
        nsubj = length(subj);
        nconds = ngroup*ncond;
        pkvv = [];
        pkii = [];
        for i = 1:ngroup
            pkv = cell(nsubj, ncond);
            pki = pkv;
            for j = 1:ncond
                for k = 1:nsubj
                    v = erp{i,j}(:,k);
                    [pkv{k, j}, pki{k, j}] = find_peaks(v, times, time, direction, n_sample);
                end
            end
            pkvv = [pkvv, pkv];
            pkii = [pkii, pki];
        end
        pk_cell = cat(2, pkvv, pkii);
        % output each group
        header_str = cat(2, {'subject'}, ...
                         strcat('peak_', cellstr_join(group_tags, cond_tags, '_')),...
                         strcat('latency_', cellstr_join(group_tags, cond_tags, '_')));
        pk_out = cat(1, header_str, cat(2, subj, pk_cell));
        fn_out = build_outputfn(prefix, ...
                                chan, time, [], [], 'csv');
        cell2csv(fullfile(output_dir, fn_out), pk_out, ',');
    elseif design_types(1)==1 && design_types(2)==1
        % one way within
        subj = pick_design_subject(STUDY);
        nsubj = length(subj);
        nconds = ngroup*ncond;
        pkvv = [];
        pkii = [];
        pkv = cell(nsubj, ncond);
            pki = pkv;
            for j = 1:ncond
                for k = 1:nsubj
                    v = erp{j}(:,k);
                    [pkv{k, j}, pki{k, j}] = find_peaks(v, times, time, direction, n_sample);
                end
            end
            pkvv = [pkvv, pkv];
            pkii = [pkii, pki];
            pk_cell = cat(2, pkvv, pkii);
        % output each group
        header_str = cat(2, {'subject'}, ...
                         strcat('peak_', cond_tags),...
                         strcat('latency_', cond_tags));
        pk_out = cat(1, header_str, cat(2, subj, pk_cell));
        fn_out = build_outputfn(prefix, ...
                                chan, time, [], [], 'csv');
        cell2csv(fullfile(output_dir, fn_out), pk_out, ',');
        disp('one way within');
    end

