% merge components in one set in cluster: only applies to export cluster ersp data NOW
function output = mergeComponentsInOneSubjOneClust(dataIn, setInds)

NDIMS = ndims(dataIn{1});
if NDIMS == 3 % ERSP
	output = cell(size(dataIn));
	for iCell = 1:length(setInds(:))
	    % scan subjects
	    uniqueSubj = unique(setInds{iCell});
	    for iSubj = 1:length(uniqueSubj)
	        subjInd    = setInds{iCell} == uniqueSubj(iSubj);
	        output{iCell}(:,:,iSubj) = squeeze(mean(dataIn{iCell}(:,:,subjInd), 3));
	    end
	end 
elseif NDIMS == 2 % ERP
	output = cell(size(dataIn));
	for iCell = 1:length(setInds(:))
	    % scan subjects
	    uniqueSubj = unique(setInds{iCell});
	    for iSubj = 1:length(uniqueSubj)
	        subjInd    = setInds{iCell} == uniqueSubj(iSubj);
	        output{iCell}(:,iSubj) = squeeze(mean(dataIn{iCell}(:,subjInd), 2));
	    end
	end 
end