function BiomarkerObject = lix_nbt_PeakFit(NumChannels)

if nargin == 0
    NumChannels = 1;
end
BiomarkerObject.AlphaFreq = nan(NumChannels,1);
BiomarkerObject.IAF = nan(NumChannels,1);
BiomarkerObject.corrected_power = nan(NumChannels, 1);
BiomarkerObject.PeakWidth = nan(NumChannels, 1);

BiomarkerObject.AlphaFreq1 = nan(NumChannels, 1);
BiomarkerObject.Alpha1corrected_power= nan(NumChannels, 1);
BiomarkerObject.Alpha1PeakWidth= nan(NumChannels, 1);
BiomarkerObject.AlphaFreq2 = nan(NumChannels, 1);
BiomarkerObject.Alpha2corrected_power= nan(NumChannels, 1);
BiomarkerObject.Alpha2PeakWidth= nan(NumChannels, 1);

BiomarkerObject.BetaFreq1= nan(NumChannels, 1);
BiomarkerObject.Beta1corrected_power= nan(NumChannels, 1);
BiomarkerObject.Beta1PeakWidth= nan(NumChannels, 1);
BiomarkerObject.BetaFreq2= nan(NumChannels, 1);
BiomarkerObject.Beta2corrected_power= nan(NumChannels, 1);
BiomarkerObject.Beta2PeakWidth= nan(NumChannels, 1);
BiomarkerObject.Beta2PeakDistance = nan(NumChannels,1);

BiomarkerObject.BetaFreq = nan(NumChannels,1);
BiomarkerObject.Betacorrected_power = nan(NumChannels, 1);
BiomarkerObject.BetaPeakWidth = nan(NumChannels, 1);
BiomarkerObject.AbsolutePower = cell(NumChannels, 1);
BiomarkerObject.RelativePower = cell(NumChannels, 1);
BiomarkerObject.CentralFreq = cell(NumChannels, 1);
BiomarkerObject.CentralPower = cell(NumChannels, 1);
BiomarkerObject.Bandwidth = cell(NumChannels, 1);
BiomarkerObject.SpectralEdge = cell(NumChannels, 1);
%-------------------------------------------------
% Array spectral bioms in classical frequency bands
BiomarkerObject.Bandwidth_Delta = nan(NumChannels, 1);
BiomarkerObject.Bandwidth_Theta = nan(NumChannels, 1);
BiomarkerObject.Bandwidth_Alpha = nan(NumChannels, 1);
BiomarkerObject.Bandwidth_Beta = nan(NumChannels, 1);
BiomarkerObject.Bandwidth_Gamma = nan(NumChannels, 1);

BiomarkerObject.CentralFreq_Delta = nan(NumChannels, 1);
BiomarkerObject.CentralFreq_Theta = nan(NumChannels, 1);
BiomarkerObject.CentralFreq_Alpha = nan(NumChannels, 1);
BiomarkerObject.CentralFreq_Beta = nan(NumChannels, 1);
BiomarkerObject.CentralFreq_Gamma = nan(NumChannels, 1);

BiomarkerObject.SpectralEdge_Delta = nan(NumChannels, 1);
BiomarkerObject.SpectralEdge_Theta = nan(NumChannels, 1);
BiomarkerObject.SpectralEdge_Alpha = nan(NumChannels, 1);
BiomarkerObject.SpectralEdge_Beta = nan(NumChannels, 1);
BiomarkerObject.SpectralEdge_Gamma = nan(NumChannels, 1);

BiomarkerObject.OneOverF_Alpha = cell(NumChannels, 1);
BiomarkerObject.OneOverF_Beta = cell(NumChannels, 1);

%-------------------------------------------------
BiomarkerObject.AbsPowerRatio = {cell(0,0)};
BiomarkerObject.RelPowerRatio = {cell(0,0)};
BiomarkerObject.TF = nan(NumChannels, 1);
BiomarkerObject.AllPeaks = cell(NumChannels, 1);
BiomarkerObject.Pminus1overf = nan(NumChannels,1);
BiomarkerObject.Fminus1overf = nan(NumChannels,1);

BiomarkerObject.f = [];
BiomarkerObject.p = cell(NumChannels,1);
BiomarkerObject.DateLastUpdate = datestr(now);
BiomarkerObject.PrimaryBiomarker = 'AlphaFreq';
%         BiomarkerObject.Biomarkers = {'AlphaFreq','BetaFreq','AlphaFreq1','AlphaFreq2',...
%            'BetaFreq1','BetaFreq2','Bandwidth_Delta',...
%            'Bandwidth_Theta','Bandwidth_Alpha','Bandwidth_Beta','Bandwidth_Gamma',...
%            'CentralFreq_Delta','CentralFreq_Theta','CentralFreq_Alpha','CentralFreq_Beta','CentralFreq_Gamma',...
%         'SpectralEdge_Delta','SpectralEdge_Theta','SpectralEdge_Alpha','SpectralEdge_Beta','SpectralEdge_Gamma'};
BiomarkerObject.Biomarkers = {'AlphaFreq','IAF', 'BetaFreq','Betacorrected_power', 'BetaPeakWidth','AbsolutePower','RelativePower',...
                    'AbsPowerRatio', 'RelPowerRatio', 'TF', 'corrected_power', 'PeakWidth', 'CentralFreq','CentralPower', 'Bandwidth', 'SpectralEdge',...
                    'Pminus1overf','Fminus1overf','AlphaFreq1', 'Alpha1corrected_power', 'Alpha1PeakWidth', 'AlphaFreq2', 'Alpha2corrected_power',...
                    'Alpha2PeakWidth','BetaFreq1', 'Beta1corrected_power','Beta1PeakWidth', 'BetaFreq2', 'Beta2corrected_power', 'Beta2PeakWidth', 'Beta2PeakDistance'...
                    'Bandwidth_Theta','Bandwidth_Alpha','Bandwidth_Beta','Bandwidth_Gamma',...
                    'CentralFreq_Delta','CentralFreq_Theta','CentralFreq_Alpha','CentralFreq_Beta','CentralFreq_Gamma','CentralFreq_Broadband','CentralFreq_Alpha1','CentralFreq_Alpha2', ...
                    'SpectralEdge_Delta','SpectralEdge_Theta','SpectralEdge_Alpha','SpectralEdge_Beta','SpectralEdge_Gamma', ...
                    'AbsolutePower_Delta', 'AbsolutePower_Theta', 'AbsolutePower_Alpha', 'AbsolutePower_Beta', 'AbsolutePower_Broadband', 'AbsolutePower_Alpha1', 'AbsolutePower_Alpha2','AbsolutePower_Gamma', 'RelativePower_Delta', 'RelativePower_Theta','RelativePower_Alpha', 'RelativePower_Beta'};
