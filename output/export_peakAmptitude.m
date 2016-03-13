%% script for exporting peak amplitude

%% parameters
chanLabels = {'FCz'}; %channel labels of interest
timeRange = [200 300]; % time range of erp component
outDir = ''; % output directory
g1 = {}; % marks of group one
g2 = {}; % marks of group two

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

% time index
t = dsearchn(erpTimes', timeRange');
t1 = t(1); t2 = t(2);

%% start output peak
if strcmp(pairing1, 'on') % var1 is within var
    for iVar2 = 1:numel(var2) % loop through group
        % prepare subject mark
        eval('gSubj = g', int2str(iVar2), ';');
        % prepare condition string
        conds = strcat(var2{iVar2}, '_', var1);
        conStr = 'subject';
        for ii = 1:numel(var1)
            conStr = [conStr, ',', conds{ii}];
        end
        % prepare output name
        tStr = strcat('t', num2str(timeRange(1)), 'to', num2str(timeRange(2)));
        cStr = [];
        if numel(chanLabels)==1
           cStr = [cStr, chanLabels{:}]; 
        elseif numel(chanLabels)>1
           for iCstr = 1:numel(chanLabels)
               if iCstr == 1
                   cStr = chanLabels{iCstr};
               else iCstr>1
                   cStr = [cStr, '_', chanLabels{iCstr}];
               end
           end
        end
        ampName = strcat('peakAmplitude_', cStr,'_', tStr, '_group', var2{iVar2}, '.csv');
        ampOutName = fullfile(outDir, ampName);
        ampFID = fopen(ampOutName, 'w');
        fprintf(ampFID, [conStr, '\n']);
        for iSubj = 1:numel(gSubj) % loop through subj
            fprintf(ampFID, [gSubj{iSubj}, ',']); % write subj name
            for iVar1 = 1:numel(var1) % loop through within var
                erpNow = erpData{iVar1, iVar2};
                tmpErp = erpNow(t1:t2, iSubj);
                amp = mean(tmpErp);
                if iVar1 < numel(var1)
                    fprintf(ampFID, [num2str(amp), ',']);
                elseif iVar1 == numel(var1)
                    fprintf(ampFID, [num2str(amp), '\n']);
                end
            end % within var end
        end % subj loop end
            fclose(ampFID);
    end % group end 
        
elseif strcmp(pairing2, 'on') % var2 is within var
    for iVar1 = 1:numel(var1)
        % prepare subject mark
        % prepare subject mark
        eval('gSubj = g', int2str(iVar1), ';');
        % prepare condition string
        conds = strcat(var1{iVar1}, '_', var2);
        conStr = 'subject';
        for ii = 1:numel(var2)
            conStr = [conStr, ',', conds{ii}];
        end
        % prepare output name
        ampName = strcat('peakAmplitude_group_', var1{iVar1}, '.csv');
        ampOutName = fullfile(outDir, ampName);
        ampFID = fopen(ampOutName, 'w'); % write file
        fprintf(ampFID, [conStr, '\n']); % write headers
        for iSubj = 1:nSubj 
            fprintf(ampFID, [gSubj{iSubj}, ',']);
            for iVar2 = 1:numel(var2)
                erpNow = erpData{iVar1, iVar2};
                tmpErp = erpNow(t1:t2, iSubj);
                amp = mean(tmpErp);
                if iVar2 < numel(var2)
                    fprintf(ampFID, [num2str(amp), ',']);
                elseif iVar2 == numel(var2)
                    fprintf(ampFID, [num2str(amp), '\n']);
                end
            end % within var end
        end % subj loop end
        fclose(ampFID);
    end % group end
end
% done
disp('DONE!')