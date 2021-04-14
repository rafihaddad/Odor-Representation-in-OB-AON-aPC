function [matFR, matResp] = get_mat_fr_phase_3d(data, params)
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
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
%   Note: should supply either data_blank in data, or pre_sniff in params
% output:
%   matFR: mat of firing rate or count in sniff range (size: #neurons x #odors x #trials)
%   matResp: mat of binary response (1/0) in sniff range (size: #neurons x #odors)

if isfield(data, 'data_blank') && (~isfield(params, 'preodor_bl_flag') || params.preodor_bl_flag == 0) 
    use_blank = 1;
else
    use_blank = 0;
end

[mat3_FR] = matFR_in_sniff_range(data.data, params.start_sniff_phase, params.end_sniff_phase, params.rate_flag);
% evoked response
if params.evoked_flag
    % evoked response
    if use_blank
        % use blank as baseline
        [mat3_FR_bl] = matFR_in_sniff_range(data.data_blank, params.start_sniff_phase, params.end_sniff_phase, params.rate_flag);
        mat3_FR_bl = repmat(mat3_FR_bl, [1 size(mat3_FR,2) 1]);
    else
        % use pre-odor activity as baseline
        range = params.end_sniff_phase - params.start_sniff_phase;
        pre_start_sniff_phase = params.pre_end_sniff_phase - range;    
        [mat3_FR_bl] = matFR_in_sniff_range(data.data, pre_start_sniff_phase, params.pre_end_sniff_phase, params.rate_flag);       
    end
    matFR = mat3_FR - mat3_FR_bl;
    % binary responses
    matResp = zeros(size(mat3_FR,1),size(mat3_FR,2));
    for neuron=1:size(mat3_FR,1)
        for odor=1:size(mat3_FR,2)
            [p,h] = ranksum(squeeze(mat3_FR(neuron,odor,:)), squeeze(mat3_FR_bl(neuron,odor,:)));
            matResp(neuron,odor) = h;
        end
    end
else
    % absolute response 
    matFR = mat3_FR;
    matResp = [];
end
end

