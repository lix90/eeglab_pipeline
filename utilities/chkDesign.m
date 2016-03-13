function [output] = chkDesign(STUDY)

output = struct();

% check study design
var1 = STUDY.design.variable(1).value;
var2 = STUDY.design.variable(2).value;
pair1 = STUDY.design.variable(1).pairing;
pair2 = STUDY.design.variable(2).pairing;

designType = 0;
varIdx = 0;
if numel(var1) == 1 || numel(var2) == 1
    designType = 1;
    if numel(var1) == 1 && strcmp(pair2, 'on')
        type = 1;
        varIdx = 2;
    elseif numel(var2) == 2 && strcmp(pair1, 'on')
        type = 1;
        varIdx = 1;
    elseif numel(var1) == 1 && strcmp(pair2, 'off')
        type = 2;
        varIdx = 2;
    elseif numel(var2) == 1 && strcmp(pair1, 'off')
        type = 2;
        varIdx = 1;
    end
elseif numel(var1) > 1 && numel(var2) > 1
    if strcmp(pair1, 'off') && strcmp(pair2, 'on')
        type = 21;
    elseif strcmp(pair1, 'on') && strcmp(pair1, 'off')
        type = 12;
    elseif strcmp(pair1, 'off') && strcmp(pair2, 'off')
        type = 22;
    elseif strcmp(pair1, 'on') && strcmp(pair2, 'on')
        type = 11;
    end % 1 is within, 2 is between
end
% output
output.var1 = var1;
output.var2 = var2;
output.pair1 = pair1;
output.pair2 = pair2;
output.type = type;
output.varIdx = varIdx;
