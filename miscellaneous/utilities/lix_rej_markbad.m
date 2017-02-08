function EEG = lix_rej_markbad(EEG, rej)

ChanOrComp = rej.chanorcomp;
% chan 1, comp 0
if ChanOrComp
	NUM = size(EEG.data, 1);
else
	NUM = size(EEG.icaact, 1);
end

eegthresh = rej.eegthresh;
jointprob = rej.jointprob;
rejtrend = rej.rejtrend;
rejkurt = rej.rejkurt;

nbchan = size(EEG.data,1);
if ~isempty(eegthresh)
	EEG = pop_eegthresh(EEG, ChanOrComp, 1:NUM, eegthresh(1), eegthresh(2), EEG.xmin, EEG.xmax, 0, 0);
end
if ~isempty(jointprob)
	EEG = pop_jointprob(EEG, ChanOrComp, 1:NUM, jointprob(1), jointprob(2), 0, 0);
end
if ~isempty(rejtrend)
	EEG = pop_rejtrend(EEG, ChanOrComp, 1:NUM, EEG.pnts, rejtrend(1), rejtrend(2), 0, 0, 0);
end
if ~isempty(rejkurt)
	EEG = pop_rejkurt(EEG, ChanOrComp, 1:NUM, rejkurt(1), rejkurt(2), 0, 0);
end	
EEG = eeg_checkset(EEG);