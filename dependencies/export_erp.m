function STUDY = export_erp(STUDY, ALLEEG, cfg)


direction = cfg.direction;
n_sample = cfg.n_sample;
prefix = cfg.prefix;
output_type = cfg.output_type;
lowpass_filter = cfg.lowpass_filter;
chan = cfg.chan_labels;
time = cfg.time_range;
output_dir = cfg.output_dir;

if ~isfield('cfg', 'subj_excluded')
    subj_excluded = 'xxxxxxxxxx';
else
    subj_excluded = cfg.subj_excluded;
end

[STUDY, erp, times] = ...
    compute_erp(STUDY, ALLEEG, ...
                chan, ...
                lowpass_filter, ...
                []);

[design_types, design_vars] = pick_design_type(STUDY);
[types, vars] = pick_design_variable(STUDY);

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

switch output_type
  case {'peak', 1}
    % two way mixed
    if design_types(1)==2 && design_types(2)==3
        for i = 1:ngroup
            grpsubj_ = pick_design_subject(STUDY, i);
            isubj_ = ~ismember(grpsubj_, subj_excluded);
            grpsubj = grpsubj_(isubj_);
            nsubj = length(grpsubj);
            pkv = cell(nsubj, ncond);
            pki = pkv;
            for j = 1:ncond
                if find(design_vars == 2)==1
                     erp_ = erp{i,j}(:,isubj_);
                elseif find(design_vars == 2)==2
                     erp_ = erp{j,i}(:,isubj_);
                end
                for k = 1:nsubj
                    fprintf('grp %i cond %i subj %i\n', i,j,k);
                    v = erp_(:,k);
                    [pkv{k, j}, pki{k, j}] = find_peaks(v, times, time, direction, []);
                end
            end
            pk_cell = cat(2, pkv, pki);
            % output each group
            header_str = cat(2, {'subject'}, ...
                             strcat('peak_', cond_tags),...
                             strcat('latency_', cond_tags));
            pk_out = cat(1, header_str, cat(2, grpsubj, pk_cell));
            fn_out = build_outputfn(strcat(prefix, '_group_', group_tags{i}), ...
                                    chan, time, [], [], 'csv');
            cell2csv(fullfile(output_dir, fn_out), pk_out, ',');
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
  case {'average', 2}
    
    % two way mixed
    if design_types(1)==2 && design_types(2)==3
        for i = 1:ngroup
            grpsubj_ = pick_design_subject(STUDY, i);
            isubj_ = ~ismember(grpsubj_, subj_excluded);
            grpsubj = grpsubj_(isubj_);
            
            nsubj = length(grpsubj);
            amp = cell(nsubj, ncond);
            range = pick_time(times, time);
            for j = 1:ncond
                if find(design_vars == 2)==1
                     erp_ = erp{i,j}(:,isubj_);
                elseif find(design_vars == 2)==2
                     erp_ = erp{j,i}(:,isubj_);
                end
                for k = 1:nsubj
                    v = erp_(:,k);
                    amp{k,j} = mean(v(range(1):range(2)));                    
                end
            end
            % output each group
            header_str = cat(2, {'subject'}, ...
                             strcat('avgamp_', cond_tags));
            pk_out = cat(1, header_str, cat(2, grpsubj, amp));
            fn_out = build_outputfn(strcat(prefix, '_group_', group_tags{i}), ...
                                    chan, time, [], [], 'csv');
            cell2csv(fullfile(output_dir, fn_out), pk_out, ',');
        end
    elseif design_types(1)==2 && design_types(2)==1
        subj = pick_design_subject(STUDY);
        nsubj = length(subj);
        nconds = ngroup*ncond;
        amp = [];
        range = pick_time(times, time);
        for i = 1:ngroup
            amp = cell(nsubj, ncond);
            for j = 1:ncond
                for k = 1:nsubj
                    v = erp{i,j}(:,k);
                    amp_{k,j} = mean(v(range(1):range(2)));
                end
            end
            amp = [amp, amp_];
        end
        % output each group
        header_str = cat(2, {'subject'}, ...
                         strcat('avgamp_', cellstr_join(group_tags, cond_tags, '_')));
        pk_out = cat(1, header_str, cat(2, subj, amp));
        fn_out = build_outputfn(prefix, ...
                                chan, time, [], [], 'csv');
        cell2csv(fullfile(output_dir, fn_out), pk_out, ',');
    elseif design_types(1)==1 && design_types(2)==0
        subj = pick_design_subject(STUDY);
        nsubj = length(subj);
        nconds = ngroup*ncond;
        amp = [];
        range = pick_time(times, time);
        for i = 1:ngroup
            amp = cell(nsubj, ncond);
            for j = 1:ncond
                for k = 1:nsubj
                    v = erp{i,j}(:,k);
                    amp_{k,j} = mean(v(range(1):range(2)));
                end
            end
            amp = [amp, amp_];
        end
        % output each group
        header_str = cat(2, {'subject'}, ...
                         strcat('avgamp_', cond_tags));
        pk_out = cat(1, header_str, cat(2, subj, amp));
        fn_out = build_outputfn(prefix, ...
                                chan, time, [], [], 'csv');
        cell2csv(fullfile(output_dir, fn_out), pk_out, ',');
        disp('one way within'); 
    end
end
