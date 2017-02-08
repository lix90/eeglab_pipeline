function lix_run_prep_report(params)

setDIR = params.prepDIR;
reportDIR = params.reportDIR;
if ~exist(reportDIR, 'dir'); mkdir(reportDIR); end

sumName = [reportDIR, filesep, 'summary_report.html'];
if exist(sumName, 'file'); delete(sumName); end

tmp = dir([setDIR, filesep, '*.set']);
setNameCell = {tmp.name};

for k = 1:length(setNameCell)
    
    fprintf('report (%i/%1)\n', k, length(setNameCell));

    n = length(int2str(k));
    reportName = [reportDIR, filesep, setNameCell{k}(1:n+1) '.pdf'];

    if exist(reportName, 'file'); delete(reportName); end
    fprintf('lix_run_prep_report(): report files exist\n');

    load([setDIR, filesep, setNameCell{k}], '-mat');

	publishPrepReport(EEG, ...
		sumName, ...
		reportName, ...
		1, true);
end


