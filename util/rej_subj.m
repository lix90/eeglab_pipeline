function rej_or_not = rejSubj(EEG, threshPercentage, nOrigTrial)

recentNumTrial = EEG.trials;
percent = 100*(1-recentNumTrial/nOrigTrial);
if ceil(percent) > threshPercentage
    rej_or_not = 1;
else
    rej_or_not = 0;
end

