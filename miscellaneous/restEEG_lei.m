%% plotting
elec_dir = '';
elec_fn = '';

load(fullfile(elec_dir, elec_fn));

scalp_dir = '';
scalp_fn = '';

load(fullfile(scalp_dir, scalp_fn));

rhythmName = {'delta (2-4 Hz)','theta (4-8 Hz)', ...
              'alpha1 (8-10 Hz)', 'alpha2 (11-13 Hz)', ...
              'beta1 (13-20 Hz)','beta2 (20-30 Hz)', ...
              'gamma (30-40 Hz)'};

groupScalp1=mean(rhythmScalpAll(:,:,group1),3);% 61 X 7
groupScalp2=mean(rhythmScalpAll(:,:,group2),3);% 61 X 7


figure(1)
for i=1:7
    ma=max([groupScalp1(:,i)' groupScalp2(:,i)']);
    subplot(3,7,i)
    topoplot(groupScalp1(:,i),chanlocs,'maplimits',ma*[-1 1]);
    title(rhythmName{i})
    subplot(3,7,i+7)
    topoplot(groupScalp2(:,i),chanlocs,'maplimits',ma*[-1 1]);
    subplot(3,7,i+14)
    topoplot(groupScalp2(:,i)-groupScalp1(:,i),chanlocs);
end



%% cortex
groupCortex1=mean(rhythmCortexAll(:,:,group1),3);% 8196 X 7
groupCortex2=mean(rhythmCortexAll(:,:,group2),3);% 8196 X 

cortexDir = '';
cortexName = 'mesh8196.mat';

load(fullfile(cortexDir, cortexName));
load(fullfile(cortexDir, cortexName));

for i=1:7
    ShowP = groupCortex1(:,i);
    ShowP = abs(ShowP);
    ShowP = ShowP-min(ShowP);
    ShowP = ShowP./max(ShowP);
    figure(i+10)
    lei_step2_NESOI_show(mesh8196,ShowP);
    title(rhythmName{i})
    
    ShowP = groupCortex2(:,i);
    ShowP = abs(ShowP);
    ShowP = ShowP-min(ShowP);
    ShowP = ShowP./max(ShowP);
    figure(i+20)
    lei_step2_NESOI_show(mesh8196,ShowP);
    title(rhythmName{i})
end

%% network

groupNetwork1m=mean(rhythmNetworkAll(:,:,group1),3);% 8 X 7
groupNetwork2m=mean(rhythmNetworkAll(:,:,group2),3);% 8 X 7
groupNetwork1s=std(rhythmNetworkAll(:,:,group1),0,3)./sqrt(16);% 8 X 7
groupNetwork2s=std(rhythmNetworkAll(:,:,group2),0,3)./sqrt(17);% 8 X 7

figure(3)
RSNname={'Visual','Somatomotor','Dorsal Attention',...
         'Ventral Attention','Limbic','Frontopariental',...
         'Default','Deep Structure'};
for i=1:8
    subplot(2,4,i)
    errorbar(groupNetwork1m(:,i),groupNetwork1s(:,i),'-^g');
    hold on;
    errorbar(groupNetwork2m(:,i),groupNetwork2s(:,i),'-vr');
    datarange = [groupNetwork1m(:,i) + groupNetwork1s(:,i); ... 
                 groupNetwork2m(:,i) + groupNetwork2s(:,i)];
    ylim([0, ceil(max(datarange)) + 1]);
    xlim([0.5, 7.5]);
    title(RSNname{i});
    set(gca,'XTick',[1:7])
    set(gca,'XTickLabel',{'del','the','al1','al2','be1','be2','ga'})
end

