function [KDFs_norm, KDFt] = neuron_phases(all_data,params)
% input:
%       all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           name: name of region
%           color: color for plot
%       params:
%           PST: time interval
%           KernelSize: std dev of Gaussian
%           morph_flag: 1: morph sniff times and spike times; 0: don't morph
%           morphType: required if morph_flag == 1:
%                       * 'full_breath_cycle': morph spikes according to
%                          median sniff duration
%                       * 'in_ex_separately': morph spikes in inhale
%                           according to median inhalation duration,
%                           and spikes in exhale according to median
%                           exhalation duration
%           image_range: value range for imagesc
%           sort_flag: 1: sort neurons by phase of max psth value
%           sort_first_post_sniff: sort neurons by phase of max psth value in: 1: 1st sniff post odor onset, 0: 1st sniff in psth data
%           num_sniffs: number of sniffs to display

% colors
breathColor = [170 170 170; 200 200 200]./255;
orange = [255, 165, 0];
white = [255,255,255];
n = 256;
perc1 = abs(params.image_range(1))/(params.image_range(2) - params.image_range(1));
n1 = floor(perc1*n);
orange_white_half_map = [linspace(orange(1), white(1), n1)', linspace(orange(2), white(2), n1)', linspace(orange(3), white(3), n1)']/255;
n2 = ceil((1-perc1)*n);



all_databases = {};
for ii = 1:length(all_data)
    all_databases{ii} = all_data{ii}.data;
end
if params.morph_flag == 1
    all_databases = morph_data(all_databases, params.morphType, [], NaN, NaN);
end

KDFs_norm = {};
for ii = 1:length(all_data)
    data = all_databases{ii};
    
    % color
    color = all_data{ii}.color - [0.07 0.07 0.07];
    white_regionColor_half_map = [linspace(white(1)/255, color(1), n2)', linspace(white(2)/255, color(2), n2)', linspace(white(3)/255, color(3), n2)'];
    colors =[orange_white_half_map; white_regionColor_half_map];
    
    if params.PST(2) > 0
        % psth for each cell-odor pair
        y_label = 'neuron-odor pairs';
        all_KDFs = [];
        idx = 1;
        for neuron=1:size(data,1)
            for odor=1:size(data,2)
                RA = GetRaster(neuron, odor, data);
                [KDF, KDFt, KDFe] = mypsth(RA,params.KernelSize,'n',params.PST);
                all_KDFs{idx} = KDF';
                idx = idx + 1;
            end
        end
    else
        % take trials of all pre-odor baseline
        y_label = 'neurons';
        all_KDFs = [];
        for neuron=1:size(data,1)
            RA = [];
            for odor=1:size(data,2)
                RA = [RA GetRaster(neuron, odor, data)];
            end
            [KDF, KDFt, KDFe] = mypsth(RA,params.KernelSize,'n',params.PST);
            all_KDFs{neuron} = KDF';
        end
    end
    all_KDFs_arr = [all_KDFs{:}]';
    % scale responses
%     all_KDFs_arr_norm = normalize(all_KDFs_arr','range')';
    all_KDFs_arr_norm = normalize(all_KDFs_arr','zscore')';
    % return NaN values (std = 0) back to non-normalized values
    nanIdx = find(all(isnan(all_KDFs_arr_norm),2));
    all_KDFs_arr_norm(nanIdx,:) = all_KDFs_arr(nanIdx,:);
    
    d = data(1,1,1);
    sniffs_in_range = find(d.inh(1:end-1) >= params.PST(1) & d.inh(1:end-1) < params.PST(2));
    if isempty(sniffs_in_range), display([char(10) '--no sniffs in this time interval--']); return, end
    % sort neurons by phase of max psth value in 1st sniff window
    if params.sort_flag
        if params.sort_first_post_sniff && find(sniffs_in_range == d.inh1_idx)
            sort_start_sniff = d.inh1_idx;
        else
            sort_start_sniff = sniffs_in_range(1);
        end
        sort_start = d.inh(sort_start_sniff);
        if length(sniffs_in_range) > params.num_sniffs - 1
            sort_end = d.inh(sort_start_sniff + 1);
        else
            sort_end = KDFt(end);
        end
        sort_start = find(abs(KDFt - sort_start) < 0.005);
        sort_end = find(abs(KDFt - sort_end) < 0.005);
        [M,I] = max(all_KDFs_arr_norm(:,sort_start:sort_end),[],2);
        [Msort,Isort] = sort(I);
        all_KDFs_arr_norm = all_KDFs_arr_norm(Isort,:);
    end
    KDFs_norm{ii} = all_KDFs_arr_norm;
    
    x1 = d.inh(sniffs_in_range(1));
    if length(sniffs_in_range) > params.num_sniffs - 1
        x2 = d.inh(sniffs_in_range(params.num_sniffs)+1);
    else
        x2 = KDFt(end);
    end
    
    % plot
    figure; hold on;
    imagesc(KDFt, 1:size(all_KDFs_arr_norm,1), all_KDFs_arr_norm, params.image_range); 
    colormap(colors); 
    cbh = colorbar;
    set(cbh, 'XTick', [params.image_range(1), 0, params.image_range(2)]);
    set(cbh,'tickdir','out','ticklength',get(gca,'ticklength')*2);
    
    ylim([1 size(all_KDFs_arr_norm,1)])
    
    % add lines to indicate inhalations & exhalations
    x_ticks = []; x_ticks_labels = {};
    for sniff=sniffs_in_range
        % inhale
        plot([d.inh(sniff) d.inh(sniff)], ylim, 'Color', breathColor(1,:), 'lineWidth', 0.5);
        x_ticks(end+1) = d.inh(sniff); x_ticks_labels{end+1} = 'in.';
        % exhale
        plot([d.exh(sniff) d.exh(sniff)], ylim, 'Color', breathColor(2,:), 'lineWidth', 0.5);
        x_ticks(end+1) = d.exh(sniff); x_ticks_labels{end+1} = 'ex.';
    end
    plot([0 0], ylim, 'k');
    xlim([x1 x2]);
    
    title(all_data{ii}.name, 'fontSize', 16);
    xlabel('Normalized respiration cycle', 'fontSize', 16);
    ylabel(y_label, 'fontSize', 16);
    set(gca, 'fontSize', 16);
    set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
    y_lim = ylim;
    set(gca, 'YTick', [y_lim(1),y_lim(2)]);
    set(gca, 'XTick', x_ticks, 'XTickLabel', x_ticks_labels);
    box on;
    hold off
    
end
end

