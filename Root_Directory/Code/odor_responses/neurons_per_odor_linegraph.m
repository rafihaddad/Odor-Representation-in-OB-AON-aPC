function [percResp] = neurons_per_odor_linegraph(all_data,params)
%   input:
%   all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%   params: struct with fields:
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
%           post_sniff: post odor sniff in which to evaluate response (1st is 1, not 0)
%           pre_sniff (if baseline is preodor sniff): pre odor sniff to be used as baseline
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)

figure; hold on;
params.evoked_flag = 0; % not relevant for calculation
percResp = {}; SD = {};
for ii=1:length(all_data)
    data = all_data{ii};
    [num_neurons, num_odors, ~] = size(data.data);
    [~, matResp] = get_mat_fr(data, params);
    numResp = sum(matResp,1);
    p = numResp/num_neurons;    % proportion of respoding neurons
    percResp{ii} = p * 100;
    plot(1:num_odors, percResp{ii}, 'color', data.color, 'marker', 'o', 'markerFaceColor', data.color);
end

ylabel('Responding neurons (%)');
xlabel('Odor');
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
y_lim = ylim;
ylim([0 ceil(y_lim(2)/10)*10]);
y_lim = ylim;
yticks = y_lim(1):(y_lim(2)-y_lim(1))/2:y_lim(2);
set(gca, 'YTick', yticks);
set(gca, 'XTick', 1:num_odors);
axis square
box off; hold off;  

end

