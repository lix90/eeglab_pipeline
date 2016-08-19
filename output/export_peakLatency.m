%% script for exporting peak latency

%% parameters
chanLabels = {'FCz'}; %channel labels of interest
timeRange = [200 400]; % time range of erp component
compLabel = 'P300'; 
outDir = ''; % output directory
g1 = {};
g2 = {};

%% compute erp
[STUDY, erpData, erpTimes] = std_erpplot(STUDY, ALLEEG, ...
                                         'channels', chanLabels, ...
                                         'noplot', 'on', ...
                                         'averagechan', 'on');
subj = STUDY.subject;
var1 = STUDY.design(1).variable(1).value;
var2 = STUDY.design(1).variable(2).value;
pairing1 = STUDY.design(1).variable(1).pairing;
pairing2 = STUDY.design(1).variable(2).pairing;
nSubj = numel(subj);

% time index
t = dsearchn(erpTimes', timeRange');
t1 = t(1); t2 = t(2);
samples = t1:t2;

tStr = strcat('t', num2str(timeRange(1)), 'to', num2str(timeRange(2)));
peakDirection = compLabel(1);

% start output peak
if strcmp(pairing1, 'on') % var1 is within var
    for iVar2 = 1:numel(var2) % loop through group
        % prepare subject mark
        eval('gSubj = g', int2str(iVar2), ';');
        % prepare condition string
        conds = strcat(var2{iVar2}, '_', var1);
        conStr = 'subject';
        for ii = 1:numel(var1)
            pkStr = [conds{ii}, '_Peak'];
            plStr = [conds{ii}, '_Latency'];
            conStr = [conStr, ',', pkStr, ',', plStr];
        end
        % prepare output name
        pkName = strcat('peakLatency_', compLabel, '_', tStr,  '_group_', var2{iVar2}, '.csv');
        pkOutName = fullfile(outDir, pkName);
        pkFID = fopen(pkOutName, 'w'); % write file
        fprintf(pkFID, [conStr, '\n']); % write headers
        for iSubj = 1:numel(gSubj) % loop through subj
            fprintf(pkFID, [gSubj{iSubj}, ',']); % write subj name
            for iVar1 = 1:numel(var1) % loop through within var
                erpNow = erpData{iVar1, iVar2};
                tmpErp = erpNow(t1:t2, iSubj);
                if strcmpi(peakDirection, 'p') % positive component
                    p = max(tmpErp);
                    pl = erpTimes(samples(tmpErp==p));
                elseif strcmpi(peakDirection, 'n'); % negative component
                    p = min(tmpErp);
                    pl = erpTimes(samples(tmpErp==p));
                end
                % if pl == erpTimes(t1) || pl == erpTimes(t2)
                %     p = 0;
                %     pl = 0;
                % end
                if iVar1 < numel(var1)
                    fprintf(pkFID, [num2str(p), ',' num2str(pl), ',']);
                elseif iVar1 == numel(var1)
                    fprintf(pkFID, [num2str(p), ',' num2str(pl), '\n']);
                end
            end % within var end
        end % subj loop end
            fclose(pkFID);
    end % subj end 
elseif strcmp(pairing2, 'on') % var2 is within var

    for iVar1 = 1:numel(var1)
        % prepare subject mark
        eval('gSubj = g', int2str(iVar2), ';');
        % prepare condition string
        conds = strcat(var1{iVar1}, '_', var2);
        conStr = 'subject';
        for ii = 1:numel(var1)
            pkStr = [conds{ii}, '_Peak'];
            plStr = [conds{ii}, '_Latency'];
            conStr = [conStr, ',', pkStr, ',', plStr];
        end
        % prepare output name
        pkName = strcat('peakLatency_', timeLabel, '_', tStr,  '_group_', var2{iVar2}, '.csv');
        pkOutName = fullfile(outDir, name);
        pkFID = fopen(pkOutName, 'w'); % write file
        fprintf(pkFID, [conStr, '\n']); % write headers
        for iSubj = 1:numel(gSubj)
            fprintf(pkFID, [gSubj{iSubj}, ',']);
            for iVar2 = 1:numel(var2)
                erpNow = erpData{iVar1, iVar2};
                tmpErp = erpNow(t1:t2, iSubj);
                if strcmpi(peakDirection, 'p') % positive component
                    p = max(tmpErp);
                    pl = erpTimes(samples(tmpErp==p));
                elseif strcmpi(peakDirection, 'n'); % negative component
                    p = min(tmpErp);
                    pl = erpTimes(samples(tmpErp==p));
                end
                % if pl == erpTimes(t1) || pl == erpTimes(t2)
                %     p = 0;
                %     pl = 0;
                % end
                if iVar1 < numel(var1)
                    fprintf(pkFID, [num2str(p), ',' num2str(pl), ',']);
                elseif iVar1 == numel(var1)
                    fprintf(pkFID, [num2str(p), ',' num2str(pl), '\n']);
                end
            end % within var end
        end % subj loop end
            fclose(pkFID);
    end % subj end
end
% done
disp('DONE!')
