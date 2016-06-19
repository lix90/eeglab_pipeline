% plot erp
fig_name = 'Central-parietal LPP';
chan_labels = {'CPz', 'CP1', 'CP2'}; % central-parietal
time_range = [-200 4000];
stat_time = [300 4000];


% study variable
conditions = STUDY.design.variable(1).value;
legend_strs = {'Reappraisal + Suppression', 'Reappraisal', ...
              'Negative Watch', 'Neutral Watch', ...
              'Suppression'};
% compute erp
[~, erp_data, erp_time] = std_erpplot(STUDY, ALLEEG, ...
                                      'channels', chan_labels,...
                                      'noplot', 'on',...
                                      'averagechan', 'on');

% average erp
erp_data_avg = cellfun(@(x) {squeeze(mean(x,2))}, erp_data);
erp_neg_neu = mean((erp_data{3}-erp_data{4}),2);
erp_rep_neg = mean((erp_data{2}-erp_data{3}),2);
erp_sup_neg = mean((erp_data{5}-erp_data{3}),2);
erp_rep_sup = mean((erp_data{1}-erp_data{3}),2);

% statistics
t1 = find(erp_time>stat_time(1), 1, 'first');
t2 = find(erp_time<stat_time(2), 1, 'last');
t_neg = mean(erp_data{3}(t1:t2,:),1);
t_neu = mean(erp_data{4}(t1:t2,:),1);
t_dual = mean(erp_data{1}(t1:t2,:),1);
t_rep = mean(erp_data{2}(t1:t2,:),1);
t_sup = mean(erp_data{5}(t1:t2,:),1);

% negative lpp > neutral lpp
[~, p_neg_neu] = ttest2(t_neg, t_neu, 0.05, 'right');
p_neg_neu

% regulation lpp < negative lpp
[~, p_dual_neg] = ttest2(t_dual, t_neg, 0.05, 'left');
p_dual_neg
[~, p_rep_neg] = ttest2(t_rep, t_neg, 0.05, 'left');
p_rep_neg
[~, p_sup_neg] = ttest2(t_sup, t_neg, 0.05, 'left');
p_sup_neg



