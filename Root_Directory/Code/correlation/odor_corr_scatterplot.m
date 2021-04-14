function [all_meanR, all_steR, p_bw_regions] = odor_corr_scatterplot(all_data, params)
% function plots scatter plots of regions vs 1st region or vs physicochemical space
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
%   *all_data{1}: reference region (1st region (OB) or physicochemical space)
%   params: struct with fields:
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
%           corr_type: e.g. Pearson, Spearman, Kandell
%           corr_range: range of correlations for display in heat map 
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

if ~isfield(params, 'multi_bins_flag')
    params.multi_bins_flag = 0;
end
if ~isfield(params, 'entire_sniff_flag')
    params.entire_sniff_flag = 0;
end

% choose correlation function
if params.multi_bins_flag == 0
    if isfield(params, 'mean_trials') && params.mean_trials == 0
        corr_func = @odor_corr_trials_vector;
    else
        corr_func = @odor_corr_vector;
    end
else
    corr_func = @odor_corr_multi_bins;
end


if isfield(params, 'exclude_inhibition_flag')
    exclude_inhibition_flag = params.exclude_inhibition_flag;
end

if ~isfield(params, 'mol_ref_flag') || params.mol_ref_flag == 0
    sim_ref_vec = corr_func(all_data{1}, params);
    ref_name = all_data{1}.name;
    mol = false;
else
    sim_ref_mat = molSimCorr(params.dataset_name);
    sim_ref_vec = upperRightTriAsVector(sim_ref_mat);
    ref_name = 'Mol.';
    mol = true;
end

if mol && isfield(params, 'show_diff') && params.show_diff == 1
    figs = figure; hold on;
else
    figs = [];
end


for ii=1:length(all_data)

    if isfield(params, 'exclude_inhibition_flag')
        if ii == 1
            params.exclude_inhibition_flag = 0;
        else
            params.exclude_inhibition_flag = exclude_inhibition_flag;
        end
    end
 
    [all_vecR{ii}, vecP, all_meanR{ii}, stdR, all_matR{ii}, matP] = corr_func(all_data{ii}, params);
    all_steR{ii} = stdR / sqrt(length(all_vecR{ii}));
    if ii > 1
       if mol && isfield(params, 'show_diff') && params.show_diff == 1
           vec = all_vecR{ii} - all_vecR{1};
           ylabel('Correlation difference');
           xlabel('Physicochemical corr.');
       else
          figs(end+1) = figure('Name', [ref_name ', ' all_data{ii}.name]); hold on;
           vec = all_vecR{ii};
           ylabel(['Odor correlations in ' all_data{ii}.name]);
           xlabel(['Odor correlations in ' all_data{1}.name]);
       end
       scatter(sim_ref_vec, vec, 'LineWidth', 2, 'MarkerEdgeColor', all_data{ii}.color, 'MarkerFaceColor', all_data{ii}.color);
       [h, p_bw_regions(ii), ci, stats] = ttest(sim_ref_vec, all_vecR{ii}); %, 0.05, 'left', 'unequal'); 
    end   
end

for f = figs
    figure(f);
    legend off
    ax = gca;
    ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
    if ~(mol && isfield(params, 'show_diff') && params.show_diff == 1)
        xlim([0 0.8]); ylim([0 0.8]);
        x_lim = xlim;
        xticks = x_lim(1):(x_lim(2)-x_lim(1))/2:x_lim(2);
        set(gca, 'XTick', xticks, 'XTickLabel', xticks);
        plot(x_lim(1):0.01:x_lim(2), x_lim(1):0.01:x_lim(2), 'k');
    end
    y_lim = ylim;
    set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2); 
    axis square
    hold off
    box off
end

end

