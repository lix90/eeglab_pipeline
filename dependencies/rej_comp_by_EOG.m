function EEG = rej_comp_by_EOG(EEG, veo, heo)

if ~exist('SASICA')==2
    disp('Error: no SASICA plugin installed in EEGLAB.');
    return;
end

labels = {EEG.chanlocs.labels};
if ~exist('veo', 'var')
    veo = labels(pick_channel_types(EEG, {'veo'}));
end

if ~exist('heo', 'var')
    heo = labels(pick_channel_types(EEG, {'heo'}));
end

cfg = SASICA('getdefs');

cfg.trialfoc.enable = 0;
cfg.MARA.enable = 0;
cfg.chancorr.enable = 0;
cfg.resvar.enbale = 0;
cfg.SNR.enable = 0;
cfg.ADJUST.enable = 0;
cfg.FASTER.enable = 0;

% EOG correlation
cfg.EOGcorr.enable = 1;
cfg.EOGcorr.Veogchannames = veo;
cfg.EOGcorr.Heogchannames = heo;
% autocorrelation
cfg.autocorr.enable = 1;
% focal components
cfg.focalcomp.enable = 1;
% no plot
cfg.opts.noplot = 1;

EEG = eeg_SASICA(EEG, cfg);

tmp = EEG.reject.SASICA;
EEG.reject.gcompreject = logical(tmp.icarejautocorr + ...
                                 tmp.icarejfocalcomp + ...
                                 tmp.icarejchancorr);
