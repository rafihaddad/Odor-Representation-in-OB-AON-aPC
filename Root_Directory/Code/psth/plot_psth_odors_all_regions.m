function [] = plot_psth_odors_all_regions(all_data, neuronIndices, odors, params, yMaxs, odor_names)
% input:
%       all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           name: name of region
%           color: color for plot
%       neuronIndices: cell array of ids of each example neuron in each
%       region (in the order of the regions)
%       odors: array of ids of example odors (all odors will be shown for
%       each neuron)
%       params:
%           PST: time interval
%           KernelSize: std dev of Gaussian
%           morph_flag: 1: morph sniff times and spike times; 0: don't morph
%           morphType: required if morph_flag == 1:
%                       * 'full_breath_cycle': morph spikes according to
%                          median sniff duration
%                       * 'in_ex_separately': morph spikes in inhale
%                           according to median inhalation duration,
%                           and spikes in exhale according to median
%                           exhalation duration
%       yMaxs: cell array of max value on y axis for each region (same
%           order as regions)
%       odor_names: names of odors in the order of 'odors' parameter

all_databases = {};
for ii=1:length(all_data)
    all_databases{ii} = all_data{ii}.data;
end
if params.morph_flag == 1
    % morph spike times and respiration times according to same standarized sniff duration for all databases
    all_databases = morph_data(all_databases, params.morphType, [], NaN, NaN);
end
params.morph_flag = 0;

for ii=1:length(all_data)
    plot_psth_odors(all_databases{ii}, [], neuronIndices{ii}, odors, all_data{ii}.color, params, yMaxs{ii}, odor_names);
end


end

