function out = lix_samEn(EEG);

m = 2;
r = 0.2;
tau = 1;

nChan = EEG.nbchan;
samEn = zeros(nChan,1);

for iChan = 1:nChan
    seq = EEG.data(iChan, :);
    samEn(iChan) = sampleEntropy(seq, m, r, tau);
end

out.M = m;
out.R = r;
out.samEn = samEn;
