function [avg_KDF, KDFt, avg_KDFe] = population_psth_odor(odor, data, PST, KernelSize)
% population PSTH of an odor
% input:
%       odor: index of odor
%       data: struct of size #neurons x #odors x #trials, with fields: times
%       PST: time interval
%       KernelSize: std dev of Gaussian
% output:
%       avg_KDF: avg. rate (spikes per sec) of population
%       KDFt: times (times of rates)
%       avg_KDFe: avg. errors (standard error) of population

num_neurons = size(data,1);

all_KDFs = {};
all_KDFe = {};
KDFt = [];

% get psth for each neuron
for ii_neuron=1:num_neurons   
    [KDF, KDFt, KDFe] = neuron_psth_odor(ii_neuron, odor, data, PST, KernelSize, 'n');
    if isempty(KDF)
        continue;
    end
    all_KDFs{end+1} = KDF;
    all_KDFe{end+1} = KDFe;
end

% population psth
% avg KDF
Z = cellfun(@(x)reshape(x,1,1,[]),all_KDFs,'un',0);
out = cell2mat(Z);
all_KDFs_array = squeeze(out);
avg_KDF = mean(all_KDFs_array);
% avg KDFe
Z = cellfun(@(x)reshape(x,1,1,[]),all_KDFe,'un',0);
out = cell2mat(Z);
all_KDFe_array = squeeze(out);
avg_KDFe = mean(all_KDFe_array);


end

