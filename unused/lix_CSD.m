function EEG = lix_CSD(EEG, G, H)

data = CSD(reshape(single(EEG.data), ...   % compute CSD for reshaped data (i.e., use a ...
  EEG.nbchan,EEG.trials*EEG.pnts),G,H);    % <channels-by-(samples*trials)> 2-D data matrix)
data = reshape(data,EEG.nbchan, ...        % reshape CSD output and re-assign to EEGlab ...
  EEG.pnts, EEG.trials);                   % <channels-by-samples-by-epochs> data matrix
EEG.data = double(data); 
