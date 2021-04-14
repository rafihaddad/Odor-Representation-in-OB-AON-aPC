function [allFR,p_ttest, p_ranksum] = FR_distribution(all_data, params)
% input:
%       all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%       params: struct with the following fields:
%               evoked_flag: 1: evoked response, 0: absolute response
%               rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%               start_sniff_phase: index + phase of sniff start of sniff range (e.g. 0.6)
%               end_sniff_phase: index + phase of sniff end of sniff range (bin
%                   will be up to inhalation of this sniff index + phase) (e.g. 2.6)
%               pre_end_sniff_phase (for evoked_flag = 1, and if baseline is pre-odor activity): 
%                           index + phase of end of baseline sniff range
%               title: title of graph

figure;
hold on;

p_ttest = [];
p_ranksum = [];
paramsFR = params;
all_means = [];
all_ste = [];
means = zeros(1,length(all_data));
all_names = {};

for ii=1:length(all_data)
    colors{ii} = all_data{ii}.color;
    all_names{ii} = all_data{ii}.name;
    
    if params.rate_flag == 0 
        % take average spike count per sniff
        y_label = 'Spike count per sniff';
        sniffs = params.start_sniff_phase:1:(params.end_sniff_phase-1);
        matFRsniff = NaN(length(sniffs), size(all_data{ii}.data,1), size(all_data{ii}.data,2), size(all_data{ii}.data,3));
        for jj = 1:length(sniffs)
            paramsFR.start_sniff_phase = sniffs(jj);
            paramsFR.end_sniff_phase = sniffs(jj) + 1;
            matFRsniff(jj,:,:,:) = get_mat_fr_phase_3d(all_data{ii}, paramsFR);
        end
        matFR = squeeze(nanmean(matFRsniff,1));
    else
        y_label = 'Firing rate (Hz)';
        matFR = get_mat_fr_phase_3d(all_data{ii}, params);
    end
    FR = matFR(:);
    allFR.(all_data{ii}.name) = FR;
    all_means(ii) = nanmean(FR);
    all_ste(ii) = nanstd(FR) / sqrt(length(FR));
    means(ii) = all_means(ii);
    bar(means, 0.5, 'FaceColor', all_data{ii}.color, 'EdgeColor', 'none');
    means(ii) = 0;
    [h, p_ttest(ii)] = ttest2(allFR.(all_data{1}.name), FR);
    [p_ranksum(ii), h] = ranksum(allFR.(all_data{1}.name), FR);
end

errorbar(1:length(all_data), all_means, all_ste,'LineStyle', 'none', 'color', 'k', 'LineWidth', 0.1);
set(gca, 'XTick', 1:length(all_means), 'XTickLabel', all_names);
ylabel(y_label);
title(params.title);
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
y_lim = ylim;
yticks = y_lim(1):(y_lim(2)-y_lim(1))/2:y_lim(2);
set(gca, 'YTick', yticks);
axis square
box off; hold off;  

end

