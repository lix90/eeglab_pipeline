function out = lix_pwelch(EEG)
% doing spectral analysis

if ndims(EEG.data)>2
    fprintf('data must have 2 dimemsions\n');
    return
end

Window = hamming(2^9);
Nfft = 2^10; % nbt_doPeakFit uses 2^14;
Overlap = 0;
Fs = EEG.srate;

% Fixed frquency bands
FrequencyBands = [1 4]; % delta
FrequencyBands = [FrequencyBands; 4 8]; % theta
FrequencyBands = [FrequencyBands; 8 13]; % alpha
FrequencyBands = [FrequencyBands; 13 30]; % beta
FrequencyBands = [FrequencyBands; 30 45]; % gamma
FrequencyBands = [FrequencyBands; 1 45]; % broadband;
FrequencyBands = [FrequencyBands; 8 10]; % lower alpha
FrequencyBands = [FrequencyBands; 10 13];% upper alpha

out.Info = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma', ...
            'Broadband', 'lowerAlpha', 'upperAlpha'};
out.Bands = FrequencyBands;
out.Param = {'Window', 'hamming(2^9)',...
             'Nfft', Nfft,...
             'Overlap', Overlap, ...
             'Fs', Fs};
nChan = size(EEG.data,1);
psd = cell(nChan, 1);
for iChan = 1:nChan
    [p, f] = pwelch(EEG.data(iChan,:), Window, Overlap, Nfft, Fs);
    AbsolutePower = nan(size(FrequencyBands,1),1);
    RelativePower = nan(size(FrequencyBands,1),1);
    for i = 1:size(FrequencyBands,1)
        find1 = find(f >= FrequencyBands(i,1),1);
        find2 = find(f <= FrequencyBands(i,2),1,'last');
        AbsolutePower(i) = sum(p(find1:find2));
        find3 = find(f>=0,1);
        find4 = find(f<=45,1,'last');
        out.AbsPower{i,1}(iChan) = AbsolutePower(i);
        out.RelPower{i,1}(iChan) = AbsolutePower(i)/sum(p(f3:f4));
    end
    psd{iChan} = p;
end

out.psd = psd;
out.f = f;

D = out.RelativePower{1};
T = out.RelativePower{2};
A = out.RelativePower{3};
B = out.RelativePower{4};

DA = D./A;
DTAT = (D+T)./(A+T);
DTAB = (D+T)./(A+B);

out.DA = DA;
out.DTAT = DTAT;
out.DTAB = DTAB;
