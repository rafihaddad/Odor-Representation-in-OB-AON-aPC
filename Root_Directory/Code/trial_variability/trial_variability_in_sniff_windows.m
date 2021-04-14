function [all_mean, all_ste, p_bw_regions] = trial_variability_in_sniff_windows(all_data, params)
% plots coefficient of variation (CV) across sniffs
% input: 
%   all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (optional, use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%   params: struct with fields:
%           evoked_flag: 1: evoked response, 0: absolute response
%           rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%           moving_window_flag:  % calculate variability in 1: moving sniff
%                                   windows, 0: accumulative sniff windows
%           windows: ends of sniff windows for CV calculation
%           bin_size: size of window for CV calculation
%           start: start of window if moving window = 0 (and when it is 1, if the beginning of the window will be prior to 'start', the window will be from 'start')           

font_size = 20;

all_mean = NaN(length(all_data),length(params.windows));
all_ste = NaN(length(all_data),length(params.windows));

for ii=1:length(all_data) 
    data = all_data{ii};
    if isfield(params, 'odors')
        data.data = all_data{ii}.data(:,params.odors,:);
    end
    for kk=1:length(params.windows) 
        % find window
        params.end_sniff_phase = params.windows(kk);
        if params.end_sniff_phase <= 0
            params.pre_end_sniff_phase = params.end_sniff_phase - 1;
        else
            phase = rem(params.end_sniff_phase,1);
            if phase == 0, params.pre_end_sniff_phase = 0; else, params.pre_end_sniff_phase = phase - 1; end
        end
        if params.moving_window_flag
            if params.end_sniff_phase <= 0
                params.start_sniff_phase = params.windows(kk) - params.bin_size;
            else
                params.start_sniff_phase = max(params.start, params.windows(kk) - params.bin_size);
            end
        else
            if params.end_sniff_phase <= 0
                % it's best for the first window to be 0, and not earlier
                % than that
                params.start_sniff_phase = params.end_sniff_phase - params.bin_size;
            else
                params.start_sniff_phase = params.start;
            end
        end
        % calcualte variability
        [var_all{ii,kk}] = CV_cell_odor_pairs(data, params);
        all_mean(ii,kk) = nanmean(var_all{ii,kk});
        all_ste(ii,kk) = nanstd(var_all{ii,kk})/sqrt(length(var_all{ii,kk}));
    end
    if ii > 1
        for jj=1:length(params.windows) 
           [p_bw_regions(ii,jj), h] = ranksum(var_all{1,jj}, var_all{ii,jj});
        end
    end
end

figure; hold on 
all_mean = all_mean';
all_ste = all_ste';
hb = bar(all_mean, 'EdgeColor', 'none');
ngroups = size(all_mean, 1);
nbars = size(all_mean, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, all_mean(:,i), all_ste(:,i),'LineStyle', 'none', 'color', 'k');
    if i > 1
    text(x - 0.105, all_mean(:,i) + 0.05, p_mark(p_bw_regions(:,i)), 'FontSize', font_size);   
    end
end
for jj=1:size(all_mean,2)
    set(hb(jj), 'FaceColor', all_data{jj}.color);
end
y_lim = ylim;
y_lim_up = ceil(y_lim(2));
ylim([0 y_lim_up])
y_lim = ylim;
yticks = y_lim(1):(y_lim(2)-y_lim(1))/2:y_lim(2);
set(gca, 'YTick', yticks);
font_size = 16;
ylabel('CV', 'FontSize', font_size);
xlabel('# sniff')
set(gca, 'FontSize', font_size);
axis square
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
box off; hold off;

end

