function [KDF, KDFt, KDFe] = neuron_psth_odor(neuron, odor, data, PST, KernelSize, color)
% PSTH of 1 neuron, and 1 odor
% input:
%       neuron: index of neuron
%       odor: index of odor
%       data: struct of size #neurons x #odors x #trials, with fields: times
%       PST: time interval
%       KernelSize: std dev of Gaussian
% output:
%       KDF: rate (spikes per sec)
%       KDFt: times (times of rates)
%       KDFe: errors (standard error)

KDF = []; KDFt = []; KDFe = [];

[RA] = GetRaster(neuron, odor, data);
if isempty(RA)
    return;
end
% psth
[KDF, KDFt, KDFe] = mypsth(RA,KernelSize,color,PST);

end

