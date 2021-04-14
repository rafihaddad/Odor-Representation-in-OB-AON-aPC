function [] = odor_corr_in_sniff_windows(all_data, params)
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
%           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
%           corr_type: e.g. Pearson, Spearman, Kandell
%           corr_range: range of correlations for display in heat map 
%           start_sniff_phase: index + phase of sniff start of sniff range (e.g. 0.6)
%           end_sniff_phase: index + phase of sniff end of sniff range (bin
%                   will be up to inhalation of this sniff index + phase) (e.g. 2.6) 
%           pre_end_sniff_phase (if baseline is pre-odor activity): index +
%           phase of end of baseline sniff range 
% function plots 2 subplots:
%           1. for each region, mean odor correlation across windows

params.entire_sniff_flag = 0;
font_size = 16;


if params.moving_window_flag
    window_type = ['moving sniff windows (window size = ' num2str(params.bin_size) ')'];
else
    window_type = 'accumulative sniff windows';
end

figure('Name', ['mean odor correlations in ' window_type]);
p1 = [];

for ii=1:length(all_data)
    all_mean = NaN(1,length(params.windows));
    all_ste = NaN(1,length(params.windows));
    for kk=1:length(params.windows)        
        % find window
        params.end_sniff_phase = params.windows(kk);
        if params.end_sniff_phase <= 0
            params.pre_end_sniff_phase = params.end_sniff_phase - 1;
        else
            phase = rem(params.end_sniff_phase,1);
            if phase == 0, params.pre_end_sniff_phase = 0; else params.pre_end_sniff_phase = phase - 1; end
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
        % get mean & std of all odor correlations
        [vecR{ii}(kk,:), vecP, all_mean(kk), std, matR, matP] = odor_corr_vector(all_data{ii}, params);
        all_ste(kk) = std / sqrt(length(vecR{ii}(kk,:)));
    end
    hold on;
    p1(end+1) = errorbar(params.windows, all_mean, all_ste, 'Color', all_data{ii}.color, 'displayName', all_data{ii}.name);
end

font_size = 16;
y_lim = ylim;
yticks = y_lim(1):(y_lim(end)-y_lim(1))/2:y_lim(end);
set(gca, 'ytick', yticks)

xlabel('Sniff window', 'fontSize', font_size); 
ylabel('Correlation', 'fontSize', font_size); 
set(gca, 'fontSize', font_size);
xlim([params.windows(1) params.windows(end)]);
x_lim = xlim;
xticks = x_lim(1):(x_lim(end)-x_lim(1))/2:x_lim(end);
set(gca, 'xtick', xticks)
if x_lim(1) < 0
    plot([0 0], ylim, 'k', 'LineWidth', 1);
end
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2); 
axis square

end

