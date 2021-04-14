function [odorsSparsenessTR] = populationSparsenessTRInRegion(neuronsFiringRate)
% input:
%           neuronsFiringRate: (#neurons x #odors) firing rate of each
%                               neuron for each odor   
% output:
%           neuronsSparsenessTR: Treves-Rolls sparse index for each odor
%           See sparsenessTR for explanation of sparseness measure.

numOdors = size(neuronsFiringRate,2);
odorsSparsenessTR = zeros(numOdors,1);
for odor=1:numOdors
    s = sparsenessTR(neuronsFiringRate(:,odor));
    odorsSparsenessTR(odor) = s;
end

end

