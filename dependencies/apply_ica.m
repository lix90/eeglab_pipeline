function EEG = apply_ica(EEG, ica_mat, is_bad_ic)
% Apply icaweights & icasphere, & also bad components


if ~exist('is_bad_ic')
    is_bad_ic = false;
else
    if isfield(ica_mat, 'reject') && isfield(ica_mat.reject, 'gcompreject')
        disp(['Warning: There is no gcompreject field. It is not going to apply ' ...
              'bad components into EEG.']);
        is_bad_ic = false;
    end
end


if isempty(ica_mat.icaweights) || isempty(ica_mat.icasphere)
    disp('Error: No icaweights and icasphere.');
    return;
end

if is_bad_ic
    EEG.reject.gcompreject = ica_mat.reject.gcompreject;
end

EEG.icawinv = ica_mat.icawinv;
EEG.icasphere = ica_mat.icasphere;
EEG.icaweights = ica_mat.icaweights;

EEG = eeg_checkset(EEG, 'ica');

