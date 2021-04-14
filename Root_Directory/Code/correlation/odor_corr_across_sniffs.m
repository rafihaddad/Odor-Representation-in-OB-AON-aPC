function [all_meansR, all_steR] = odor_corr_across_sniffs(all_data, params)
% function plots mean odor correlation across sniffs for each region
% input: 
%   all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%   *all_data{1}: reference region (usually OB)
%   params: struct with fields:
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag = 1: spike rate in sniff, 0: spike count in sniff
%           corr_type: e.g. Pearson, Spearman, Kandell 
%           sniffs: array of sniffs to calculate odor correlations in
%           (NOTE: 1st sniff post odor onset is marked by 1)
%           pre_sniff (optional): pre-odor sniff baseline for post-odor
%           sniffs, if baseline is pre-odor and not blank
%           preodor_bl_flag: (optional): 
%               1: always use pre-odor sniff baseline; 
%               0: use blank baseline when available
% output:
%   all_meansR: for each region, mean odor correlation across sniffs
%   all_steR: for each region, ste of odor correlation across sniffs


params.entire_sniff_flag = 1;
if isfield(params, 'pre_sniff')
    pre_sniff_org = params.pre_sniff;
else
    pre_sniff_org = -1;
end
% choose correlation function
if ~isfield(params, 'multi_bins_flag') || params.multi_bins_flag == 0
    corr_func = @odor_corr_vector;
else
    corr_func = @odor_corr_multi_bins;
end

font_size = 20;
figure; hold on;
all_meansR = {};
all_vecR = {};

for ii=1:length(all_data)
    data = all_data{ii};
    all_meansR{ii} = [];
    all_vecR{ii} = {};
    for jj=1:length(params.sniffs)
        sniff = params.sniffs(jj);
        params.post_sniff = sniff;
        if params.post_sniff > 0
            params.pre_sniff = pre_sniff_org;
        else
            params.pre_sniff = sniff - 1;
        end
        [all_vecR{ii}{jj}, vecP, all_meansR{ii}(jj), stdR, matR, matP] = corr_func(data, params);
        all_steR{ii}(jj) = stdR/sqrt(length(vecP));
        [h, p_bw_regions] = ttest(all_vecR{1}{jj}, all_vecR{ii}{jj});
        text(sniff-0.1, all_meansR{ii}(jj)+0.01, p_mark(p_bw_regions), 'FontSize', font_size);
    end
    plot(params.sniffs, all_meansR{ii}, 'color', data.color);    
    errorbar(params.sniffs, all_meansR{ii}, all_steR{ii}, 'color', data.color);
end

x_lim = xlim;
y_lim = ylim;
if x_lim(1) < 0
    plot([0 0], ylim, 'k');
end
y_lim_new = ylim;
if y_lim(2) ~= y_lim_new(2)
    y_lim = y_lim_new;
    plot([0 0], ylim, 'k');
end
if y_lim(1) < 0 && y_lim(2) > 0
    yticks = 0:y_lim(end)/2:y_lim(end);
else
    yticks = y_lim(1):(y_lim(end)-y_lim(1))/2:y_lim(end);
end
set(gca, 'YTick', yticks);
if y_lim(1) < 0
    plot(xlim, [0 0], 'k--');
end
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2); 
ylabel('Odor pair correlations');
xlabel('# sniff');
set(gca, 'fontSize', font_size);
axis square
hold off
box off

end

