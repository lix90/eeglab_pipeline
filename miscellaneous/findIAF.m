function FrequencyBands = findIAF(signal, fs, PSDWindow, PSDOverlap, PSDFreqResolution)

    if isempty(PSDWindow)
        PSDWindow = hamming(2^9);
    end
    if isempty(PSDFreqResolution)
        PSDFreqResolution = 2^14;
    else
        PSDFreqResolution = 2^(nextpow2(1/(PSDFreqResolution/fs))); 
        %because padded resolution is given by SamplingFreq/WindowLength
    end
    if isempty(PSDOverlap)
        PSDOverlap = 0;
    end
    
    PeakFitObject = nbt_PeakFit(size(signal, 2));
    PeakFitObject.PSDFreqResolution = fs/PSDFreqResolution;
    PeakFitObject.PSDWindow = PSDWindow;
    PeakFitObject.PSDOverlap = PSDOverlap;
    
    %% get individual alpha peak frequency
    % input signal must be high-pass filtered
    nbChan = size(signal, 2);
    PeakFit = struct();
    
    for ChId = 1:nbChan
        [p1, f1] = pwelch(signal(:, ChId), PSDWindow, PSDOverlap, PSDFreqResolution, fs);

        PeakFit.p{ChId,1} = p1;
        PeakFit.f = f1;

        %% Find Alpha peak
        % define Alpha peak range
        a = find(f1 > 4, 1 );
        b = find(f1 > 14, 1 );
        loweredge = find(f1 > 0.5, 1);
        upperedge = find(f1 > 42, 1);
        
        % we fit a 1/f baseline
        try
            [pks,locs] = findpeaks(p1, 'MINPEAKHEIGHT', prctile(p1, 90));
            if ~(50 < pks(1) < 200)
                pks(1) = 130;
            end
            s = fit(log(f1([locs(1):a,b:upperedge])), ...
                    log((p1([locs(1):a,b:upperedge]))), ...
                    'poly1');
            PeakFit.OneOverF_Alpha{ChId,1} = {exp(s.p2),s.p1};
            zeta2 = exp(s.p2).*f1(2:end).^s.p1;
            p_minus1overf = p1(2:end)-zeta2;
            % Subtract this 1/f baseline
            PeakFit.Pminus1overf(ChId) = sum(p_minus1overf);
            PeakFit.Fminus1overf(ChId) = sum(p_minus1overf > 0.5*median(p_minus1overf));
        catch
        end

        % and fit Gaussian to the peak
        try
            s1 = fit(f1(a+1:b+1), p_minus1overf(a:b), ...
                     'gauss1', 'lower', [0 3 -100 ], ...
                     'upper', [1000 20 200], ...
                     'MaxIter', 100000, ...
                     'MaxFunEvals', 200000);
            % ,'startpoint',[start mu 3 50 -1],'lower',[0 0 -100 -100 ],'upper',[1000
            % 40 200 2000 0],'MaxIter',1000);
            % find the confidence interval
            confidenceInterval = predint(s,s1.b1,0.95,'functional');
            if((s1.a1+s(s1.b1)) > confidenceInterval(2))
                PeakFit.AlphaFreq(ChId,1) = s1.b1;
                PeakFit.corrected_power(ChId,1)= s1.a1;
                PeakFit.PeakWidth(ChId,1)= s1.c1;
            end
        catch
        end

        %% Find second alpha peak if it exists
        try
            s1=fit(f1(a:b),p_minus1overf(a:b), ...
                   'gauss2','lower',[0 3 -100 ], ...
                   'upper',[1000 20 200],...
                   'MaxIter',100000,...
                   'MaxFunEvals',200000);
            confidenceInterval1 = predint(s, s1.b1, 0.95, 'functional');
            confidenceInterval2 = predint(s, s1.b2, 0.95, 'functional');
            if (((s1.a1+s(s1.b1)) > confidenceInterval1(2)) && (((s1.a2+s(s1.b2)) > confidenceInterval2(2))))
                PeakFit.AlphaFreq1(ChId,1) = s1.b1;
                PeakFit.Alpha1corrected_power(ChId, 1) = s1.a1;
                PeakFit.Alpha1PeakWidth(ChId, 1) = s1.c1;
                PeakFit.AlphaFreq2(ChId, 1) = s1.b2;
                PeakFit.Alpha2corrected_power(ChId, 1) = s1.a2;
                PeakFit.Alpha2PeakWidth(ChId, 1) = s1.c2;
            end
        catch
        end

        %% Find TF theta see e.g. Klimesch 1999, EEG alpha and theta
        % oscillations reflect cognitive and memory performance: a review
        % and analysis, Brain Research Reviews 29:169-195
        try
            freqIndex = find(f1 < s1.b1);
            [dummy, index] = min(p1(2:freqIndex(end)));
            
            PeakFit.TF(ChId,1) = f1(index+1);
        catch
            PeakFit.TF(ChId,1) = nan(1,1);
        end

        FrequencyBands = nbt_FindFrequencyBands(PeakFit, ChId, p1, f1);
    end


function FrequencyBands = nbt_FindFrequencyBands(PeakFit,ChId,p,frq)

% Fixed frquency bands
    FrequencyBands = [1 4]; %delta
    FrequencyBands = [FrequencyBands; 4 8]; % theta
    FrequencyBands = [FrequencyBands; 8 13]; % alpha
    FrequencyBands = [FrequencyBands; 13 30]; %beta
    FrequencyBands = [FrequencyBands; 30 45]; %gamma
    FrequencyBands = [FrequencyBands; 1 45]; %broadband;
    FrequencyBands = [FrequencyBands; 8 10]; %lower alpha
    FrequencyBands = [FrequencyBands; 10 13];% upper alpha

    % find frequency bands based on IAF the indiviual alpha frequency.
    % Adapted from Klimesch et al 1999;
    % find f1, f2
    if(isnan(PeakFit.TF(ChId)) || PeakFit.TF(ChId) < 2)
        f1 =  8;
    else
        f1 = PeakFit.TF(ChId);
    end
    if(isnan(PeakFit.AlphaFreq(ChId)))
        f2 =  13;
    else
        f2 =  abs(5 - (PeakFit.AlphaFreq(ChId)-1))+ PeakFit.AlphaFreq(ChId);
    end

    % IAF
    IAF = sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')).*frq(find(frq >= f1,1):find(frq <=f2,1,'last')))/sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')));
    f2 = abs( 5 - (IAF - 1)) + IAF;
    IAF = sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')).*frq(find(frq >= f1,1):find(frq <=f2,1,'last')))/sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')));
    
    %IDelta
    FrequencyBands = [FrequencyBands; 1, f1];
    
    %ITheta
    FrequencyBands = [FrequencyBands; f1 - 2, f1];
    
    %Alpha1
    FrequencyBands = [FrequencyBands; IAF-4, IAF-2];
    
    %Alpha2
    FrequencyBands = [FrequencyBands; IAF-2, IAF];
    
    %Alpha3
    FrequencyBands = [FrequencyBands; IAF, IAF+2];
    
    %Alpha all
    FrequencyBands = [FrequencyBands; IAF-4, IAF+2];
    
    %Ibeta
    FrequencyBands = [FrequencyBands; IAF+2, 30];

