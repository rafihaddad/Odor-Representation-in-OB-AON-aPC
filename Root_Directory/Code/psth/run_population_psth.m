function [avg_KDFs, std_KDFs, KDFt] = run_population_psth(all_data, PST, KernelSize, graph_title, morphParams)
% input:
%       all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           name: name of region
%           color: color for plot
%       PST: time interval
%       KernelSize: std dev of Gaussian
%       graph_title: char array: title of graph
%       morphParams: struct with fields:
%           morph_flag: 1: morph sniff times and spike times; 0: don't morph
%           morphType: required if morph_flag == 1: 
%                       * 'full_breath_cycle': morph spikes according to 
%                          avg sniff duration
%                       * 'in_ex_separately': morph spikes in inhale
%                           according to avg inhalation duration, 
%                           and spikes in exhale according to avg
%                           exhalation duration 
% output:
%       avg_KDFs: for each database: avg. rate (spikes per sec) of
%                 population (mean of odors)
%       std_KDFs: for each database: avg. errors (standard error) of
%                 population (mean of odors)
%       KDFt: times (times of rates)
% plots population PSTH of mean of odors, for all databases

% organize data
all_databases = {}; DB_region_names = {}; colors = {};
for ii=1:length(all_data)
    all_databases{ii} = all_data{ii}.data;
    DB_region_names{end+1} = all_data{ii}.name;
    colors{end+1} = all_data{ii}.color;
end

hold on; 
if morphParams.morph_flag
    % morph sniff times and spike times to standarized sniff duration 
    all_databases = morph_data(all_databases, morphParams.morphType, [], NaN, NaN);
end

num_DB = length(all_databases);
all_num_odors = []; for database=all_databases, all_num_odors(end+1) = size(database{1},2); end
num_odors = max(all_num_odors); % max number of odors in data sets
large_allocation = length(PST)*3000; % size of large allocation
avg_KDFs_odors = NaN(num_DB, num_odors, large_allocation); 
avg_KDFs = NaN(num_DB,large_allocation);
std_KDFs = NaN(num_DB,large_allocation);
p = [];

if morphParams.morph_flag
    % add patches to indicate inhalations & exhalations - same length in all
    % databases
    breathColor = [170 170 170; 200 200 200]./255;
    d = all_databases{1}(1,1,1);
    sniffs_in_range = find(d.inh(1:end-1) > PST(1) - 1 & d.inh(1:end-1) < PST(2)) - d.inh1_idx ;
    y = [0 8];
    y_placement = [y(1) y(1) y(2) y(2)];
    for sniff=sniffs_in_range
        % inhale
        inhale = [d.inh(d.inh1_idx + sniff) d.exh(d.inh1_idx + sniff) d.exh(d.inh1_idx + sniff) d.inh(d.inh1_idx + sniff)];
        patch(inhale, y_placement, breathColor(1,:), 'EdgeColor','none', 'FaceAlpha', 0.5);
        % exhale
        exhale = [d.exh(d.inh1_idx + sniff) d.inh(d.inh1_idx + sniff + 1) d.inh(d.inh1_idx + sniff + 1) d.exh(d.inh1_idx + sniff)];
        patch(exhale,y_placement, breathColor(2,:), 'EdgeColor','none', 'FaceAlpha', 0.2);   
    end
end

% for each database
for DB=1:num_DB
    database = all_databases{DB};
    DB_region_names{DB}
    num_odors = size(database, 2);
    % get population psth for each odor
    for odor = 1:num_odors
        [avg_KDF, KDFt_, avg_KDFe] = population_psth_odor(odor, database, PST, KernelSize);
        avg_KDFs_odors(DB,odor,1:length(avg_KDF)) = avg_KDF; 
        if ~isempty(KDFt_)
            KDFt = KDFt_;
        end
    end
    % mean & std of all odors
    DB_avg_KDFs_odors = squeeze(avg_KDFs_odors(DB,:,:));
    if size(DB_avg_KDFs_odors,1) ~= size(avg_KDFs_odors,2)
        DB_avg_KDFs_odors = DB_avg_KDFs_odors';
    end
    avg_KDFs(DB,:) = nanmean(DB_avg_KDFs_odors,1);
    if num_odors > 1
        std_KDFs(DB,:) = nanstd(DB_avg_KDFs_odors) / sqrt(size(DB_avg_KDFs_odors,1));
    else
        std_KDFs(DB,:) = 0;
    end
    % plot population psth of mean of odors
    avg = avg_KDFs(DB,~isnan(avg_KDFs(DB,:)));
    sd = std_KDFs(DB,~isnan(std_KDFs(DB,:)));
    if isempty(avg)
        continue
    end
    p(end+1) = plot(KDFt,avg(1:length(KDFt)), 'Color', colors{DB}, 'LineWidth', 0.5, 'DisplayName', DB_region_names{DB});
    errorbar_patch(KDFt,avg(1:length(KDFt)),sd(1:length(KDFt))/2, colors{DB});
end

% edit graph
plot([0 0], ylim, 'k');
legend(p);
xlim(PST);
font_size = 16;
xlabel('Time (sec)', 'FontSize', font_size);
ylabel('Rate (Hz)', 'FontSize', font_size);
title(graph_title, 'FontSize', font_size);
set(gca, 'FontSize', font_size);
axis square
y_lim = ylim;
yticks = y_lim(1):(y_lim(2)-y_lim(1))/2:y_lim(2);
set(gca, 'YTick', yticks);
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
hold off


end

