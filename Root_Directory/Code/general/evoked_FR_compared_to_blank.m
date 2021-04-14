function [evoked_FR] = evoked_FR_compared_to_blank(neurons_odors, neurons_blank, postOdorSniff, rate_flag)
% input:
%           neurons_odors = neurons odors datastruct (#neurons x #odors x #trials) 
%           with fields: times, inh, exh, inh1_idx
%           neurons_blank = neurons blank datastruct (#neurons x 1 x #trials) 
%           with fields: times, inh, exh, inh1_idx
%           postOdorSniff = # sniff post 1st inh post odor onset (e.g. 1, 2,...). 
%                           NOTICE: 1st sniff is 1 (not 0)
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
% output: 
%           evoked_FR: (#neurons x #odors) firing rate of each neuron for
%                       each odor (baseline is activity in response to blank)

if nargin < 4
    rate_flag = 0;
end

[num_neurons, num_odors, ~] = size(neurons_odors);
evoked_FR = NaN(num_neurons, num_odors);

for neuron=1:num_neurons
    % blank data
    trials_blank = neurons_blank(neuron,:);
    [all_sp_cnt_blank, all_sp_rate_blank] = trial_sniff_firing(trials_blank);
    all_sp_cnt_blank = all_sp_cnt_blank(~all(isnan(all_sp_cnt_blank),2),:);
    all_sp_rate_blank = all_sp_rate_blank(~all(isnan(all_sp_rate_blank),2),:);
    if isempty(all_sp_cnt_blank)  
        continue;   % all trials are invalid (NaN)
    end
    sniff_idx_blank = neurons_blank(neuron,1,1).inh1_idx+postOdorSniff-1;
    mean_count_blank = nanmean(all_sp_cnt_blank(:,sniff_idx_blank));
    std_count_blank = nanstd(all_sp_cnt_blank(:,sniff_idx_blank));
    mean_rate_blank = nanmean(all_sp_rate_blank(:,sniff_idx_blank));
    std_rate_blank = nanstd(all_sp_rate_blank(:,sniff_idx_blank));
    for odor=1:num_odors
        % odor data
        trials = squeeze(neurons_odors(neuron,odor,:));
        [all_sp_cnt, all_sp_rate] = trial_sniff_firing(trials);
        all_sp_cnt = all_sp_cnt(~all(isnan(all_sp_cnt),2),:);
        all_sp_rate = all_sp_rate(~all(isnan(all_sp_rate),2),:);
        if isempty(all_sp_cnt)  
            continue;   % all trials are invalid (NaN)
        end
        sniff_idx = neurons_odors(neuron,1,1).inh1_idx+postOdorSniff-1;
        % mean of activity in postOdorSniff
        mean_count_odor = nanmean(all_sp_cnt(:,sniff_idx));
        mean_rate_odor = nanmean(all_sp_rate(:,sniff_idx));          
        if rate_flag
            % evoked spike rate
            evoked_FR(neuron,odor) = mean_rate_odor - mean_rate_blank;
        else
            % evoked spike count
            evoked_FR(neuron,odor) = mean_count_odor - mean_count_blank;
        end
        
    end  
end

end

