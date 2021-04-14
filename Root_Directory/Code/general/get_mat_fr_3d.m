function [matFR, matResp] = get_mat_fr_3d(data, params)
% input:
%   data: region data: struct with fields:
%           data: odors responses data 
%           data_blank (optional, use if baseline is blank): blank responses data
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
%   matFR: mat of firing rate in post_sniff (size: #neurons x #odors x #trials)
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

% FR responses
[inh1_idx, mat_cnt, mat_rate] = build_4d_matrix(data.data);
if params.rate_flag
    matFRabs = mat_rate(:,:,:,inh1_idx + params.post_sniff - 1);
else
    matFRabs = mat_cnt(:,:,:,inh1_idx + params.post_sniff - 1);
end
if params.evoked_flag
    % evoked response
    if use_blank
        % use blank as baseline
        [inh1_idx_blank, mat_cnt_blank, mat_rate_blank] = build_4d_matrix(data.data_blank);
        if params.rate_flag
            matFRblank = mat_rate_blank(:,:,:,inh1_idx_blank + params.post_sniff - 1);
        else
            matFRblank = mat_cnt_blank(:,:,:,inh1_idx_blank + params.post_sniff - 1);
        end
        matFRblank = nanmean(matFRblank,3);
        matFR_bl = repmat(matFRblank, [1 size(matFRabs,2) size(matFRabs,3)]);    
    elseif isfield(params, 'pre_sniff')
        % use pre-odor sniff as baseline
        if params.rate_flag
            matFR_pre = mat_rate(:,:,:,inh1_idx + params.pre_sniff);
        else
            matFR_pre = mat_cnt(:,:,:,inh1_idx + params.pre_sniff);
        end
        matFR_pre = nanmean(matFR_pre,3);
        matFR_bl = repmat(matFR_pre, [1 1 size(matFRabs,3)]);
    end
    matFR = matFRabs - matFR_bl;
else
    % absolute response 
    matFR = matFRabs;
end

end

