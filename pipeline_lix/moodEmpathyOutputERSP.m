alpha = [8, 12, 400, 800];
beta = [13, 20, 300, 700];
chan = {'C3', 'C1', 'Cz', 'C2', 'C4'};
% chan = {'O1', 'Oz', 'O2'};
band = {'alpha', 'beta'};

f = dsearchn(freqs', roi(1:2)');
t = dsearchn(times', roi(3:4)');
c = find(ismember(chans, chan));
dataSubset = ...
    cellfun(@(x) {squeeze(mean(mean(x(f(1):f(2), t(1):t(2), c, :), 1), ...
                               2))}, data);
dataMN = cellfun(@(x) mean(x, 2), dataSubset, 'UniformOutput', false);
dataSE = cellfun(@(x) std(x, 1, 2)/sqrt(size(x, 2)), dataSubset, ...
                 'UniformOutput', false);
dataMN = reshape(cell2mat(dataMN))
