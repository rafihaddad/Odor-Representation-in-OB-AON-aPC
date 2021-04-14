function [evoked_FR] = evoked_FR_preodor_baseline(neurons_odors, preOdorSniff, postOdorSniff, rate_flag)
% input:
%           neurons_odors = neurons odors datastruct (#neurons x #odors x #trials) 
%           with fields: times, inh, exh, inh1_idx
%           preOdorSniff = # sniff pre 1st inh post odor onset (e.g. -1, -2)
%           postOdorSniff = # sniff post 1st inh post odor onset (e.g. 1, 2). 
%                           NOTICE: 1st sniff is 1 (not 0)
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
% output: 
%           evoked_FR: (#neurons x #odors) firing rate of each neuron for
%                       each odor (baseline is activity in preOdorSniff)

if nargin < 4
    rate_flag = 0;
end

[num_neurons, num_odors, ~] = size(neurons_odors);
evoked_FR = NaN(num_neurons, num_odors);

for neuron=1:num_neurons
    for odor=1:num_odors
        trials = squeeze(neurons_odors(neuron,odor,:));
        [all_sp_cnt, all_sp_rate] = trial_sniff_firing(trials);
        all_sp_cnt = all_sp_cnt(~all(isnan(all_sp_cnt),2),:);
        all_sp_rate = all_sp_rate(~all(isnan(all_sp_rate),2),:);
        if isempty(all_sp_cnt)  
            continue;   % all trials are invalid (NaN)
        end             
        sniff_idx = neurons_odors(neuron,1,1).inh1_idx+postOdorSniff-1;
        mean_count_odor = nanmean(all_sp_cnt(:,sniff_idx));
        mean_rate_odor = nanmean(all_sp_rate(:,sniff_idx));
        % pre-odor baseline
        sniff_idx_bl = neurons_odors(neuron,1,1).inh1_idx+preOdorSniff;
        mean_count_odor_bl = nanmean(all_sp_cnt(:,sniff_idx_bl));
        std_count_odor_bl = nanstd(all_sp_cnt(:,sniff_idx_bl));
        mean_rate_odor_bl = nanmean(all_sp_rate(:,sniff_idx_bl));   
        std_rate_odor_bl = nanstd(all_sp_rate(:,sniff_idx_bl)); 
        if rate_flag
            % evoked spike rate            
            evoked_FR(neuron,odor) = mean_rate_odor - mean_rate_odor_bl;
        else
            % evoked spike count           
            evoked_FR(neuron,odor) = mean_count_odor - mean_count_odor_bl;
        end
        
    end  
end

end

