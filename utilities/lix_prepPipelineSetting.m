function params = lix_prepPipelineSetting(EEG)

%% prep pipeline parameters
params.detrendChannels = 1:EEG.nbchan;
params.lineNoiseChannels = 1:EEG.nbchan;
params.referenceChannels = 1:EEG.nbchan;
params.evaluationChannels = 1:EEG.nbchan;
params.rereferencedChannels = 1:EEG.nbchan;


% pop_editoptions('option_single', false, 'option_savetwofiles', false);

% params = struct();
% % parameters for boundary:
% params.ignoreBoundaryEvents = true;
% % parameters for resample:
% % params.resampleOff = true;
% % params.resampleFrequency = 256;
% % params.lowPassFrequency = 0;
% % parameters for detrend:
% params.detrendChannels = 1:EEG.nbchan;
% params.detrendType = 'high pass';
% detrendCutoff = 1;
% % parameters for linenoise:
% params.lineNoiseChannels = 1:EEG.nbchan;
% params.lineFrequencies = [50 120 180 240];
% % parameters for reference:
% params.robustDeviationThreshold = 5;
% params.highFrequencyNoiseThreshold = 5;
% params.correlationThreshold = 0.4;
% params.badTimeThreshold = 0.01;
% params.referenceType = 'robust'; % {robust} | average | specific | none
% % params.interpolationOrder = 'post-reference'; % {post-reference} | pre-reference | none
% % params.meanEstimateType = 'median'; % {median} | huber | mean | none
% params.referenceChannels = 1:EEG.nbchan;
% params.evaluationChannels = 1:EEG.nbchan;
% params.rereferencedChannels = 1:EEG.nbchan;
% % parameters for report:
% params.reportMode = 'skip'; % normal | skip | reportOnly
% % parameters for postprocess:
% params.keepFiltered = false; % true | false
% params.removeInterpolatedChannels = true; % true | false
% params.cleanupReference = false; % true | false