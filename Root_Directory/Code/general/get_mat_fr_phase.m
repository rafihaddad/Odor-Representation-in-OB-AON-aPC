function [matFR] = get_mat_fr_phase(data, params)
% input:
%   data: region data: struct with fields:
%           data: odors responses data 
%           data_blank (optional, use if baseline is blank): blank responses data
%           non_inh_flag (optional): 
%               1: only use neurons that weren't inhibited for any odor
%               0: use all neurons
%   params: 
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%           start_sniff_phase: index + phase of start start of sniff range
%                           (e.g. 0.6)
%           end_sniff_phase: index + phase of sniff end of sniff range (bin
%                         will be up to inhalation of this sniff index +
%                         phase) (e.g. 2.6) 
%           pre_end_sniff_phase (optional, use if baseline is pre-odor activity): index + phase of end of baseline sniff range
%   Note: should supply either data_blank in data, or pre_sniff in params
% output:
%   matFR: mat of firing rate or count in sniff range (size: #neurons x #odors)


[mat3_FR] = matFR_in_sniff_range(data.data, params.start_sniff_phase, params.end_sniff_phase, params.rate_flag);
mat2_FR = nanmean(mat3_FR,3);
% evoked response
if params.evoked_flag
    % evoked response
    if isfield(data, 'data_blank')
        % use blank as baseline
        [mat3_FR_bl] = matFR_in_sniff_range(data.data_blank, params.start_sniff_phase, params.end_sniff_phase, params.rate_flag);
        mat2_FR_bl = nanmean(mat3_FR_bl,3);
        mat2_FR_bl = repmat(mat2_FR_bl, [1 size(mat2_FR,2)]);
    elseif isfield(params, 'pre_end_sniff_phase')
        % use pre-odor activity as baseline
        range = params.end_sniff_phase - params.start_sniff_phase;
        pre_start_sniff_phase = params.pre_end_sniff_phase - range;    
        [mat3_FR_bl] = matFR_in_sniff_range(data.data, pre_start_sniff_phase, params.pre_end_sniff_phase, params.rate_flag);
        mat2_FR_bl = nanmean(mat3_FR_bl,3);        
    end
    matFR = mat2_FR - mat2_FR_bl;
else
    % absolute response 
    matFR = mat2_FR;
end

end

