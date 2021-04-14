function [all_means, all_ste, all_p_bw_regions, p_low_high] = odor_corr_similar_odors_vs_nonsimilar_odors(all_data,params)
% plots bar graph of mean odor-pair correlations in each region for odor
% pairs that are dissimilar in OB/physicochemical space and odor-pairs that
% are similar in OB/physicochemical space
% input: 
%   all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%           non_inh_flag (optional, can use for cortex, and only if entire_sniff_flag = 1): 
%               1: only use neurons that weren't inhibited
%               0: use all neurons
%   *all_data{1}: reference region (usually OB)
%   params: struct with fields:
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
%           corr_type: e.g. Pearson, Spearman, Kandell
%           mol_ref_flag: 1: compare regions to physicochemical space, 0:
%           compare to first region on list (OB)
%           database_name (for mol_ref_flag = 1): name of database (e.g. Mor, Bolding)
%           show_diff (optional): show difference between cortical
%           correlations and 1st region (OB) correlations
%           entire_sniff_flag: 1: correlation between FR in entire sniff
%                              0: correlation between FR in sniff
%                              phase/range
%           1. If entire_sniff_flag = 1:
%              *post_sniff: post odor sniff of which to evaluate response corr (1st is 1, not 0)
%              *pre_sniff (if baseline is preodor sniff): pre odor sniff to be used as baseline
%           2. If entire_sniff_flag = 0:
%              *start_sniff_phase: index + phase of sniff start of sniff range (e.g. 0.6)
%              *end_sniff_phase: index + phase of sniff end of sniff range (bin
%                   will be up to inhalation of this sniff index + phase) (e.g. 2.6) 
%              *pre_end_sniff_phase (if baseline is pre-odor activity): index + phase of end of baseline sniff range
% output:
%   all_means: mean correlations in regions for each category. 
%              row 1: dissimilar pairs, row 2: similar pairs
%              columns by the order of the regions in all_data
%   all_ste: standard error of correlations in regions for each category. 
%            same organization as all_means 
%   all_p_bw: p values of t test between regions and first region
%            same organization as all_means
%   p_low_high: p value for each region comparing similar to dissimilar
%   odors


if ~isfield(params, 'multi_bins_flag')
    params.multi_bins_flag = 0;
end
if ~isfield(params, 'entire_sniff_flag')
    params.entire_sniff_flag = 0;
end

% choose correlation function
if params.multi_bins_flag == 0
    corr_func = @odor_corr_vector;
else
    corr_func = @odor_corr_multi_bins;
end


for ii=1:length(all_data)
    [all_vecR{ii}, vecP, all_meanR{ii}, stdR, matR, matP] = corr_func(all_data{ii}, params);
end

if ~isfield(params, 'mol_ref_flag') || params.mol_ref_flag == 0
    sim_ref_vec = all_vecR{1};
else
    sim_ref_mat = molSimCorr(params.dataset_name);
    sim_ref_vec = upperRightTriAsVector(sim_ref_mat);
end

% compute corr between regions for odor pairs with high & low corr in OB
cutoff = nanmedian(sim_ref_vec);
low_idx = find(sim_ref_vec < cutoff);
high_idx = find(sim_ref_vec >= cutoff);
mean_corr_low = []; mean_corr_high = [];
colors = [];

for ii=1:length(all_data)
    [h, p_bw_regions_low(ii)] = ttest(sim_ref_vec(low_idx), all_vecR{ii}(low_idx));
    [h, p_bw_regions_high(ii)] = ttest(sim_ref_vec(high_idx), all_vecR{ii}(high_idx));
    [h, p_low_high(ii)] = ttest2(all_vecR{ii}(low_idx), all_vecR{ii}(high_idx));
    colors(ii,:) = all_data{ii}.color;
end

if isfield(params, 'show_diff') && params.show_diff == 1
    y_label = 'Correlation difference';
    diffs_low = []; diffs_high = [];
    for ii=2:length(all_data)
       diffs_low(ii,:) = all_vecR{ii}(low_idx) - all_vecR{1}(low_idx);
       mean_corr_low(ii) = mean(diffs_low(ii,:));
       ste_corr_low(ii) = std(diffs_low(ii,:))/sqrt(length(diffs_low(ii,:)));
       diffs_high(ii,:) = all_vecR{ii}(high_idx) - all_vecR{1}(high_idx);
       mean_corr_high(ii) = mean(diffs_high(ii,:));
       ste_corr_high(ii) = std(diffs_high(ii,:))/sqrt(length(diffs_high(ii,:)));       
    end
else 
    y_label = 'Odor pair correlations';
    for ii=1:length(all_data)
        mean_corr_low(ii) = mean(all_vecR{ii}(low_idx));
        ste_corr_low(ii) = std(all_vecR{ii}(low_idx))/sqrt(length(all_vecR{ii}(low_idx)));
        mean_corr_high(ii) = mean(all_vecR{ii}(high_idx));
        ste_corr_high(ii) = std(all_vecR{ii}(high_idx))/sqrt(length(all_vecR{ii}(high_idx)));

    end
    if isfield(params, 'mol_ref_flag') && params.mol_ref_flag == 1
        mean_corr_low = [nanmean(sim_ref_vec(low_idx)) mean_corr_low];
        ste_corr_low =  [nanstd(sim_ref_vec(low_idx))/sqrt(length(sim_ref_vec(low_idx))) ste_corr_low];
        mean_corr_high = [nanmean(sim_ref_vec(high_idx)) mean_corr_high];
        ste_corr_high =  [nanstd(sim_ref_vec(high_idx))/sqrt(length(sim_ref_vec(high_idx))) ste_corr_high];
        colors = [[0.95,0.69,0.14]; colors];
    end    
end


all_means = [mean_corr_low; mean_corr_high]; 
all_ste = [ste_corr_low; ste_corr_high];
all_p_bw_regions = [p_bw_regions_low; p_bw_regions_high];

if isfield(params, 'show_diff') && params.show_diff == 1
   all_means = all_means(:,2:end);
   all_ste = all_ste(:,2:end);
   colors = colors(2:end,:);
end

figure; hold on 
hb = bar(all_means, 'BarWidth', 0.8, 'EdgeColor', 'none');
ngroups = size(all_means, 1);
nbars = size(all_means, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, all_means(:,i), all_ste(:,i),'LineStyle', 'none', 'color', 'k');
end
x = (1:ngroups) - groupwidth/2 + (2*ceil(nbars/2)-1) * groupwidth / (2*nbars);
set(gca, 'XTick', x+0.145, 'XTickLabel', {'dissimilar', 'similar'});
for jj=1:size(all_means,2)
    set(hb(jj), 'FaceColor', colors(jj,:));
end
y_lim = ylim;
ax = gca;
ax.XAxisLocation = 'origin';
yticks = 0:y_lim(end)/2:y_lim(end);
set(gca, 'YTick', yticks, 'YTickLabel', yticks);
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2); 
ylabel(y_label);
axis square
hold off
box off
end

