input_dir = '/Users/lix/Desktop/P2/';
file_ext = 'vhdr';
marks = {'S 11'  'S 12'  'S 23'  'S 24'  'S 51'  'S 52'  'S 53'  'S 54'};
marks_group = {{'S 11'  'S 12'},{'S 23'  'S 24'},...
               {'S 51'  'S 52'},{'S 53'  'S 54'}};
erp_timerange = [-0.2 1]; % s
baseline = [-200, 0]; % ms
time_select = [160, 200]; % ms
chan_select = {'FCz', ''};
job = 'single'; % 'single' or 'average'

filename = dir(fullfile(input_dir, strcat('*.', file_ext))); %% find files
filename = {filename.name}; %% get filenames

for i = 1:numel(filename)

    EEG = pop_loadbv(input_dir, filename{i});
    EEG = eeg_checkset( EEG );

    % export chanlocs
    if isfield(EEG, 'chanlocs') && i==1
        chanlocs = EEG.chanlocs;
        save(fullfile(input_dir, sprintf('chanlocs_%ichans.mat', ...
                                         length(chanlocs)))),'chanlocs');
    end

    % epoching
    EEG = pop_epoch( EEG, marks, erp_timerange);
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, baseline);
    EEG = eeg_checkset( EEG );

    switch job
      case 'single'
        % export single trials
        erp_time = [EEG.xmin:EEG.srate:EEG.xmax]*1000;

        t1 = find(erp_time>=time_select(1), 1, 'first');
        t2 = find(erp_time>=time_select(2), 1, 'first');

        erp_single = EEG.data;
        chan_select_index = ismember({chanlocs.labels}, chan_select);
        erp_single_select = squeeze(mean(mean(erp_single(chan_select_index, ...
                                                         t1:t2, :),1),2));
        % centering
        erp_single_select_center = erp_single_select-mean(erp_single_select);

        output_subjname = filename{i}(1:end-length(file_ext)-1);
        output_filename = sprintf('%s_%s_t%i-%i.mat', output_subjname, chan_select{1}, ...
                                  time_select(1), time_select(2));
        save(fullfile(input_dir, output_filename), 'erp_single_select_center');

      case 'average'
        % averaged erp
        n_chan = length(chanlocs);
        n_time = size(EEG.pnts);
        n_cond = numel(marks_group);
        n_subj = length(filename);
        erp_avg_all = zeros(n_chan, n_time, n_cond, n_subj);
        for j = 1:numel(marks_group)

            marks_now = marks_group{j};
            EEG_temp = pop_epoch(EEG, marks_now, [EEG.xmin, EEG.xmax]);

            erp_avg = mean(EEG_temp, 3);
            erp_avg_all(:,:,j,i) = erp_avg;
        end
    end

end

if strcmpi(job, 'average')
    save('erp_avg_all.mat', 'erp_avg_all');
end
% erp_avg_all: channels * time points * conditions * subjects
