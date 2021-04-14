function [matFR, matResp] = get_mat_fr(data, params)
% input:
%   data: region data: struct with fields:
%           data: odors responses data 
%           data_blank (optional, use if baseline is blank): blank responses data
%           non_inh_flag (optional): 
%               1: only use neurons that weren't inhibited for any odor
%               0: use all neurons
%   params: 
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
%           post_sniff: post odor sniff (1st is 1, not 0)
%           pre_sniff (optional, use if baseline is pre-odor sniff): pre odor sniff baseline
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
%   Note: should supply either data_blank in data, or pre_sniff in params
%         if preodor_bl_flag is provided, baseline will be chosen according
%         to preodor_bl_flag. Otherwise, it is according to what is
%         provided - data_blank / pre_sniff 
% output:
%   matFR: mat of firing rate in post_sniff (size: #neurons x #odors)
%   matResp: mat of binary response (1/0) in post_sniff (size: #neurons x
%   #odors)


matResp = [];
if isfield(data, 'data_blank') && (~isfield(params, 'preodor_bl_flag') || params.preodor_bl_flag == 0) 
    use_blank = 1;
else
    use_blank = 0;
end

% binary responses (1/0)
if use_blank
    % use blank as baseline
    matResp = responses_compared_to_blank(data.data, data.data_blank, params.post_sniff, params.rate_flag);
elseif isfield(params, 'pre_sniff')
    % use pre-odor sniff as baseline
    matResp = responses_preodor_baseline(data.data, params.pre_sniff, params.post_sniff, params.rate_flag);
end


% evoked response
if use_blank
    % use blank as baseline
    matFR_evoked = evoked_FR_compared_to_blank(data.data, data.data_blank, params.post_sniff, params.rate_flag);
elseif isfield(params, 'pre_sniff')
    % use pre-odor sniff as baseline
    matFR_evoked = evoked_FR_preodor_baseline(data.data, params.pre_sniff, params.post_sniff, params.rate_flag);
end

% choose matFR according to params
if params.evoked_flag
    % evoked FR
    matFR = matFR_evoked;
else
    % absolute response 
    [inh1_idx, mat_cnt, mat_rate] = build_4d_matrix(data.data);
    if params.rate_flag
        matFR = nanmean(mat_rate(:,:,:,inh1_idx + params.post_sniff - 1),3);
    else
        matFR = nanmean(mat_cnt(:,:,:,inh1_idx + params.post_sniff - 1),3);
    end
end

if isfield(data, 'non_inh_flag') && data.non_inh_flag
    % take non-inhibited neurons only
    num_neurons = size(matFR_evoked,1);
    non_inh_neurons = false(num_neurons,1);
    for neuron=1:num_neurons
        B = matResp(neuron,:);
        if all(matFR_evoked(neuron,find(B)) > 0) || all(B == 0)
            non_inh_neurons(neuron) = 1;
        end
    end
    matFR = matFR(non_inh_neurons,:);
end
end

