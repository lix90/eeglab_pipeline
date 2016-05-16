function EEG = lix_amica(EEG, varargin)

% In:
% 	'pca': [] (default)
%	'modnum': 1 (default)
% 	'outdir': [] (default)

for i = 1:2:length(varargin) % for each Keyword
      Keyword = varargin{i};
      Value = varargin{i+1};
    if ~isstr(Keyword)
         fprintf('runamica(): keywords must be strings')
         return
    end
    Keyword = lower(Keyword); % convert upper or mixed case to lower

    if strcmp(Keyword,'pca')
        if numel(Value)>1 && ~isnumeric(Value)
            fprintf('runamica(): pca must be a positive number');
            return
        else
            pca = Value;
        end
    elseif strcmp(Keyword, 'modnum')
     	if numel(Value)>1 && ~isnumeric(Value)
     		fprintf('lix_amica(): modnum must be a scalar')
     		return
     	else
     		modnum = Value;
        end
    elseif strcmp(Keyword, 'outdir')
     	if ~ischar(Value)
            fprintf('runamica(): outdir must be a string');
            return
        else
            outdir = Value;
        end
    end
end


icadata = EEG.data;
if nargin==1
	[EEG.icaweights, EEG.icasphere, mods] = runamica12(icadata(:,:));
elseif ~isempty(modnum) && ~isempty(outdir) && ~isempty(pca)
	[EEG.icaweights, EEG.icasphere, mods] = runamica12(icadata(:,:), 'pcakeep', pca, 'modnum', modnum, 'outdir', outdir);
elseif isempty(modnum)
	[EEG.icaweights, EEG.icasphere, mods] = runamica12(icadata(:,:), 'pcakeep', pca, 'outdir', outdir);
else
	fprint('lix_amica(): please reset parameters')
end

% EEG.icasphere = mods.S(1:mods.num_pcs,:);
% EEG.icaweights = mods.W(:,:,modnum);
EEG.icawinv = mods.A(:,:,modnum);
EEG.icachansind = 1:EEG.nbchan;
EEG = eeg_checkset(EEG);