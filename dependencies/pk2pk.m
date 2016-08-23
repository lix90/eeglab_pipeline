function pk2pk_value = pk2pk(signal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function pk2pk_value = pk2pk(signal)
%   the peak to peak value of the signal is determined
%   all peaks and troughs are used and the mean signal pk2pk result is
%   produced.
%
% By R. Lobbia, rlobbia@hotmail.com
%   2008-06-16, created
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%use mean to provide AC filtering; centering peaks about origin
signal_ac   = signal - mean(signal);%could also use detrend but that's a rare matlab function

%first find set of upper peaks
upper_pks   = findpeaks(signal_ac);

%now find 
lower_pks   = findpeaks(-signal_ac);

pk2pk_value = mean(upper_pks) + mean(lower_pks);

end

