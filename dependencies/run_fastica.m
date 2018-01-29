function EEG = run_fastica(EEG, isavg);

nc = size(EEG.data, 1);
if isavg
    npc = nc-1;
else
    npc = nc;
end

EEG = pop_runica(EEG, 'icatype', 'fastica', 'numOfIC', npc);
