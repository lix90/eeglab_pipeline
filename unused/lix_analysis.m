clear all; close all; clc;
cd 'E:\data_2015_07'
load chanlocs
load painsub
try
    range = [-200 1000 3 30];
    chan = {'fcz'};
    [t, f] = lix_tfind(T, F, range);
    c = lix_chanind(chan, chanlocs);
    posi = squeeze(pain_posi(f(1):f(2), t(1):t(2), c, :));
    nega = squeeze(pain_nega(f(1):f(2), t(1):t(2), c, :));
    neut = squeeze(pain_neut(f(1):f(2), t(1):t(2), c, :));
    data = {posi, nega, neut};
    [Fvals, Pvals, P_fdr, P_masked] = lix_1anova_fdr(data, 'perm', 2000);
    figure('color', 'w');
    lix_tfplot(Pvals<0.05, T, F, chanlocs, [-200 1000 3 30 -1 1], chan, 'native');
    %     print(gcf,'-depsc', ['.\ica2\eps\sub\p-', chan, '-0.05.eps']);
catch err
    lix_disperr(err);
end

%%
clear all; close all; clc;
cd 'E:\data_2015_07'
load chanlocs
load painsub
chan = {'all channels'};
hf = figure('color', 'w');
subplot(1,3,1,'parent', hf);
lix_tfplot(pain_posi, T, F, chanlocs, [-200 1000 3 30 -1 1], chan,'native');
subplot(1,3,2,'parent', hf);
lix_tfplot(pain_nega, T, F, chanlocs, [-200 1000 3 30 -1 1], chan,'native');
subplot(1,3,3,'parent', hf);
lix_tfplot(pain_neut, T, F, chanlocs, [-200 1000 3 30 -1 1], chan,'native');

%%
clear all; close all; clc;
cd 'E:\data_2015_07'
load chanlocs
load painsub
%%
tband = {[0 100],[100 200],[200 300], [300 400], [400 500],...
    [500, 600], [600, 700], [700 800], [800 900], [900 1000]};
fband = 'alpha';
clim = [-1 1];
mark = {'c1'};
for i = 1:length(tband)
    figure(i);
    subplot_tight(1,3,1,([0.01 0.01]));
    lix_tftopo(pain_posi, T, F, chanlocs, fband, tband{i}, clim, mark);
    subplot_tight(1,3,2,([0.01 0.01]));
    lix_tftopo(pain_nega, T, F, chanlocs, fband, tband{i}, clim, mark);
    subplot_tight(1,3,3,([0.01 0.01]));
    lix_tftopo(pain_neut, T, F, chanlocs, fband, tband{i}, clim, mark);
    set(gcf, 'color', 'w');
    print(gcf, '-depsc', [int2str(tband{i}(1)), '.eps']);
    close;
end
