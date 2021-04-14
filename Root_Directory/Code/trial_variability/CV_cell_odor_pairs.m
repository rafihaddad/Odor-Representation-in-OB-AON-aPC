function [CV] = CV_cell_odor_pairs(data, params)
% Calculates coefficient of variation of trials for each neuorn-odor pair
% input:
%   data: struct with fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%   params: struct with fields:
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
%           start_sniff_phase: index + phase of sniff start of sniff range (e.g. 0.6)
%           end_sniff_phase: index + phase of sniff end of sniff range (bin
%                   will be up to inhalation of this sniff index + phase) (e.g. 2.6) 
%           pre_end_sniff_phase (if evoked_flag = 1 and if baseline is pre-odor activity): index +
%               phase of end of baseline sniff range 
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)

[matFR, matResp] = get_mat_fr_phase_3d(data, params);

matFR_abs = abs(matFR); % only necessary for evoked activity (otherwise spike counts are always non-negative)
std = nanstd(matFR_abs,0,3);
avg = nanmean(matFR_abs,3);
CV = std./avg;

% remove pairs that didn't respond if using evoked activity
if params.evoked_flag
    CV(matResp == 0) = [];
else
    CV = CV(:)';
end

% remove pairs in which avg is close to 0
% CV(avg(:) < 1) = [];


end

