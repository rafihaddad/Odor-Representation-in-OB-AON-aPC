function [excNeuronsPerOdor,avgExc,sdExc,inhNeuronsPerOdor,avgInh,sdInh] = neuronsPercentPerOdorExcInh(neuronsResponses, evoked_FR)
% input:
%       neuronsResponses: num neurons x num odors(1 - response/ 0 - no response)
%       evoked_FR: num neurons x num odors(firing rate)
% output:
%       excNeuronsPerOdor: percentage of excited neurons per odor
%       avgExc: average percentage of excited neurons per odor
%       sdExc: standard deviation of percentage of excited neurons per odor
%       inhNeuronsPerOdor: percentage of inhibited neurons per odor
%       avgInh: average percentage of inhibited neurons per odor
%       sdInh: standard deviation of percentage of inhibited neurons per odor     

[numNeurons, numOdors] = size(neuronsResponses);

excNeuronsPerOdor = zeros(1,numOdors);  %  percentage of excited neurons per odor
inhNeuronsPerOdor = zeros(1,numOdors);  %  percentage of inhibited neurons per odor
for odor=1:numOdors
    B = neuronsResponses(:,odor);
    % # excited neurons per odor
    numExc = length(find(evoked_FR(find(B),odor) > 0));
    % # inhibited neurons per odor
    numInh = length(find(evoked_FR(find(B),odor) < 0));
    % percentages
    excNeuronsPerOdor(odor) = numExc / numNeurons;
    inhNeuronsPerOdor(odor) = numInh / numNeurons;
end

avgExc = mean(excNeuronsPerOdor);   % average percentage of excited neurons per odor
sdExc = std(excNeuronsPerOdor);     % standard deviation of percentage of excited neurons per odor

avgInh = mean(inhNeuronsPerOdor);   % average percentage of inhibited neurons per odor
sdInh = std(inhNeuronsPerOdor);     % standard deviation of percentage of inhibited neurons per odor


end

