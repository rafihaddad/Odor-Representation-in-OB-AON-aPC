function [RA] = GetRaster(neuron, odor, data)
% input:
%       neuron: index of neuron
%       odor: index of odor
%       data: struct of size #neurons x #odors x #trials, with fields: times
% output: 
%       RA: struct of length of trials, with field times: raster aligned spike times

trials = squeeze(data(neuron, odor, :));
RA_temp = cell2struct({trials.times}, {'times'}); 
% delete NaN or empty trials
f = fieldnames(RA_temp);
struct_f(1:2:2*length(f)) = f;
RA = struct(struct_f{:}, []);
for trial = 1:length(RA_temp)
    if all(isnan(RA_temp(trial).times)) || (isempty(RA_temp(trial).times))
        continue;
    else
        RA(trial) = RA_temp(trial);
    end
end      
if length(find(arrayfun(@(RA) isempty(RA.times),RA))) == length({RA.times})
    %  all trials are empty
    RA = [];
    return;
end

end

