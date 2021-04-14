function [neuronsSparsenessTR] = lifetimeSparsenessTRInRegion(neuronsFiringRate)
% input:
%           neuronsFiringRate: (#neurons x #odors) firing rate of each
%                               neuron for each odor  
% output:
%           neuronsSparsenessTR: Treves-Rolls sparse index for each neuron
%           See sparsenessTR for explanation of sparseness measure.

numNeurons = size(neuronsFiringRate,1);
neuronsSparsenessTR = zeros(numNeurons,1);
for neuron=1:numNeurons
    s = sparsenessTR(neuronsFiringRate(neuron,:));
    neuronsSparsenessTR(neuron) = s;
end

end

