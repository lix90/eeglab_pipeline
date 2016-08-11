function EEG = rej_badchan(EEG, flatline, mincorr, linenoisy)

% flatline: 5s
% minCorr: 0.4
% lineNoisy: 4

% remove bad channels
arg_flatline = flatline; % default is 5
arg_highpass = 'off';
arg_channel = mincorr; % default is 0.85
arg_noisy = linenoisy;
arg_burst = 'off';
arg_window = 'off';
EEG = clean_rawdata(EEG, ...
                    arg_flatline, ...
                    arg_highpass, ...
                    arg_channel, ...
                    arg_noisy, ...
                    arg_burst, ...
                    arg_window);

% % remove flat-line channels
% if ~strcmp(flatline_crit,'off')
%     EEG = clean_flatlines(EEG, flatline_crit);
% end

% % remove noisy channels by correlation and line-noise thresholds
% if ~strcmp(chancorr_crit,'off') || ~strcmp(line_crit,'off') %#ok<NODEF>
%     if strcmp(chancorr_crit,'off')
%         chancorr_crit = 0; end
%     if strcmp(line_crit,'off')
%         line_crit = 100; end
%     try
%         EEG = clean_channels(EEG,chancorr_crit,line_crit,[],channel_crit_maxbad_time);
%     catch e
%         if strcmp(e.identifier,'clean_channels:bad_chanlocs')
%             disp('Your dataset appears to lack correct channel locations; using a location-free channel cleaning method.');
%             EEG = clean_channels_nolocs(EEG,nolocs_channel_crit,nolocs_channel_crit_excluded,[],channel_crit_maxbad_time);
%         else
%             rethrow(e);
%         end
%     end
% end
