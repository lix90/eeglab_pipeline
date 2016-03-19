%find frequency bands based on IAF the indiviual alpha frequency.
%Adapted from Klimesch et al 1999;
%find f1, f2
if(isnan(PeakFitObject.TF(ChId)) || PeakFitObject.TF(ChId) < 2)
    f1 =  8;
else
    f1 = PeakFitObject.TF(ChId);
end
if(isnan(PeakFitObject.AlphaFreq(ChId)))
    f2 =  13;
else
    f2 =  abs(5 - (PeakFitObject.AlphaFreq(ChId)-1))+ PeakFitObject.AlphaFreq(ChId);
end

%IAF
find1 = find(frq >= f1,1);
find2 = find(frq <= f2,1,'last');
IAF = sum(p(find1:find2).*frq(find1:find2))/sum(p(find1:find2));
f2 = abs(5 - (IAF - 1)) + IAF;
IAF = sum(p(find1:find2).*frq(find1:(frq <=f2,1,'last')))/sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')));
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
