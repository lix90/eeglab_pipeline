function ica = lix_ica(EEG, icatype);

ica = struct();

% get rank of data
r = rank(double(EEG.data(:,:,:));

switch icatype
case 'infomax'
	EEG = pop_runica(EEG,'extended',1, 'pca', r, 'interupt', 'off');
case 'amica'
	EEG = lix_amica(EEG, 'pca', r, 'modnum', modnum, 'outdir', ouDIR);
end
EEG = eeg_checkset(EEG);

ica.icaweights = EEG.icaweights;
ica.icasphere = EEG.icasphere;
ica.icawinv = EEG.icawinv;
ica.icachansind = EEG.icachansind;