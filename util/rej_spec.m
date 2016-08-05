% compute spectrum and reject artifacts
% -------------------------------------
function [specdata, Irej, Erej, freqs ] = rejSpec(data, specdata, elecrange, srate, negthresh, posthresh, startfreq, endfreq, method);

% compute the fft if necessary - old version
if isempty(specdata)
    if strcmpi(method, 'fft')
        sizewin = size(data,2);
        freqs = srate*[1, sizewin]/sizewin/2;
        specdata = fft( data-repmat(mean(data,2), [1 size(data,2) 1]), sizewin, 2);
        specdata = specdata( :, 2:sizewin/2+1, :);
        specdata = 10*log10(abs( specdata ).^2);
        specdata  = specdata - repmat( mean(specdata,3), [1 1 size(data,3)]);
    else
        if ~exist('pmtm')
            error('The signal processing toolbox needs to be installed');
        end;
        [tmp freqs] = pmtm( data(1,:,1), [],[],srate); % just to get the frequencies

        fprintf('Computing spectrum (using slepian tapers; done only once):\n');

        for index = 1:size(data,1)
            fprintf('%d ', index);
            for indextrials = 1:size(data,3)
                [ tmpspec(index,:,indextrials) freqs] = pmtm( data(index,:,indextrials) , [],[],srate);
            end;
        end;
        tmpspec  = 10*log(tmpspec);
        tmpspec  = tmpspec - repmat( mean(tmpspec,3), [1 1 size(data,3)]);
        specdata = tmpspec;
    end;
else
    if strcmpi(method, 'fft')
        sizewin = size(data,2);
        freqs = srate*[1, sizewin]/sizewin/2;
    else
        [tmp freqs] = pmtm( data(1,:,1), [],[],srate); % just to get the frequencies
    end;
end;

% perform the rejection
% ---------------------
[I1 Irej NS Erej] = eegthresh( specdata(elecrange, :, :), size(specdata,2), 1:length(elecrange), negthresh, posthresh, ...
                               [freqs(1) freqs(end)], startfreq, min(freqs(end), endfreq));
fprintf('\n');
