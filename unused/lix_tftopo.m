% lix_tftopo - use eeglab topoplot function to plot topographical image
% 
% usage:
%               lix_tftopo(tfdata, times, freqs, chanlocs, fband, ...
%                                                       tband, clim, mark)
% Inputs:
%
% tfdata    = time frequency data with 4 dims: freq*time*channel*subject
% times     = time vector
% freqs     = freq vector
% chanlocs  = struct
% fband     = string
% tband     = scalar or [lo hi]
% clim      = [lo hi] colormap limits
% mark      = {cell array} marked channel vector

function lix_tftopo(tfdata, times, freqs, chanlocs, varargin)

try
    h = [];
    % check inputs
    if nargin < 8
        help lix_tftopo;
        error('not enough parameters');
    end
    bandstr = varargin{1};
    switch bandstr
        case 'alpha'
            band = [8 12];
        case 'delta'
            band = [4 7];
        case 'alpha1'
            band = [8 10];
        case 'alpha2'
            band = [10 12];
        case 'beta'
            band = [13 30];
    end
    
    time = varargin{2};
    clim = varargin{3};
    chan = varargin{4};
    numt = numel(time);
    % find time & frequency index
    tmpF = dsearchn(freqs', band');
    tmpT = dsearchn(times', time');
    switch numt
        case 2
            f1 = tmpF(1); f2 = tmpF(2); 
            t1 = tmpT(1); t2 = tmpT(2); 
        case 1
            f1 = tmpF(1); f2 = tmpF(1);
            t1 = tmpT(1); t2 = tmpT(1); 
    end
    % find channel index
    markchans = lix_chanind(chan, chanlocs);
    % subset data
    data = tfdata(f1:f2, t1:t2, :, :);
    data = squeeze(mean(mean(mean(data,1),2),4));
    % allocate maker style
    emarker = {'.', 'k', 4, 1};
    emarker2 = {markchans,'o','r',8,1};
    % plot
    topoplot(data, chanlocs, ...
        'maplimits', clim, ...
        'emarker', emarker, ...
        'emarker2', emarker2, ...
        'whitebk', 'on', ...
        'plotrad', 0.54, ...
        'headrad', 0.45, ...
        'intsquare', 'off', ...
        'shading', 'flat');
%     set(gcf, 'color', 'w');
    switch numt
        case 2
            titlename = ['time range: ', int2str(time(1)), 'ms - ', ...
                int2str(time(2)), 'ms of ', bandstr];
        case 1
            titlename = ['time range: ', int2str(time(1)), ...
                'ms of ', bandstr];
    end
    title(titlename, ...
          'fontweight', 'bold', ...
          'fontsize', 10, ...
          'fontname', 'times', ...
          'fontangle', 'italic');
    % change default plot settings
    set(gca, 'fontname', 'times');
    hchildren = get(gca, 'children');
    set(hchildren(1), 'visible', 'on', ...
                      'MarkerEdgeColor', 'k', ...
                      'MarkerFaceColor', 'none', ...
                      'LineWidth', 2);
catch err
    lix_disperr(err);
end