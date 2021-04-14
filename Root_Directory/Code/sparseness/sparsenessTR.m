function [s_m] = sparsenessTR(responses)
% input:
%           responses: avg. firing rates
%                      1. for lifetime sparsness: 1 x #odors
%                      2. for population sparsness: 1 x #neurons  
% ouput:
%           sparseIndex: modified Treves-Rolls sparse index of neuron
%                        (lifetime sparseness)/ odor (population sparsness)
% measure of sparseness: Treves-Rolls
% s = [(sum(ri))/n]^2/[(sum(ri^2))/n]
% modification: Willmore & Tolhurst:
% s_m = 1 - [(sum(|ri|))/n]^2/[(sum(ri^2))/n]
% further modification so that values are between 0 and 1:
% s_m = s_m / (1-1/n)
% => lifetime sparseness:
% proportion of stimuli to which the neuron responds to strongly
% *sparse: sparse index close to 1 => long tail to the distribution,
%    which means that the neuron responds to few odors with large magnitude 
% *dense: sparse index close to 0: neuron responds to all stimuli
% => population sparseness:
% proportion of neurons that respond strongly to odor
% *sparse: sparse index close to 1 => long tail to the distribution,
%    which means that few neurons respond with large magnitude to odor 
% *dense: sparse index close to 0: all neurons respond to odor

responses(find(responses == Inf)) = NaN;
n = length(responses);
sumR = nansum(abs(responses));
numerator = power((sumR / n),2);
respSquared = power(responses,2);
denominator = nansum(respSquared)/ n;
s = numerator / denominator;
s_m = 1 - s;
s_m = s_m / (1-1/n);

end