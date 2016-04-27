%% align electrode
elec_name = 'standard_1005.elc';
elec = ft_read_sens(elec_name);

vol_name = 'standard_bem.mat';
load(vol_name);

%% plot
figure;
ft_plot_mesh(vol.bnd(1),'edgecolor','none',...
             'facealpha',0.8,'facecolor',[0.6, 0.6, 0.8]);
hold on;
ft_plot_sens(elec, 'style', 'sk');


