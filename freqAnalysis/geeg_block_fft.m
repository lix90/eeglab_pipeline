function [fs,pwr] = geeg_block_fft(time_series,hz,win)
%GEEG_BLOCK_FFT - get power for multiple time series
%
%   Syntax: [fs,pwr] = geeg_block_fft(time_series,hz,win)
%
%   Input:
%       time_series - [nPoints x nSeries] time series
%       hz - sampling rate
%       win - window to apply (e.g. hamming(2048))
%   Output:
%       fs - frequencies
%       pwr - [nFFTPoints x nSeries] power at each frequency

[nPoints, nSeries] = size(time_series);

%% Windowing
% Check window size against block size
if (size(win,2) < nSeries)
    % repeat window to make matrix the same size as time_series
    win = repmat(win,1,nSeries);
end
% Apply window
time_series = time_series.*win;

%% Compute FFT, power
% Take fft
FFTX = fft(time_series);
% Calculate the number of unique points
NumUniquePts = ceil((nPoints+1)/2);
% FFT is symmetric, throw away second half
FFTX = FFTX(1:NumUniquePts,:);
% Take the magnitude of fft of x
MX = abs(FFTX);
% Scale the fft so that it is not a function of the length of x
MX = MX./nPoints;
% Take the square of the magnitude of fft of x.
pwr = MX.^2;
% Multiply by 2 because you threw out second half of FFTX above
pwr = pwr.*2;
% DC Component should be unique, i.e. undo multiply by 2.
pwr(1,:) = pwr(1,:)./2;
% Nyquist component should also be unique.
if ~rem(nPoints,2)
   % Here NFFT is even; therefore, Nyquist point is included.
   pwr(end,:) = pwr(end,:)./2;
end

%% Compute frequency vector
% This is an evenly spaced frequency vector with NumUniquePts points.
fs = (0:NumUniquePts-1)* hz / nPoints;
fs=fs';