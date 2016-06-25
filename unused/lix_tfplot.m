% lix_tfplot() - using eeglab tftopo function to plot time-freqeuncy image
%
% Usage:
%			>> lix_tfplot(tfdata, times, freqs, chanlocs, ...
%                                       limits, chan, logfreq);
% Inputs:
% 	tfdata		= time frequency data with 4 dimensions
% 	times 		= time vector
% 	freqs		= freq vector
% 	chanlocs	= channel location structure
% 	limits		= [minms maxms minhz maxhz mincaxis maxcaxis]
% 	chan 		= interested channel name
%   logfreq     = ['on'|'off'|'native']


function lix_tfplot(tfdata, times, freqs, chanlocs, varargin)

try
    % check inputs
    if nargin < 7
        error('not enough parameters');
        help lix_tfplot;
    end
    
    if isempty(varargin{1});
        warning('use default limits of ERSP image');
        limits = [-200 1000 3 30 -2 2];
    else
        limits = varargin{1};
    end
    chan    = varargin{2};
    logfreq = varargin{3};
    % get time & frequency index
    %     [t,f] = lix_tfind(times, freqs, limits(1:4));
    % subset time & frequency vector
    %     times = times(t(1):t(2));
    %     freqs = freqs(f(1):f(2));
    % get channel index
    if strcmpi(chan, 'all channels')
        c = 1:length({chanlocs.labels});
    else
        c = lix_chanind(chan, chanlocs);
    end
    % compute average of data
    if ndims(tfdata) > 2
        if numel(c)>1
            data = squeeze(mean(mean(tfdata(:,:,c,:), 3),4));
        else
            data = squeeze(mean(tfdata(:,:,c,:), 4));
        end
    else
        data = tfdata;
        [t,f] = lix_tfind(times, freqs, limits(1:4));
        times = times(t(1):t(2));
        freqs = freqs(f(1):f(2));
    end
    % figure('name', 'tfplot', 'color', 'w');
    tftopo(data, times, freqs, ...
        'limits', limits, ...
        'logfreq', logfreq);
    % plot parameters
    title(chan, 'fontname', 'times', 'fontsize', 12);
    if numel(chan)>1
        title('mean of channels', 'fontname', 'times', 'fontsize', 12);
    end
    % change default plot parameters
    hchildren = get(gca, 'children');
    set(hchildren(1), 'linewidth', 1);
    set(gca, 'fontname', 'times', 'fontsize', 10);
    set(get(gca, 'xlabel'), 'fontname', 'times', 'fontangle', 'italic');
    set(get(gca, 'ylabel'), 'fontname', 'times', 'fontangle', 'italic');
catch err
    lix_disperr(err);
end

