function [h, meanSuccessRateAll, sdSuccessRateAll] = decoding_by_num_neurons_array(all_data, params)
% Plots success rate of decoding
% input: 
%   all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%   params: struct with field:
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)                     
%           sniff_window (window for decoding)
%           pre_sniff_window_end (required if evoked_flag = 1 and using pre-odor baseline): end of pre-odor baseline window
%           num_neurons_array: array of numbers of neurons to use for decoding 
%           num_odors (optional, default: min # odors of databases): # odors to decode
%           num_trials (optional, default: min # trials of databases): # trials to use in decoding
%           num_rep:number of bootstrapping repetitions
%           dist: the distance measure for decoding algorithm
% output: 
%           h: plot handle
%           meanSuccessRateAll: for each database, mean successs rate (%) for
%           each number of neurons
%           sdSuccessRateAll: for each database, standard deviation of successs rate (%) for
%           each number of neurons

% fill in default parameters
all_num_neurons = []; for data=all_data, all_num_neurons(end+1) = size(data{1}.data,1); end % check how many neurons each dataset has   
min_neurons = min(params.num_neurons_array(end), min(all_num_neurons));  % max number of neurons to use from each dataset for decoding
params.num_neurons_array = params.num_neurons_array(params.num_neurons_array <= min_neurons);
all_num_odors = []; for data=all_data, all_num_odors(end+1) = size(data{1}.data,2); end % check how many odors each dataset has
if ~isfield(params, 'num_odors'), params.num_odors = Inf; end   
params.num_odors = min(params.num_odors,min(all_num_odors));   % number of odors to decode
all_max_trials = []; for data=all_data, all_max_trials(end+1) = size(data{1}.data,3); end % check how many trials each dataset has
if ~isfield(params, 'num_trials'), params.num_trials = Inf; end  
params.num_trials = min(params.num_trials,min(all_max_trials));   % number of trials to use for decoding

% add parameters details to figure name
figure;
param_details = ['sniff window: ' num2str(params.sniff_window(1)) '-' num2str(params.sniff_window(2)) ', ' num2str(params.num_odors) ' odors, ' num2str(params.num_trials) ' trials, ' num2str(params.num_rep) ' repetitions'];
set(gcf, 'Name', [get(gcf, 'name') ', ' param_details]);

hold on; h = [];
DB_names = {};
% run decoding on each data set
for DB=1:length(all_data)
    database = all_data{DB};
    DB_names{DB} = database.name
    meanSuccessRate = NaN(1,length(params.num_neurons_array)); 
    sdSuccessRate = NaN(1,length(params.num_neurons_array)); 
    % run decoding for each number of neurons
    for jj = 1:length(params.num_neurons_array)
        num_neurons = params.num_neurons_array(jj)
        params.num_neurons = num_neurons;     
       [meanSuccessRate(jj), sdSuccessRate(jj)] = decoding_by_num_neurons(database, params); 
    end
    meanSuccessRateAll{DB} = meanSuccessRate;
    sdSuccessRateAll{DB} = sdSuccessRate;
    if length(params.num_neurons_array) > 1
        % plot mean success rate across #neurons and standard deviation of bootstrapping repetitions
        if params.num_rep > 1
            h(end+1) = errorbar(params.num_neurons_array,meanSuccessRate,sdSuccessRate, 'color', database.color);
        else
            h(end+1) = plot(params.num_neurons_array, meanSuccessRate, 'color', database.color, 'MarkerFaceColor', database.color, 'LineWidth', 1);
        end
         plot(params.num_neurons_array, meanSuccessRate, 'o', 'color', database.color, 'MarkerFaceColor', database.color);
    end
end

font_size = 16;
if length(params.num_neurons_array) == 1
    % for decoding by one size of set of neurons, graph results in bar graph
    s = cell2mat(meanSuccessRateAll);
    h = bar(s);
    if params.num_rep > 1
        errorbar(1:length(s), s, cell2mat(sdSuccessRateAll), 'LineStyle','none'); 
    end
    set(gca, 'XTickLabel', DB_names, 'XTick', 1:length(DB_names));
else
    % for decoding across array of # neurons, edit x axis
    xlabel('# neurons', 'fontSize', font_size);     
    xlim([0 params.num_neurons_array(end)]);
    x_lim = xlim;
    xticks = x_lim(1):(x_lim(2)-x_lim(1))/5:x_lim(2);
    set(gca, 'XTick', xticks, 'XTickLabel', xticks);
    legend(h, DB_names);
end
% further graph edits
ylim([0 100]);
ylabel('Decoding success rate (%)', 'fontSize', font_size);
title('Odor Decoding Accuracy', 'fontSize', font_size);
y_lim = ylim;
yticks = y_lim(1):(y_lim(2)-y_lim(1))/2:y_lim(2);
set(gca, 'YTick', yticks, 'YTickLabel', yticks);
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2); 
axis square
% mark chance level
chance = (1/params.num_odors) * 100;
plot(xlim, [chance chance], 'k--', 'DisplayName', 'chance level');

hold off;
end




