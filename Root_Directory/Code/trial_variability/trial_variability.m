function [all_means, all_ste, p_bw_regions] = trial_variability(all_data, params)
% plots boxplot of coefficient of variation (CV)
% input: 
%   all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%   params: struct with fields:
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
%           start_sniff_phase: index + phase of sniff start of sniff range (e.g. 0.6)
%           end_sniff_phase: index + phase of sniff end of sniff range (bin
%                   will be up to inhalation of this sniff index + phase) (e.g. 2.6) 
%           pre_end_sniff_phase (if evoked_flag = 1 and if baseline is pre-odor activity): index +
%               phase of end of baseline sniff range 
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)


% variability for all responding cell-odor pairs
for ii=1:length(all_data)
    data = all_data{ii};
    [var_all{ii}] = CV_cell_odor_pairs(data, params)';
end

all_means = zeros(1,length(var_all)); 
all_ste = zeros(1,length(var_all));
p_bw_regions = zeros(1,length(var_all));
for ii=1:length(var_all)
    all_means(ii) = nanmean(var_all{ii});
    all_ste(ii) = nanstd(var_all{ii})/sqrt(length(var_all{ii}));
    [p_bw_regions(ii), h, stats] = ranksum(var_all{1}, var_all{ii});
end

figure;
font_size = 16;
for ii=1:length(all_data)
    names{ii} = repmat({all_data{ii}.name},length(var_all{ii}),1);
end
var_cat = cat(1,var_all{:});
name_cat = cat(1,names{:});
boxplot(var_cat, name_cat, 'Widths', 0.3)
ylabel('CV', 'FontSize', font_size);
set(gca, 'FontSize', font_size);
axis square
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
box off; hold off;
end

