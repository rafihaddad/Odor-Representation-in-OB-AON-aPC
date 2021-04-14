function [successRate] =  leave_1_out_decoder(labels, data, label_ids, num_trials, dist_type)
% run a leave one out decoding analysis.
% input:
%   labels: odor identity for each cell-odor pair
%   data: struct array with field:
%      features: firing rates of trials corresponding to the cell-odor pair in
%   labels
%   label_ids: array of unique labels
%   num_trials: # trials to use from features (first # trials will be used)
%   dist_type: distance measure for decoding
% Algorithm:
%   select a trial and remove it from the matrix. keep it at testTrial
%   compute the center of each label
%   compute the distance between testTrial and the centers
%   set the label of the testTrial to the label it is closest too
% output:
%   successRate: proportion of correct classifications

if nargin < 5
    dist_type = 'euclidean';
end

if size(labels,1) > 1 & size(labels,2) > 1
    error('labels should be a columns vector')
end
if size(labels,2) > 1, labels = labels'; end
if size(data,2) > 1, data = data'; end

if size(labels,1) ~=  size(data,1)
    error('labels and features should have the same number of samples')
end

num_indxs = length(find(labels == label_ids(1)));
s=0; % counter for correct classifications
c=0; % counter for total classifications

for reps=1:100  
    for labelTestIndx = label_ids
        leaveOneFr=NaN(1,num_indxs);
        labelCenterAll = NaN(length(label_ids),num_indxs);
        ll = 1; 
        for labelId = label_ids
            labelCenter=NaN(1,num_indxs);                                
            indx = find(labels == labelId)';
            jj=1;
            for ii=indx
                fr = data(ii).features;
                fr=fr(1:min(num_trials,length(fr)));
                if labelId == labelTestIndx
                    leaveOneIndx = randperm(length(fr),1);
                    leaveOneFr(jj) = fr(leaveOneIndx);
                    fr(leaveOneIndx) = []; % remove the sample 
                end
                % compute the mean of the reamining samples
                labelCenter(jj) = mean(fr);
                jj = jj + 1;
            end
            labelCenterAll(ll,:) = labelCenter;
            ll = ll + 1;
        end
        dall = NaN(1,size(labelCenterAll,1));
        for i=1:size(labelCenterAll,1)
            d = pdist2(labelCenterAll(i,:), leaveOneFr, dist_type);
            dall(i) = d;
        end
        [a,b]=min(dall);
        if label_ids(b) == labelTestIndx
            s=s+1;
        end
        c=c+1;
    end
end
successRate = s/c
