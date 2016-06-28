clear, clc, close all
% pipeline for preprocessing ica

baseDir = '';
inputTag = '';
outputTag = '';
fileExtension = 'set';
prefixPosition = 1;
offlineRef = {'TP9', 'TP10'};
hiPassHz = 1; % for ica

%%---------

inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

setEEGLAB;

for i = 1:numel(id)
    
    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end
    
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    
    % clean data
    % if ~exist('maxbad','var') || isempty(maxbad) maxbad = 0.15; end
    % if ~exist('stddev','var') || isempty(stddev) stddev = 3; end

    % first determine the breakage mask
    %[dummy,sample_mask] = clean_windows(signal,maxbad);
    % instead we use Nima's amplitude-based
    % isFrameAnArtifact = eeg_clean_data_by_probability_robust(EEG, false);
    % sample_mask = ~isFrameAnArtifact;

    % % generate a repaired version of the data set
    % repaired = repair_bursts(EEG, stddev);

    % % substitute repaired content into the original signal
    % EEG.data(:,~sample_mask) = repaired.data(:,~sample_mask);
    % EEG = eeg_checkset(EEG);
    
    % high pass fitering if necessary
    if exist('hiPassHz', 'var') && ~isempty(hiPassHz)
        cleanEEG = pop_eegfiltnew(EEG, hiPassHz, 0);
    else
        cleanEEG = EEG;
    end
    
    [isFrameAnArtifact rejectionWindows] = eeg_clean_data_by_probability_robust(cleanEEG, false);
		if isempty(cleanEEG.icachansind) % making sure that EEG.icachansind which contains channels to be used for ICA is not empty
			cleanEEG.icachansind  =1:size(cleanEEG.data, 1);
		end

		% assuming your data is 2D, and not epoched
		cleanData = cleanEEG.data(cleanEEG.icachansind, ~isFrameAnArtifact);

		% do your ICA here and get wts and sph matrices, for example
		% [wts sph] = binica(cleanData, ...);

    nChan = size(cleanData, 1);
    if strcmp(offlineRef, 'average')
        [wts, sph] = binica(cleanData, 'extended', 1, 'pca', nChan-1);
    else
        [wts, sph] = binica(cleanData, 'extended', 1);
    end
    
		iWts = pinv(wts*sph);
		scaling = repmat(sqrt(mean(iWts.^2))', [1 size(wts,2)]);
		wts = wts.*scaling;

		EEG.icawinv = pinv(wts*sph);
		EEG.icasphere = sph;
		EEG.icaweights = wts;
		EEG.icaact = [];
		EEG = eeg_checkset(EEG);
    
    % save dataset
    % parsave(outputFilenameFull, ica);
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    EEG = []; ALLEEG = []; CURRENTSET = [];
    
end
