function EEG = rej_SASICA(EEG, EOG, is_rej)
% EOG: {'VEO', 'HEO'}

if ~exist('SASICA')==2
    disp('Error: no SASICA plugin installed in EEGLAB.');
    return;
end

if ~exist('is_rej', 'var')
    is_rej = false;
end

if ~exist('EOG', 'var')
    eog_ind = pick_channel_types(EEG, 'eog');
    chan_labels = {EEG.chanlocs.labels};
    EOG = chan_labels(eog_ind);
end

[v, vi, h, hi] = identify_eog(EOG);

cfg = SASICA('getdefs');
if ndims(EEG.data)==2
    cfg.trialfoc.enable = 0;
elseif ndims(EEG.data)==3
    cfg.trialfoc.enable = 1;
end

if isempty(EOG)
    cfg.EOGcorr.enable = 0;
    cfg.FASTER.enable = 0;
elseif iscellstr(EOG) && numel(EOG)>=2

    cfg.EOGcorr.enable = 1;
    cfg.EOGcorr.Veogchannames = v{1};
    cfg.EOGcorr.Heogchannames = h{1};

    cfg.FASTER.enable = 1;
    cfg.FASTER.blinkchanname = v{1};

end

cfg.MARA.enable = 0;
cfg.opts.noplot = 1;
cfg.chancorr.enable = 0;
cfg.resvar.enbale = 0;
cfg.SNR.enable = 0;

cfg.autocorr.enable = 1;
cfg.ADJUST.enable = 1;
cfg.focalcomp.enbale = 1;

EEG = eeg_SASICA(EEG, cfg);

rejSASICA = EEG.reject.SASICA;
rej = rejSASICA.icarejautocorr + rejSASICA.icarejfocalcomp + ...
      rejSASICA.icarejADJUST;

if cfg.trialfoc.enable
    rej = rej + rejSASICA.icarejtrialfoc;
end

if ~isempty(EOG) && isfield(rejSASICA, {'icarejFASTER', 'icarejEOGcorr'})
    rej = rej + rejSASICA.icarejFASTER + rejSASICA.icarejEOGcorr;
end

EEG.reject.gcompreject = logical(rej);
EEG = eeg_checkset(EEG);

if is_rej
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
end

function [v, vi, h, hi] = identify_eog(EOG);

ver = 'v';
hor = 'h';

eog = strrep(lower(EOG), 'eo', '');

vi = find(strfind(eog, ver));
hi = find(strfind(eog, hor));
v = EOG(vi);
h = EOG(hi);
