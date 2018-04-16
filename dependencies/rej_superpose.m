function [rejE, rejG] = rej_superpose(EEG)

rej = EEG.reject;

ntrials = EEG.trials;
nchans = EEG.nbchan;
rejE_ = zeros(nchans, ntrials);
rejG_ = zeros(1, ntrials);

if isempty(rej.rejjpE) || isempty(rej.rejjp)
    rej.rejjpE = rejE_;
    rej.rejjp = rejG_;
end

if isempty(rej.rejkurtE) || isempty(rej.rejkurt)
    rej.rejkurtE = rejE_;
    rej.rejkurt = rejG_;
end

if isempty(rej.rejmanualE) || isempty(rej.rejmanual)
    rej.rejmanualE = rejE_;
    rej.rejmanual = rejG_;
end

if isempty(rej.rejconstE) || isempty(rej.rejconst)
    rej.rejconstE = rejE_;
    rej.rejconst = rejG_;
end

if isempty(rej.rejfreqE) || isempty(rej.rejfreq)
    rej.rejfreqE = rejE_;
    rej.rejfreq = rejG_;
end


rejE = rej.rejjpE + rej.rejkurtE + rej.rejmanualE + rej.rejconstE + rej.rejfreqE;
rejG = rej.rejjp + rej.rejkurt + rej.rejmanual + rej.rejconst + rej.rejfreq;

%EEG.reject.rejglobal = rejG~=0;
%EEG.reject.rejglobalE = rejE~=0;
rejE = rejE ~= 0;
rejG = rejG ~= 0;