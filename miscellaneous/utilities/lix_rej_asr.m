function EEG = lix_asr_rejchan(EEG, vis);	


arg_flatline = 5;
arg_channel = 0.85;
arg_noisy = 4;
arg_highpass = 'off';
arg_burst = 'off';
arg_window = 'off';
cleanEEG = clean_artifacts(EEG, 'FlatlineCriterion', arg_flatline,...
                            'Highpass',          arg_highpass,...
                            'ChannelCriterion',  arg_channel,...
                            'LineNoiseCriterion',  arg_noisy,...
                            'BurstCriterion',    arg_burst,...
                            'WindowCriterion',   arg_window);
if vis
	vis_artifacts(cleanEEG,EEG);
end
EEG = cleanEEG;



