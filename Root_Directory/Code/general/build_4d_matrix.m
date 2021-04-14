function [inh1_idx, neurons_matrix_cnt, neurons_matrix_rate] = build_4d_matrix(neurons)
% input: neurons = neurons datastruct (#neurons x #odors x #trials) 
%                  with fields: times, inh, exh, inh1_idx
% output: 
%           inh1_idx: index of 1st sniff post odor
%           neurons_matrix_cnt (#neurons x #odors x #trials x #sniffs): spike count in sniff
%           neurons_matrix_rate (#neurons x #odors x #trials x #sniffs): spike rate in sniff


[num_neurons, num_odors, num_trials] = size(neurons);
inh1_idx = neurons(1,1,1).inh1_idx;

num_sniffs = length(neurons(1,1,1).inh)-1;
neurons_matrix_cnt = NaN(num_neurons, num_odors, num_trials, num_sniffs);
neurons_matrix_rate = NaN(num_neurons, num_odors, num_trials, num_sniffs);

for neuron=1:num_neurons
    for odor=1:num_odors
        trials = squeeze(neurons(neuron,odor,:));
        [sp_cnt_all_sniffs, sp_rate_all_sniffs] = trial_sniff_firing(trials);
        neurons_matrix_cnt(neuron, odor, :, :) = sp_cnt_all_sniffs;
        neurons_matrix_rate(neuron, odor, :, :) = sp_rate_all_sniffs;
    end
end

end

