function [neurons_odors_responses, neurons_odors_responses_pvals] = responses_ks_blank_bl(neurons_odors, neurons_blank, post_sniff)

if post_sniff > 0, post_sniff = post_sniff - 1; end

[num_neurons, num_odors, num_trials] = size(neurons_odors);
neurons_odors_responses = NaN(num_neurons, num_odors);
neurons_odors_responses_pvals = NaN(num_neurons, num_odors);
for neuron=1:num_neurons
    for odor=1:num_odors
        ts = [];
        for trial=1:num_trials
            DT = neurons_odors(neuron, odor, trial);
            sniff_dur = DT.inh(DT.inh1_idx + post_sniff + 1) - DT.inh(DT.inh1_idx + post_sniff);
            % stimulus
            ts_trial = DT.times(DT.inh(DT.inh1_idx + post_sniff) < DT.times & DT.times < DT.inh(DT.inh1_idx + post_sniff + 1));
            ts_trial = (ts_trial - DT.inh(DT.inh1_idx + post_sniff))/sniff_dur;
            ts = [ts, ts_trial'];
        end
        tc = [];
        for trial=1:size(neurons_blank,3)
            % control
            DTC = neurons_blank(neuron, 1, trial);
            sniff_dur_C = DTC.inh(DT.inh1_idx + post_sniff + 1) - DTC.inh(DTC.inh1_idx + post_sniff);
            tc_trial = DTC.times(DTC.inh(DTC.inh1_idx + post_sniff) < DTC.times & DTC.times < DTC.inh(DTC.inh1_idx + post_sniff + 1));
            tc_trial = (tc_trial - DTC.inh(DTC.inh1_idx + post_sniff))/sniff_dur_C;
            tc = [tc, tc_trial'];
        end
        if ~isempty(ts) && ~isempty(tc) 
            [h,p,ks2stat] = kstest2(tc, ts, 0.05);  
            neurons_odors_responses_pvals(neuron,odor) = p;
            neurons_odors_responses(neuron,odor) = h;   
        else
            neurons_odors_responses(neuron,odor) = 0;            
        end
    end
end

perc = nansum(neurons_odors_responses)/num_neurons
mean(perc)

end
