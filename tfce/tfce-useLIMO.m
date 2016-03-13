%% tfce for multiple comparison correction
% parameters initiation
type = 3;
% 1. compute channel neighbour structmat
if type == 3
    channeighbstructmat = limo_neighbourdist(EEG);
end

% 2. run tfce
type = '3'; % 1 for 1D data; 2 for 2D data; 3 for 3D data.