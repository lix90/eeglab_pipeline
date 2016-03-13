function output = export_ersp_wave(DataIn, erspFreqs, freqRange)

output = cell(size(DataIn));

if  strcmp(class(freqRange), 'double') || strcmp(class(freqRange), 'single')
	f = get_ind(erspFreqs, freqRange);
	Ncell = numel(DataIn);
	for iCell = 1:Ncell
		tmp = DataIn{iCell};
		output{iCell} = squeeze(mean(tmp(f(1):f(2),:,:), 1));
	end
elseif  strcmp(class(freqRange), 'cell')
	Nrange = numel(freqRange);
	Ncell = numel(DataIn);	
	[x, y, z] = size(DataIn{1});
	tmpOneCell = zeros(Nrange, y, z);
	for iCell = 1:Ncell
		tmp = DataIn{iCell};
		for iRange = 1:Nrange
			f = get_ind(erspFreqs, freqRange{iRange});
			tmpOneCell(iRange,:,:) = squeeze(mean(tmp(f(1):f(2),:,:), 1));
		end
		output{iCell} = tmpOneCell;
	end
end

function ind = get_ind(vector, range)

if size(range, 2)~=1; range=range'; end
if size(vector, 2)~=1; vector=vector'; end
ind = dsearchn(vector, range);