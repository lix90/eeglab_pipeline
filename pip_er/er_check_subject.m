base_dir = '';
input_tag ='';
output_tag = 'output';
file_ext = 'set';
sep_pos = 1;
chan_used = {'Pz'};
% marks = {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'};
% conds = {'f_neg', 's_neg', 'f_neu', 'r_neg', 'sr_neg'};
% colors = {'k', ''}
NEU = {'S 33'};
NEG = {'S 11'};

input_dir = fullfile(base_dir, input_tag);
output_dir = fullfile(base_dir, output_tag);
mkdir_p(output_dir);
[input_fname, id] = get_fileinfo(input_dir, file_ext, sep_pos);
nf = numel(id);

good_or_bad = zeros(nf,1);
how_good = zeros(nf,1);

% output file
output_fname = sprintf('check_subject_erp_%s.csv', strjoin(chan_used, '-'));
output_fname_full = fullfile(output_dir, output_fname);

if exist(output_fname_full, 'file')
    warning('files alrealy exist!');
else
    fid = fopen(output_fname_full, 'w');
    fprintf(fid, ['subject,good_or_bad,how_good\n']);

    for i = 1:nf

        fig_fname = sprintf('fig_%s.pdf', id{i});
        fig_fullpath = fullfile(output_dir, fig_fname);

        disp('========================================');
        fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
        disp('========================================');
        fprintf('\n\n');

        fprintf(fid, [id{i},',']);

        EEG = import_data(input_dir, input_fname{i});
        EEG = pop_subcomp(EEG, []);
        EEG = eeg_checkset(EEG);
        EEG = pop_rmbase(EEG, [EEG.xmin*1000, 0]);

        times = EEG.times;
        chan_labels = {EEG.chanlocs.labels};
        chan_index = find(ismember(chan_labels, chan_used));

        % for neutral condition
        EEG_neu = pop_epoch(EEG, NEU, [EEG.xmin, EEG.xmax]);
        EEG_neu = pop_epoch(EEG, NEG, [EEG.xmin, EEG.xmax]);

        if numel(chan_index)>1
            data_neu = squeeze(mean(EEG_neu.data(chan_index,:,:),1));
            data_neg = squeeze(mean(EEG_neg.data(chan_index,:,:),1));
        elseif numel(chan_inde)==1
            data_neu = squeeze(EEG_neu.data(chan_index,:,:));
            data_neu = squeeze(EEG_neg.data(chan_index,:,:));
        end

        data_neu_avg = squeeze(mean(data_neg, 2));
        data_neg_avg = squeeze(mean(data_neg, 2));

        data_diff = data_neg_avg - data_neu_avg;

        start = EEG.xmin*1000;
        ending = EEG.xmax*1000;

        ploterp = figure('erp');

        % neutral single trials
        subplot(2,2,1,'parent',ploterp);
        plot(times, data_neu, 'gray', 'LineWidth', 0.5);
        set(gca, 'YDir', 'reverse');
        xlim([start, ending]);
        ylim([-50, 70]);
        hold on;
        plot(times, data_neu_avg, 'k', 'LineWidth', 2);
        plot([0,0], [-50,70], ':k', 'LineWidth', 0.5);
        plot([start, ending], [0, 0], ':k', 'LineWidth', 0.5);
        plot([start, ending], [20, 20], ':k', 'LineWidth', 0.5);
        plot([start, ending], [-10, -10], ':k', 'LineWidth', 0.5);
        hold off;
        title('Neutral');

        % negative single trials
        subplot(2,2,2,'parent',ploterp);
        plot(times, data_neg, 'g', 'LineWidth', 0.5);
        set(gca, 'YDir', 'reverse');
        xlim([start, ending]);
        ylim([-50, 70]);
        hold on;
        plot(times, data_neg_avg, 'k', 'LineWidth', 2);
        plot([0,0], [-50,70], ':k', 'LineWidth', 0.5);
        plot([start, ending], [0, 0], ':k', 'LineWidth', 0.5);
        plot([start, ending], [20, 20], ':k', 'LineWidth', 0.5);
        plot([start, ending], [-10, -10], ':k', 'LineWidth', 0.5);
        hold off;
        title('Negative');

        % neutral & negative average
        subplot(2,2,3,'parent',ploterp);
        plot(times, data_neu_avg, 'k', 'LineWidth', 2);
        set(gca, 'YDir', 'reverse');
        xlim([start, ending]);
        ylim([-10, 20]);
        hold on;
        plot(times, data_neg_avg, 'b', 'LineWidth', 2);
        plot(times, data_diff, 'r', 'LineWidth', 2);
        plot([0,0], [-10,20], ':k', 'LineWidth', 0.5);
        plot([start, ending], [0, 0], ':k', 'LineWidth', 0.5);
        hold off;
        title('Negative, Neutral, & Difference');
        legend(gca, {'Neutral', 'Negative', 'Difference'}, 'Location', 'SouthEast');

        % neutral & negative average
        subplot(2,2,4,'parent',ploterp);
        plot(times, data_neu_avg, 'k', 'LineWidth', 2);
        set(gca, 'YDir', 'reverse');
        xlim([start, 600]);
        ylim([-10, 20]);
        hold on;
        plot(times, data_neg_avg, 'b', 'LineWidth', 2);
        plot(times, data_diff, 'r', 'LineWidth', 2);
        plot([0,0], [-10,20], ':k', 'LineWidth', 0.5);
        plot([start, 600], [0, 0], ':k', 'LineWidth', 0.5);
        plot([start, 600], [5, 5], ':k', 'LineWidth', 0.5);
        plot([start, 600], [-5, -5], ':k', 'LineWidth', 0.5);
        hold off;
        title('Negative, Neutral, & Difference (-200 ~ 600ms)');
        legend(gca, {'Neutral', 'Negative', 'Difference'}, 'Location', 'SouthEast');

        good_or_bad_v = [];
        while isempty(good_or_bad_v)
            good_or_bad_v = input('Good or Bad? 1/0:');
            if isempty(good_or_bad_v)
                disp('Please input 1 or 0');
                good_or_bad_v = [];
            end
        end

        how_good_v = [];
        while isempty(how_good_v)
            how_good_v = input('How Good Is It? 1-5:');
            if ~isnumeric(how_good_v)
                disp('The value must be a number');
                how_good_v = [];
            elseif how_good_v < 0 || how_good_v > 5
                disp('The value must be a number between 0 ~ 5');
                how_good_v = [];
            end
        end

        fprintf(fid, sprintf('%i,', good_or_bad_v));
        if i==nf
            fprintf(fid, sprintf('%i', how_good_v));
        else
            fprintf(fid, sprintf('%i\n', how_good_v));
        end

        print -dpdf -r300 fig_fullpath;

        while ishandle(ploterp)
            disp('Please close the figure');
        end

    end
end
