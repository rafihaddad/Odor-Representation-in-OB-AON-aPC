function [vecR, vecP, meanR, stdR, matR, matP] = odor_corr_trials_vector(data, params, matFR)
% input: 
%   data: region data. struct with fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data 
%           non_inh_flag (optional, can use for cortex): 
%               1: only use neurons that weren't inhibited
%               0: use all neurons
%         Note: can supply matFR INSTEAD of data
%   params: struct with fields:
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%           corr_type: e.g. Pearson, Spearman
%           entire_sniff_flag: 1: correlation between FR in entire sniff
%                              0: correlation between FR in sniff
%                              phase/range
%           1. If entire_sniff_flag = 1:
%              *post_sniff: post odor sniff of which to evaluate response corr (1st is 1, not 0)
%              *pre_sniff (if baseline is preodor sniff): pre odor sniff to be used as baseline
%           2. If entire_sniff_flag = 0:
%              *start_sniff_phase: index + phase of sniff start of sniff range (e.g. 0.6)
%              *end_sniff_phase: index + phase of sniff end of sniff range (bin
%                   will be up to inhalation of this sniff index + phase) (e.g. 2.6) 
%              *pre_end_sniff_phase (if baseline is pre-odor activity): index + phase of end of baseline sniff range
%   matFR: supply this when data is not supplied
% output:
%   vecR: vector of correlations (size #odor-pairs x 1)
%   vecP: vector of p-values of correlations (size #odor-pairs x 1)
%   meanR: mean of correlations
%   stdR:  standard deviation of correlations
%   matR: mat of correlations (size #odors x #odors)
%   matP: mat of p-values of correlations (size #odors x #odors)

if ~isempty(data)
    if params.entire_sniff_flag
        matFR = get_mat_fr_3d(data, params);
    else
        matFR = get_mat_fr_phase_3d(data, params);
    end
end

% corr and p values
vecR = []; vecP = [];
% correlations between odors for each trial

for t=1:size(matFR,3)
    matFR_t = squeeze(matFR(:,:,t));
    if ~isfield(params, 'dist_flag') || params.dist_flag == 0
        [matR,matP] = corr(matFR_t, 'Type', params.corr_type, 'rows', 'complete');
    else        
        % pdist will return NaN values for trials in which there are NaN
        % values
        matR = pdist(matFR_t', params.dist_type);
        matR = squareform(matR);
        matP = [];
    end
    vecR = [vecR; upperRightTriAsVector(matR)];
    vecP = [vecP; upperRightTriAsVector(matP)];
end
% num_nan_trials
meanR = nanmean(vecR);
stdR = nanstd(vecR);


end

