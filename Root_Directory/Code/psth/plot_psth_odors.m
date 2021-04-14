function [] = plot_psth_odors(data, data_blank, neuron, odors, color, params, yMax, odor_names)
% plot neuron's psth & raster plot for all odors
% input:
%       data: neurons' responses to odors.
%             struct of size #neurons x #odors x #trials, with fields:
%             times, inh, exh, inh1_idx
%       data_blank: neurons' responses to blank.
%                   struct of size #neurons x 1 x #trials, with fields:
%                   times, inh, exh, inh1_idx
%             Note: optional, could enter empty array: []
%       neuron: index of neuron
%       odors: indices of odors
%       color: color of plot
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
%       odor_names: names of odors in the order of 'odors' parameter

figure('Name', ['neuron ' num2str(neuron)]);

if params.morph_flag == 1
    all_data = {data,data_blank};
    all_data = morph_data(all_data, params.morphType, neuron, NaN, NaN);
    data = all_data{1};
    data_blank = all_data{2};
end

num_odors = length(odors);
rows = floor(sqrt(num_odors)); cols = 3;
breathColor = [200 200 200; 230 230 230]./255;
trial_height = 0.0286*yMax;
num_trials = size(data,3);

for ii=1:num_odors
    subplot(rows,cols,ii);
    odor = odors(ii);
    [KDF, KDFt, KDFe] = neuron_psth_odor(neuron, odor, data, params.PST, params.KernelSize, color);
    hold on;
    if ~isempty(data_blank)
        plot(KDFtB, KDFB, 'k');
    end
    title(odor_names{ii});
    % raster plot
    for trial=1:num_trials
        y_placement =  trial_height*trial;
        y = [-(y_placement-trial_height) -(y_placement-trial_height) -y_placement -y_placement];
        d = data(neuron,odor,trial);
        sniffs_in_range = find(d.inh(1:end-1) > params.PST(1)-1 & d.inh(1:end-1) < params.PST(2)+1) - d.inh1_idx ;
        for sniff=sniffs_in_range
            % inhale
            inhale = [d.inh(d.inh1_idx + sniff) d.exh(d.inh1_idx + sniff) d.exh(d.inh1_idx + sniff) d.inh(d.inh1_idx + sniff)];
            patch(inhale, y, breathColor(1,:), 'EdgeColor','none');
            % exhale
            exhale = [d.exh(d.inh1_idx + sniff) d.inh(d.inh1_idx + sniff + 1) d.inh(d.inh1_idx + sniff + 1) d.exh(d.inh1_idx + sniff)];
            patch(exhale,y, breathColor(2,:), 'EdgeColor','none');
        end
        spike_times = d.times(d.times > params.PST(1) & d.times < params.PST(2));
        scatter(spike_times,ones(1,length(spike_times))*(-y_placement+0.5), 20, 'k.');
    end
    ylim([-y_placement yMax]);
    set(gca, 'YTick', yMax, 'YTickLabel', [num2str(yMax) 'Hz']);
    set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2); 
    xlim(params.PST);
    plot([0 0], ylim, 'k');
    plot(xlim, [0 0], 'k');
    axis square
    set(gca, 'visible', 'off')
    h = gca; set(h.Title, 'visible', 'on')
    hold off
    box off
end

end


