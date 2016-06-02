%% script for exporting ersp

%% parameters
% defining ROIs
chanLabels = {'F4'}; % channel labels of interest
timeRange = [200 600]; % time range of erp component
freqRange = [4, 7];
outDir = ''; % output directory
design = 'mixed'; % repeated or mixed
g1 = {''};
g2 = {''};

%% compute ersp
if ~exist(outDir, 'dir'); mkdir(outDir); end
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', 'channels', chanLabels,...
                 'plotmode', 'none',...
                 'subbaseline', 'off');
subj = STUDY.subject;
var1 = STUDY.design(1).variable(1).value;
var2 = STUDY.design(1).variable(2).value;
pairing1 = STUDY.design(1).variable(1).pairing;
pairing2 = STUDY.design(1).variable(2).pairing;
nSubj = numel(subj);
nChan = numel(chanLabels);
t = dsearchn(erspTimes', timeRange');
f = dsearchn(erspFreqs', freqRange');
tStr = strcat('t', num2str(timeRange(1)), '-', num2str(timeRange(2)));
fStr = strcat('f', num2str(freqRange(1)), '-', num2str(freqRange(2)));
cStr = cellstrcat(chanLabels, '-');
if numel(chanLabels)~=1
    erspData = cellfun(@(x) {squeeze(mean(x, 3))}, erspData);
end
% -------------------------------------------------
% export ersp
if strcmp(design, 'repeated')
    gSubj = subj;
    conds = var1;
    conStr = 'subject';
    for ii = 1:numel(var1)
        tmp = conds{ii};
        conStr = [conStr, ',', tmp];
    end
    fileName = strcat('ersp', cStr, '_', fStr, '_', tStr, '.csv');
    OutName = fullfile(outDir, fileName);
    FID = fopen(OutName, 'w');
    fprintf(FID, [conStr, '\n']);
    for iSubj = 1:numel(gSubj) % loop through subj
        fprintf(FID, [gSubj{iSubj}, ',']); % write subj name
        for iVar1 = 1:numel(var1) % loop through within var
            erspNow = erspData{iVar1};
            tmpErsp = erspNow(f(1):f(2), t(1):t(2), iSubj);
            tmpErsp = squeeze(mean(mean(tmpErsp, 1), 2));
            if iVar1 < numel(var1)
                fprintf(FID, [num2str(tmpErsp), ',']);
            elseif iVar1 == numel(var1)
                fprintf(FID, [num2str(tmpErsp), '\n']);
            end
        end % within var end
    end % subj loop end
        fclose(FID);
elseif strcmp(design, 'mixed')
    if strcmp(pairing1, 'on') && strcmp(pairing2, 'off') % var1 is within var
        for iVar2 = 1:numel(var2) % loop through group
                                  % prepare subject mark
            eval(['gSubj = g', int2str(iVar2), ';']);
            % prepare condition string
            conds = strcat(var2{iVar2}, '_', var1);
            conStr = 'subject';
            for ii = 1:numel(var1)
                tmp = conds{ii};
                conStr = [conStr, ',', tmp];
            end
            % prepare output name
            fileName = strcat('ersp_', cStr, '_', fStr, '_', tStr,  '_group_', var2{iVar2}, '.csv');
            OutName = fullfile(outDir, fileName);
            FID = fopen(OutName, 'w'); % write file
            fprintf(FID, [conStr, '\n']); % write headers
            for iSubj = 1:numel(gSubj) % loop through subj
                fprintf(FID, [gSubj{iSubj}, ',']); % write subj name
                for iVar1 = 1:numel(var1) % loop through within var
                    erspNow = erspData{iVar1, iVar2};
                    tmpErsp = erspNow(f(1):f(2), t(1):t(2), iSubj);
                    tmpErsp = squeeze(mean(mean(tmpErsp, 1), 2));
                    if iVar1 < numel(var1)
                        fprintf(FID, [num2str(tmpErsp), ',']);
                    elseif iVar1 == numel(var1)
                        fprintf(FID, [num2str(tmpErsp), '\n']);
                    end
                end % within var end
            end % subj loop end
                fclose(FID);
        end % subj end 
    elseif strcmp(pairing2, 'on') && strcmp(pairing1, 'off') % var2 is within var
        for iVar1 = 1:numel(var1) % loop through group
                                  % prepare subject mark
            eval(['gSubj = g', int2str(iVar1), ';']);
            % prepare condition string
            conds = strcat(var1{iVar1}, '_', var2);
            conStr = 'subject';
            for ii = 1:numel(var2)
                tmp = conds{ii};
                conStr = [conStr, ',', tmp];
            end
            % prepare output name
            fileName = strcat('ersp_', cStr, '_', fStr, '_', tStr,  '_group_', var1{iVar1}, '.csv');
            OutName = fullfile(outDir, fileName);
            FID = fopen(OutName, 'w'); % write file
            fprintf(FID, [conStr, '\n']); % write headers
            for iSubj = 1:numel(gSubj) % loop through subj
                fprintf(FID, [gSubj{iSubj}, ',']); % write subj name
                for iVar2 = 1:numel(var2) % loop through within var
                    erspNow = erspData{iVar1, iVar2};
                    tmpErsp = erspNow(f(1):f(2), t(1):t(2), iSubj);
                    tmpErsp = squeeze(mean(mean(tmpErsp, 1), 2));
                    if iVar2 < numel(var2)
                        fprintf(FID, [num2str(tmpErsp), ',']);
                    elseif iVar2 == numel(var2)
                        fprintf(FID, [num2str(tmpErsp), '\n']);
                    end
                end % within var end
            end % subj loop end
                fclose(FID);
        end % subj end 
    end
end
% done
disp('DONE!')
