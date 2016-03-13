% suitable for repeated measures design
% not proper for between subject design
function output = export_roi_chanersp(STUDY, erspData, erspTimes, erspFreqs, range)

% check input
if nargin~=6
    fprintf('the number of parameters must be 6')
end

% code
output = struct();
conditions = STUDY.design.variable(1).value;
subjects = STUDY.subject;
times = erspTimes;
freqs = erspFreqs;
nCond = numel(conditions);
nSubj = numel(subjects);

% average in channel dimension
if ndims(erspData{1})==4
    erspData2 = cellfun(@(x) {squeeze(mean(x, 3))}, erspData);
elseif ndims(erspData{1})==3
    erspData2 = erspData;
end

% find frequency and time index
[t,f] = lix_tfind(times, freqs, range);
if size(subjects, 2) ~= 1; subjects = subjects'; end

% prepare output data
% switch dataFormat
%   case {'wide', 'w'}
    output.subject = subjects;
    for i = 1:nCond
        tmp = erspData2{i}(f(1):f(2), t(1):t(2), :);
        output.(conditions{i}) = squeeze(mean(mean(tmp,1),2));
    end
    
  % case {'long', 'l'}
  %   output.subject = repmat(subjects, [nCond, 1]);
  %   output.ersp = [];
  %   output.conditions = cell(nSubj, 1);
  %   if size(conditions, 1) == 1; conditions = conditions'; end
  %   tmp1 = repmat(conditions, [1, nSubj]);
    
  %   for i = 1:nCond
  %      tmp = erspData2{i}(f(1):f(2), t(1):t(2), :);
  %      output.ersp = [output.ersp, tmp];
  %   end
  %   if size(output.ersp, 1)==1
  %       output.ersp = output.ersp';
  %   end
% end
