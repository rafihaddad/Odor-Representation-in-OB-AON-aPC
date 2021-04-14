function [neurons_odors_responses, neurons_odors_responses_pvals] = responses_preodor_baseline(neurons_odors, preOdorSniff, postOdorSniff, rate_flag)
% input:
%       neurons_odors = neurons odors datastruct (#neurons x #odors x #trials) 
%                       with fields: times, inh, exh, inh1_idx
%       preOdorSniff = # sniff before 1st inh post odor onset (e.g. -2)
%       postOdorSniff = # sniff post 1st inh post odor onset (e.g. 1, 2,...). 
%                       NOTICE: 1st sniff is 1 (not 0)
%       rate_flag = determine response by:
%                   1: spike rate in sniff
%                   0: spike count in sniff
%                 * optional, default = 0
% output: 
%       neurons_odors_responses: (#neurons x #odors) 1: response, 0: no response
%       neurons_odors_responses_pvals: (#neurons x #odors) p-values of response
% response is determined according to wilcoxon test (ranksum) comparing
% activity in postOdorSniff in response to odor with activity in preOdorSniff 

if nargin < 4
    rate_flag = 0;
end

[num_neurons, num_odors, ~] = size(neurons_odors);
neurons_odors_responses = NaN(num_neurons, num_odors);
neurons_odors_responses_pvals = NaN(num_neurons, num_odors);

for neuron=1:num_neurons
    for odor=1:num_odors
        trials = squeeze(neurons_odors(neuron,odor,:));
        [all_sp_cnt, all_sp_rate] = trial_sniff_firing(trials);
        all_sp_cnt = all_sp_cnt(~all(isnan(all_sp_cnt),2),:);
        all_sp_rate = all_sp_rate(~all(isnan(all_sp_cnt),2),:);
        if isempty(all_sp_cnt)  
            continue;   % all trials are invalid (NaN)
        end        
        sniff_idx = neurons_odors(neuron,1,1).inh1_idx+postOdorSniff-1;
        sniff_sp_cnts = all_sp_cnt(:,sniff_idx);
        sniff_sp_rates = all_sp_rate(:,sniff_idx);
        % baseline
        sniff_idx_bl = neurons_odors(neuron,1,1).inh1_idx+preOdorSniff;
        sniff_sp_cnts_bl = all_sp_cnt(:,sniff_idx_bl);
        sniff_sp_rates_bl = all_sp_rate(:,sniff_idx_bl);
        % check if neuron responded to odor
        if rate_flag
            % compare spike rates
            [p,h] = ranksum(sniff_sp_rates_bl, sniff_sp_rates);
        else
            % compare spike counts
            [p,h] = ranksum(sniff_sp_cnts_bl, sniff_sp_cnts);   
        end
        neurons_odors_responses_pvals(neuron,odor) = p;
        neurons_odors_responses(neuron,odor) = h;
    end  
end
end

