function [act_all, p_act, sup_all, p_sup] = perc_act_perc_supp(all_data, params)
% plots % activated and % suppressed
% input:
%       all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (optional): blank responses data
%           name: name of region
%           color: color for plot
%       params: struct with the following fields:
%           rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%           post_sniff: post odor sniff (1st is 1, not 0)
%           pre_sniff: pre-odor sniff baseline
%           preodor_bl_flag (required if data_blank exists): 1: pre-odor sniff baseline, 
%                                                            0: blank response baseline when available

p_act = [];
p_sup = [];
act_all = {};
sup_all = {};
regions = {};
for ii=1:length(all_data)
    data = all_data{ii};
    regions{ii} = data.name;
    if (~isfield(data, 'data_blank') || params.preodor_bl_flag == 1)
        [act,~,~,sup,~,~] = neuronsPercentPerOdorExcInhPreOdorBaseline(data.data, params.pre_sniff, params.post_sniff, params.rate_flag);   
    else 
        [act,~,~,sup,~,~] = neuronsPercentPerOdorExcInhBlank(data.data, data.data_blank, params.post_sniff, params.rate_flag);   
    end
    act_all{ii} = act' * 100;
    sup_all{ii} = sup' * 100;
    % t-test
    [p_act(ii), h] = signrank(act_all{1}, act_all{ii}); 
    [p_sup(ii), h] = signrank(sup_all{1}, sup_all{ii});
end
figs{1} = figure('Name', '% activated per odor distribution'); hold on;
boxplot([act_all{:}], regions);
figs{2} = figure('Name', '% suppressed per odor distribution'); hold on;
boxplot([sup_all{:}], regions);
plot_name = {'activate', 'suppressed'};
for ii = 1:length(figs)
    figure(figs{ii});
    ylabel([plot_name{ii} ' neurons per odor (%)'])
    set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
    y_lim = ylim;
    ylim([0 ceil(y_lim(2)/10)*10]);
    y_lim = ylim;
    yticks = y_lim(1):(y_lim(2)-y_lim(1))/2:y_lim(2);
    set(gca, 'YTick', yticks);
    axis square
    box off; hold off;  
end
end

