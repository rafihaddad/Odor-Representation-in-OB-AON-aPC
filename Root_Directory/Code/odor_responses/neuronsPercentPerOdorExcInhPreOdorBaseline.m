function [excNeuronsPerOdor,avgExc,sdExc,inhNeuronsPerOdor,avgInh,sdInh] = neuronsPercentPerOdorExcInhPreOdorBaseline(neurons_odors, preOdorSniff, postOdorSniff, rate_flag)
% input:
%        neurons: neurons datastruct (#neurons x #odors x #trials) 
%                 with fields: times, inh, exh, inh1_idx
%        preOdorSniff: pre-odor sniff baseline
%        postOdorSniff: post-odor sniff in which to evaluate response
%        rate_flag = determine response by:
%                   1: spike rate in sniff
%                   0: spike count in sniff
% output:
%       excNeuronsPerOdor: percentage of excited neurons per odor
%       avgExc: average percentage of excited neurons per odor
%       sdExc: standard deviation of percentage of excited neurons per odor
%       inhNeuronsPerOdor: percentage of inhibited neurons per odor
%       avgInh: average percentage of inhibited neurons per odor
%       sdInh: standard deviation of percentage of inhibited neurons per odor 
% Note: response is determined according to pre-odor baseline

% matrix of #neurons x #odors: 1: response; 0: no response
[responses, responses_pvals] = responses_preodor_baseline(neurons_odors, preOdorSniff, postOdorSniff, rate_flag);
% matrix of #neurons x #odors: evoked activity in postOdorSniff
[evoked_FR] = evoked_FR_preodor_baseline(neurons_odors, preOdorSniff, postOdorSniff, rate_flag);

% calculate percentage of neurons that respond with excitation or
% inhibition to odors
[excNeuronsPerOdor,avgExc,sdExc,inhNeuronsPerOdor,avgInh,sdInh] = neuronsPercentPerOdorExcInh(responses, evoked_FR);

end

