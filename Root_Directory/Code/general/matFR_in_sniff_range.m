function [mat_FR] = matFR_in_sniff_range(neurons, start_sniff_phase, end_sniff_phase, rate_flag)
% input: 
%       neurons = neurons datastruct (#neurons x #odors x #trials)
%                   with fields: times, inh, inh1_idx
%       start_sniff_phase = index + phase of start start of sniff range
%                           (e.g. 1.6)
%       end_sniff_phase = index + phase of sniff end of sniff range (bin
%                         will be up to inhalation of this sniff index +
%                         phase) (e.g. 2.6)
%       rate_flag = 1: spike rate in sniff, 0: spike count in sniff
%                   OPTIONAL. Default: rate_flag = 1
% output: 
%       mat_FR = matrix (#neurons x #odors x #trials): 
%                firing rate or count in sniff range

if nargin < 4
    rate_flag = 1;
end

start_sniff = floor(start_sniff_phase);
start_phase = start_sniff_phase - start_sniff;
end_sniff = floor(end_sniff_phase);
end_phase = end_sniff_phase - end_sniff;

[num_neurons, num_odors, num_trials] = size(neurons);

mat_FR = NaN(num_neurons, num_odors, num_trials);

for neuron=1:num_neurons
    for odor = 1:num_odors
        for trial = 1:num_trials
            d = neurons(neuron,odor,trial);
            st = d.times;
            if isnan(st)
                continue;
            end       
            
            % start time of bin
            start_sniff_time = d.inh(d.inh1_idx + start_sniff);
            start_sniff_dur = d.inh(d.inh1_idx + start_sniff + 1) - start_sniff_time;
            start_time = start_sniff_time + (start_phase * start_sniff_dur);
            % end time of bin
            end_sniff_time = d.inh(d.inh1_idx + end_sniff);
            end_sniff_dur = d.inh(d.inh1_idx + end_sniff + 1) - end_sniff_time;
            end_time = end_sniff_time + (end_phase * end_sniff_dur);
            
            % find spike rate in bin
            sp_cnt = length(st(st >= start_time & st < end_time));
            if rate_flag
                sp_rate = sp_cnt / (end_time - start_time);
                mat_FR(neuron,odor,trial) = sp_rate;
            else
                mat_FR(neuron,odor,trial) = sp_cnt;
            end
        end
    end
end

end