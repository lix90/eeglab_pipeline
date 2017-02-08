clear, clc, close all
base_dir = '/Volumes/play/sex-role/';
input_tag ='epoch-40hz';
output_tag = 'output-40hz';
file_ext = 'set';
sep_pos = 1;
chan_used = 'P3';
% marks = {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'};
% conds = {'f_neg', 's_neg', 'f_neu', 'r_neg', 'sr_neg'};
% colors = {'k', ''}
NEU = {'S 33'};
NEG = {'S 11'};
% NEU = {'free_neutral'};
% NEG = {'free'};

input_dir = fullfile(base_dir, input_tag);
output_dir = fullfile(base_dir, output_tag);
mkdir_p(output_dir);
[input_fname, id] = get_fileinfo(input_dir, file_ext, sep_pos);
nf = numel(id);

good_or_bad = zeros(nf,1);
how_good = zeros(nf,1);

% output file
output_fname = sprintf('check_subject_erp_%s.csv', chan_used);
output_fname_full = fullfile(output_dir, output_fname);
fig_dir = fullfile(output_dir, sprintf('fig_%s', chan_used));
mkdir_p(fig_dir);

% if exist(output_fname_full, 'file')
%     warning('files alrealy exist!');
% else
% fid = fopen(output_fname_full, 'w');
% fprintf(fid, ['subject,good_or_bad,how_good\n']);

for i = 1:nf

    fig_fname = sprintf('fig_%s.pdf', id{i});
    fig_fullpath = fullfile(fig_dir, fig_fname);

    fprintf('\n\n');
    disp('========================================');
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    disp('========================================');
    fprintf('\n\n');

    if exist(fig_fullpath)
        continue;
    end
    % fprintf(fid, [id{i},',']);

    EEG = import_data(input_dir, input_fname{i});
    EEG = pop_subcomp(EEG, []);
    EEG = eeg_checkset(EEG);
    EEG = pop_eegfiltnew(EEG, 0, 30);
    EEG = pop_rmbase(EEG, [-200, 0]);
    chan_index = find(ismember({EEG.chanlocs.labels}, chan_used));
    EEG = pop_eegthresh(EEG, 1, chan_index, -80, 80, ...
                        EEG.xmin*1000, EEG.xmax*1000, 0, 1);
    EEG = eeg_checkset(EEG);

    % for neutral condition
    epoch_time = [-0.2, 4];
    try
        EEG_neu = pop_epoch(EEG, NEU, epoch_time);
        EEG_neg = pop_epoch(EEG, NEG, epoch_time);
    catch
        continue;
    end
    times = EEG_neu.times;

    if numel(chan_index)>1
        data_neu = squeeze(mean(EEG_neu.data(chan_index,:,:),1));
        data_neg = squeeze(mean(EEG_neg.data(chan_index,:,:),1));
    elseif numel(chan_index)==1
        data_neu = squeeze(EEG_neu.data(chan_index,:,:));
        data_neg = squeeze(EEG_neg.data(chan_index,:,:));
    end

    data_neu_avg = squeeze(mean(data_neu, 2));
    data_neg_avg = squeeze(mean(data_neg, 2));

    data_diff = data_neg_avg - data_neu_avg;

    start = epoch_time(1)*1000;
    ending = epoch_time(2)*1000;
    YLIM = 25;
    %% plot
    ploterp = figure('name', 'erp', ...
                     'color', 'w');

    wt = 0.4;
    ht = 0.28;
    gp = 0.08;
    lft = (1-wt*2-gp)/2;
    btm = (1-ht*2-gp)/2;

    % neutral single trials
    left_top = [lft, btm+ht+gp, wt, ht];
    subplot(2,2,1,'parent',ploterp,...
            'position', left_top);
    plot(times, data_neu, 'g', 'LineWidth', 0.5);
    set(gca, 'YDir', 'reverse');
    xlim([start, ending]);
    ylim([-YLIM, YLIM]);
    ylabel('Amptitude (\muV)');
    hold on;
    plot(times, data_neu_avg, 'k', 'LineWidth', 1.5);
    plot([0,0], [-YLIM,YLIM], ':k', 'LineWidth', 0.5);
    plot([start, ending], [0, 0], ':k', 'LineWidth', 0.5);
    plot([start, ending], [20, 20], ':k', 'LineWidth', 0.5);
    plot([start, ending], [-10, -10], ':k', 'LineWidth', 0.5);
    hold off;
    title('Neutral');


    % negative single trials
    right_top = [lft+wt+gp, btm+ht+gp, wt, ht];
    subplot(2,2,2,'parent',ploterp,...
            'position', right_top);
    plot(times, data_neg, 'g', 'LineWidth', 0.5);
    set(gca, 'YDir', 'reverse');
    xlim([start, ending]);
    ylim([-YLIM, YLIM]);
    hold on;
    plot(times, data_neg_avg, 'b', 'LineWidth', 1.5);
    plot([0,0], [-YLIM,YLIM], ':k', 'LineWidth', 0.5);
    plot([start, ending], [0, 0], ':k', 'LineWidth', 0.5);
    plot([start, ending], [20, 20], ':k', 'LineWidth', 0.5);
    plot([start, ending], [-10, -10], ':k', 'LineWidth', 0.5);
    hold off;
    title('Negative');


    % neutral & negative average
    left_bottm = [lft, btm, wt, ht];
    subplot(2,2,3,'parent',ploterp,...
            'position', left_bottm);
    plot(times, data_neu_avg, 'k', 'LineWidth', 1.5);
    set(gca, 'YDir', 'reverse');
    xlim([start, ending]);
    ylim([-10, 20]);
    xlabel('Time (ms)');
    ylabel('Amptitude (\muV)');
    hold on;
    plot(times, data_neg_avg, 'b', 'LineWidth', 1.5);
    plot(times, data_diff, 'r', 'LineWidth', 1.5);
    plot([0,0], [-10,20], ':k', 'LineWidth', 0.5);
    plot([start, ending], [0, 0], ':k', 'LineWidth', 0.5);
    hold off;
    title('Negative, Neutral, & Difference');
    % hlen = legend(gca, {'Neutral', 'Negative', 'Difference'},...
    %               'Location', 'SouthEast');
    % set(hlen, 'Box', 'off');


    % neutral & negative average 600ms
    right_bottom = [lft+wt+gp, btm, wt, ht];
    hsubp = subplot(2,2,4,'parent', ploterp, ...
                    'position', right_bottom);
    plot(times, data_neu_avg, 'k', 'LineWidth', 1.5);
    set(gca, 'YDir', 'reverse');
    xlim([0, 600]);
    ylim([-10, 20]);
    xlabel('Time (ms)');
    hold on;
    plot(times, data_neg_avg, 'b', 'LineWidth', 1.5);
    plot(times, data_diff, 'r', 'LineWidth', 1.5);
    plot([0,0], [-10,20], ':k', 'LineWidth', 0.5);
    plot([0, 600], [0, 0], ':k', 'LineWidth', 0.5);
    plot([0, 600], [5, 5], ':k', 'LineWidth', 0.5);
    plot([0, 600], [-5, -5], ':k', 'LineWidth', 0.5);
    hold off;
    title('Negative, Neutral, & Difference (-200~600ms)');
    len_pos = [lft+wt+gp/2-wt/4, btm/3, wt/2, btm/3];
    hlen = legend(gca, {'Neutral', 'Negative', 'Difference'},...
                  'position', len_pos);
    set(hlen, 'Box', 'off');
    print(ploterp, fig_fullpath, '-dpdf', '-r300');

    % good_or_bad_v = [];
    % while isempty(good_or_bad_v)
    %     good_or_bad_v = input('Good or Bad? 1/0:');
    %     if isempty(good_or_bad_v)
    %         disp('Please input 1 or 0');
    %         good_or_bad_v = [];
    %     end
    % end

    % how_good_v = [];
    % while isempty(how_good_v)
    %     how_good_v = input('How Good Is It? 1-5:');
    %     if ~isnumeric(how_good_v)
    %         disp('The value must be a number');
    %         how_good_v = [];
    %     elseif how_good_v < 0 || how_good_v > 5
    %         disp('The value must be a number between 0 ~ 5');
    %         how_good_v = [];
    %     end
    % end

    % fprintf(fid, sprintf('%i,', good_or_bad_v));
    % if i==nf
    %     fprintf(fid, sprintf('%i', how_good_v));
    % else
    %     fprintf(fid, sprintf('%i\n', how_good_v));
    % end
    if ishandle(ploterp)
        close(ploterp);
    end
end
% end
fclose('all');
