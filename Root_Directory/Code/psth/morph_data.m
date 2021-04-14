function [datasets_morphed] = morph_data(datasets, morphType, neurons, newSniffDur, newInhDur)
% input:
%       datasets: cell array of database structs:
%                 each of size #neurons x #odors x #trials,
%                 with fields: times
%       morphType: 
%                 * 'full_breath_cycle': morph spikes according to newSniffDur                                        
%                 * 'in_ex_separately': morph spikes in inhale according to
%                    newInhDur and spikes in exhale according to newExhDur
%       neurons: neurons to morph in databases. If empty or nan, default is 
%                all neurons
%       newSniffDur: duration of morphed sniff. If empty or nan, default is 
%                    all median of all sniff durations in all databases
%       newInhDur: duration of morphed inhalation. If empty or nan, default  
%                  is all median of all inhalation durations in all databases
% output: 
%       datasets_morphed: same as datasets, but with morphed sniff times
%                         and spike times

datasets_morphed = {};

% find mean inhale and sniff
if (isempty(newSniffDur) || isnan(newSniffDur)) && (isempty(newInhDur) || isnan(newInhDur))
    % find median inhale and sniff of all datasets
    sniff_dur = [];
    inh_dur = [];
    for ii=1:length(datasets)
        data = datasets{ii};
         [num_neurons, num_odors, num_trials] = size(data);
        for neuron=1:num_neurons
            for odor=1:num_odors
                for trial=1:num_trials
                    d = data(neuron,odor,trial);
                    sniff_dur = [sniff_dur (d.inh(2:end) - d.inh(1:end-1))];
                    inh_dur = [inh_dur (d.exh(1:end) - d.inh(1:end))];
                end
            end
        end
    end
    newSniffDur = nanmedian(sniff_dur);
    newInhDur = nanmedian(inh_dur);
end
newExhDur = newSniffDur - newInhDur;

% morph sniff times & spike times

if isempty(neurons) || isnan(neurons)
    all_neurons_flag = 1;
else
    all_neurons_flag = 0;
end

for ii=1:length(datasets)
    data = datasets{ii};
    data_morphed = data;
    
    [num_neurons, num_odors, num_trials] = size(data);
    
    if all_neurons_flag
        % morph all neurons
        neurons = 1:num_neurons;
    end
    for neuron=neurons
        for odor=1:num_odors
            for trial=1:num_trials
                d = data(neuron,odor,trial);
                
                % morph sniff times
                
                data_morphed(neuron,odor,trial).inh = (0:newSniffDur:newSniffDur*length(d.inh)) - newSniffDur*(length(d.inh(1:d.inh1_idx))-1);
                data_morphed(neuron,odor,trial).exh = newInhDur + (0:newSniffDur:newSniffDur*length(d.inh)) - newSniffDur*(length(d.inh(1:d.inh1_idx))-1);
                
                d_m = data_morphed(neuron,odor,trial);
                
                % morph spike times
                
                t = d.times;
                t_m = NaN(1,length(t));
                for i = 1:length(t)
                    
                    % find the sniff the spike is in
                    sniffIndx = find(t(i) > d.inh);
                    if isempty(sniffIndx), continue; end
                    sniffIndx = sniffIndx(end);
                    if sniffIndx >= length(d.exh), continue; end
                    
                    % morph according to phase of spike
                    switch(lower(morphType))
                        case{'full_breath_cycle'}
                            spikePhase = (t(i) - d.inh(sniffIndx))/(d.inh(sniffIndx+1) - d.inh(sniffIndx));
                            t_m(i) = d_m.inh(sniffIndx)+(spikePhase*newSniffDur);
                            % handle inhaltaion and exchalation differently
                        case{'in_ex_separately'}
                            if t(i) < d.exh(sniffIndx)
                                % spike is in inhale
                                spikePhase = (t(i) - d.inh(sniffIndx))/(d.exh(sniffIndx) - d.inh(sniffIndx));
                                t_m(i) = d_m.inh(sniffIndx)+(spikePhase*newInhDur);
                            else
                                % spike is in exhale
                                spikePhase = (t(i) - d.exh(sniffIndx))/(d.inh(sniffIndx+1) - d.exh(sniffIndx));
                                t_m(i) = d_m.exh(sniffIndx)+(spikePhase*newExhDur);
                            end
                    end
                end
                data_morphed(neuron,odor,trial).times = t_m;
            end
        end
    end
    datasets_morphed{ii} = data_morphed;
end
end

