function [allFR,p_ttest, p_ranksum] = FR_distribution_across_sniffs(all_data, params)
% input:
%       all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (optional): blank responses data
%           name: name of region
%           color: color for plot
%       params: struct with the following fields:
%               evoked_flag: 1: evoked response, 0: absolute response
%               rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%               start_sniff_phase: index + phase of sniff start of sniff range (e.g. 0.6)
%               end_sniff_phase: index + phase of sniff end of sniff range (bin
%                   will be up to inhalation of this sniff index + phase) (e.g. 2.6)
%               pre_end_sniff_phase (require for evoked_flag = 1 and if baseline is pre-odor activity): 
%                           index + phase of end of baseline sniff range
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)


figure;
hold on;

p_ttest = [];
p_ranksum = [];
paramsFR = params;
all_means = [];
all_ste = [];
all_names = {};


for ii=1:length(all_data)
    [nn,oo,tt] = size(all_data{ii}.data);
    colors{ii} = all_data{ii}.color;
    all_names{ii} = all_data{ii}.name;
    if params.rate_flag == 0
        y_label = 'Spike count per sniff';
    else
        y_label = 'Firing rate (Hz)';
    end
    sniffs = params.start_sniff_phase:1:(params.end_sniff_phase-1);
    matFR = NaN(length(sniffs), nn, oo, tt);
    for jj = 1:length(sniffs)
        paramsFR.start_sniff_phase = sniffs(jj);
        paramsFR.end_sniff_phase = sniffs(jj) + 1;
        matFR(jj,:,:,:) = get_mat_fr_phase_3d(all_data{ii}, paramsFR);
    end
    FR = NaN(length(sniffs), nn*oo*tt);
    FR(:,:) = matFR(:,:);
    allFR.(all_data{ii}.name) = FR;
    all_means(ii,:) = nanmean(FR');
    all_ste(ii,:) = nanstd(FR') / sqrt(size(FR,2));
    for jj=1:length(sniffs)
        [h, p_ttest(ii,jj)] = ttest2(allFR.(all_data{1}.name)(jj,:), FR(jj,:));
        [p_ranksum(ii,jj), h] = ranksum(allFR.(all_data{1}.name)(jj,:), FR(jj,:));
    end
end

all_means = all_means';
all_ste = all_ste';
hb = bar(all_means, 'EdgeColor', 'none');
ngroups = size(all_means, 1);
nbars = size(all_means, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, all_means(:,i), all_ste(:,i),'LineStyle', 'none', 'color', 'k', 'LineWidth', 0.2);
end
for jj=1:size(all_means,2)
    set(hb(jj), 'FaceColor', all_data{jj}.color);
end
set(gca, 'XTick', 1:length(all_means), 'XTickLabel', sniffs + 1);
xlabel('# sniff');
ylabel(y_label);
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
y_lim = ylim;
yticks = y_lim(1):(y_lim(2)-y_lim(1))/2:y_lim(2);
set(gca, 'YTick', yticks);
axis square
box off; hold off;

end

