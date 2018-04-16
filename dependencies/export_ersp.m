function STUDY = export_ersp(STUDY, ALLEEG, cfg)

prefix = cfg.prefix;
chan = cfg.chan_labels;
time = cfg.time_range;
freq = cfg.freq_range;
output_dir = cfg.output_dir;

[STUDY, ersp_data, times, freqs] = ...
    compute_ersp(STUDY, ALLEEG, ...
                chan);
            
 if numel(chan)~=1
     erspp = cellfun(@(x) {squeeze(mean(x, 3))}, ersp_data);
 else
     erspp = ersp_data;
 end

[design_types, design_vars] = pick_design_type(STUDY);
[types, vars] = pick_design_variable(STUDY);

ngroup = length(vars{design_vars==2});
ncond = length(vars{design_vars==1});
group_tags = vars{design_vars==2};
cond_tags = vars{design_vars==1};

t = pick_time(times, time);
f = pick_freq(freqs, freq);

    % two way mixed
    if design_types(1)==2 && design_types(2)==3
        for i = 1:ngroup
            grpsubj = pick_design_subject(STUDY, i);
            nsubj = length(grpsubj);
            ersppp = cell(nsubj, ncond);
            for j = 1:ncond
                for k = 1:nsubj
                    if find(design_vars == 2)==1
                        v = erspp{i,j}(:,:,k);
                    elseif find(design_vars==2)==2
                        v = erspp{j,i}(:,:,k);
                    end
                    ersppp{k,j} = mean(mean(v(f(1):f(2),t(1):t(2))));
                end
            end
            % output each group
            header_str = cat(2, {'subject'}, ...
                             strcat('ersp_', cond_tags));
            ersp_out = cat(1, header_str, cat(2, grpsubj, ersppp));
            fn_out = build_outputfn(strcat(prefix, '_group_', group_tags{i}), ...
                                    chan, time, freq, [], 'csv');
            cell2csv(fullfile(output_dir, fn_out), ersp_out, ',');
        end
    elseif design_types(1)==2 && design_types(2)==1
        subj = pick_design_subject(STUDY);
        nsubj = length(subj);
        nconds = ngroup*ncond;
        erspppp = [];
        for i = 1:ngroup
            erspppp = cell(nsubj, ncond);
            for j = 1:ncond
                for k = 1:nsubj
                    v = erspp{i,j}(:,:,k);
                    ersppp{k,j} = mean(mean(v(f(1):f(2),t(1):t(2))));
                end
            end
            erspppp = [erspppp, ersppp];
        end
       
        % output each group
        header_str = cat(2, {'subject'}, ...
                         strcat('ersp_', cellstr(group_tags, cond_tags, '_')));
        ersp_out = cat(1, header_str, cat(2, subj, erspppp));
        fn_out = build_outputfn(prefix, ...
                                chan, time, freq, [], 'csv');
        cell2csv(fullfile(output_dir, fn_out), ersp_out, ',');
    elseif design_types(1)==1 && design_types(2)==1
        disp('TODO');
    elseif design_types(1)==1 && design_types(2)==1
        disp('TODO');
    end
  
