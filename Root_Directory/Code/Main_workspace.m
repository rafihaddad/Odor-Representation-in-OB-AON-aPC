%% - general description
% To run the code below, first change the current folder to the
% root directory and run the script "set_global_variables"
% Make sure the Data folder is alongside the Code directory.
% NOTE: most of this code is compatible with MATLAB R2014a but some of it
% will require MATLAB R2020a.

global root_dir
addpath(genpath(root_dir));


%% general database params
database_name_M = 'Mor'; 
regions_M = {'OB', 'PC', 'AON'};
colors_M = {[241    95    106]/255; [73    161    218]/255; [165,90,159]/255}; 
num_neurons_M = 101;    % number of neurons in OB dataset 
odor_labels_M = {'octane', 'hexanal', 'acetophenone, ', 'geraniol', 'ethyl valerate', 'citral', 'cineole', 'phenethyl alcohol', 'D-limonene'};
% load data
[M_all_data] = prepare_data(regions_M, database_name_M, colors_M);  % load data with all neurons in each region

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% *** Figure 1: experiment and Mor data description
%% A: experiment schematic
%% B: odors in physicochemical space
%% C: example neurons: raster and PSTH - not morphed
% params
clear params
params.PST = [-0.6 1.2]; %[-1 2];       % time interval - take approximate 2 post sniffs for all neurons
params.KernelSize = 0.02;  % std dev of Gaussian
params.morph_flag = 0;  % 1: morph sniff times and spike times; 0: don't morph
params.morphType = 'in_ex_separately';   % morph according to: 'full_breath_cycle' or 'in_ex_separately' (inhalation and exhalation separately)
odors = [1:4,6,8];
neuronIndices = {41, 143, 60}; % first neuron is for OB, second is for PC, third for AON
yMaxs = {40, 40, 40};   % first is for OB, second for PC, third for AON
odor_names = odor_labels_M(odors);
plot_psth_odors_all_regions(M_all_data, neuronIndices, odors, params, yMaxs, odor_names);
%% D: phase locking - matrices of cell-odor pair normalized spike counts 
clear params
params.KernelSize = 0.02;  % std dev of Gaussian
params.morph_flag = 1; % 1: morph sniff times and spike times; 0: don't morph
params.morphType = 'in_ex_separately';   % morph according to: 'full_breath_cycle' or 'in_ex_separately' (inhalation and exhalation separately)
params.sort_flag = 1;   % sort neurons by phase of max psth value
params.sort_first_post_sniff = 1;   % sort neurons by phase of max psth value in: 1: 1st sniff post odor onset, 0: 1st sniff in psth data
params.PST = [-0.7 0.7];            % time interval
params.num_sniffs = 2;              % number of sniffs to display
params.image_range = [-3 9];        % value range for imagesc
[KDFs_norm, KDFt] = neuron_phases(M_all_data,params);
%% E: population PSTH (not morphed)
% params
PST = [-3 3];       % time interval - afterwards take from one pre sniff till one/two post sniffs
KernelSize = 0.02;  % std dev of Gaussian
clear morphParams
morphParams.morph_flag = 0; % 1: morph sniff times and spike times; 0: don't morph
morphParams.morphType = 'in_ex_separately';   % morph according to: 'full_breath_cycle' or 'in_ex_separately' (inhalation and exhalation separately)
graph_title = [database_name_M ' Population PSTH Mean Odors'];
[avg_KDFs_M, std_KDFs_M, KDFt_M] = run_population_psth(M_all_data, PST, KernelSize, graph_title, morphParams);
xlim([-0.62 1.257])
%% F: % responses per # odors (rank-sum)
% general params
clear params
params.rate_flag = 0;  % evaluate response by 1: spike rate; 0: spike count
params.post_sniff = 1; % post odor sniff (Note: 1st is 1, not 0). can also pass array of sniffs (e.g. [1 2 3])
params.pre_sniff = -1; % pre-odor sniff baseline
params.preodor_bl_flag = 0; % 1: pre-odor sniff baseline; 0: blank baseline when available (otherwise, pre-odor)
params.ks_flag = 0;    % 1: use ks test, 0: use rank-sum test
[NumOpN_M, NpNumO_M] = odors_per_neuron_sniffs(M_all_data, params);
%% G-H: % activated & % suppressed
clear params;
params.rate_flag = 0;
params.post_sniff = 1;
params.pre_sniff = -1;
[act_M, p_act_M, sup_M, p_sup_M] = perc_act_perc_supp(M_all_data, params);

%% I-J: lifetime & population sparseness
clear params
params.post_sniff = 1; % post odor sniff (Note: 1st is 1, not 0)  
params.pre_sniff = -1; % pre-odor sniff baseline
params.rate_flag = 0;  % 1: spike rate in sniff, 0: spike count in sniff
params.evoked_flag = 0; % 1: evoked response, 0: absolute response
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
[lifetime_TR_M, population_TR_M] = TR_sparseness_in_regions_boxplot(M_all_data, params);

%% *** Supplementary Figure 1
%% A: inhalation and sniff durations bar graph and/or errorbar graph of sniff duration across sniffs (decreases exhalation a bit at first sniff)
%% 
%% A: spontaneous activity - bar graph
clear params
params.evoked_flag = 0; % 1: evoked response, 0: absolute response
params.rate_flag = 0;   % 1: spike rate in sniff, 0: spike count in sniff
params.end_sniff_phase = 0; % end of sniff window
params.start_sniff_phase = -7;  % first sniff in window
params.title = 'Spontaneous activity';
[allFR_spont,p_ttest_spont, p_ranksum_spont] = FR_distribution(M_all_data, params);
%% B: example neurons: raster and PSTH - morphed
% params
clear params
params.PST = [-0.62 1.257]; %[-1 2];       % time interval - take approximate 2 post sniffs for both neurons
params.KernelSize = 0.02;  % std dev of Gaussian
params.morph_flag = 1;  % 1: morph sniff times and spike times; 0: don't morph
params.morphType = 'in_ex_separately';   % morph according to: 'full_breath_cycle' or 'in_ex_separately'
color = 'b';
odors = [1:4,6,8]; 
neuronIndices = {41, 143, 60}; % first neuron is for OB and second is for PC
yMaxs = {50, 50, 50};   % first is for OB and second for PC, third for AON
odor_names = odor_labels_M(odors);
plot_psth_odors_all_regions(M_all_data, neuronIndices, odors, params, yMaxs, odor_names);
%% C: morphed population psth
PST = [-3 3];       % time interval
KernelSize = 0.02;  % std dev of Gaussian
clear morphParams
morphParams.morph_flag = 1; % 1: morph sniff times and spike times; 0: don't morph
morphParams.morphType = 'in_ex_separately';   % morph according to: 'full_breath_cycle' or 'in_ex_separately'
graph_title = [database_name_M ' Morphed Population PSTH Mean Odors'];
[avg_KDFs_M_m, std_KDFs_M_m, KDFt_M_m] = run_population_psth(M_all_data, PST, KernelSize, graph_title, morphParams);
xlim([-2.5132 2.5132])
%% D: spike count in first 3 sniffs - bar graph
clear params
params.evoked_flag = 0; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.end_sniff_phase = 3; % index + phase of sniff end of sniff range (e.g., 2.6)
params.start_sniff_phase = 0;   % index + phase of sniff start of sniff range (e.g., 0.6)
[allFR_resp,ptest_resp, p_ranksum_resp] = FR_distribution_across_sniffs(M_all_data, params);
%% E: % responding for each of the 9 odors - line graph
clear params
params.pre_sniff = -1;  % pre odor sniff baseline
params.post_sniff = 1;  % use activity in post odor sniff. NOTE: 1st sniff is 1, not 0
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
percRespM = neurons_per_odor_linegraph(M_all_data, params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% *** Figure 2: odor representation quality
%% A-D: odor correlations
%% general params for odor correlations
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
params.entire_sniff_flag = 1; % use activity in: 1: entire sniff; 0: sniff range/phase 
params.post_sniff = 1;  % use activity in post odor sniff. NOTE: 1st sniff is 1, not 0
params.pre_sniff = -1;  % pre odor sniff baseline
params.mean_trials = 1; % 1: take mean of trials before calculating correlation; 0: don't
params.dist_flag = 0;   % 1: distance metric instead of correlation; 0: correlation
%% A-B: odor-pair correlations
[all_meanR_M, all_steR_M, p_bw_regions_M] = odor_corr_scatterplot(M_all_data, params);
%% C: compare similar and dissimilar odors-pairs
params.show_diff = 1;
[all_means_M, all_ste_M, all_p_bw_reg_M, all_p_sim_M] = odor_corr_similar_odors_vs_nonsimilar_odors(M_all_data,params);
%% D: correlations across sections of first sniff - ACCUMULATIVE windows
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor) 
params.moving_window_flag = 0;  % calculate correlations in moving sniff windows
step = 0.125;                    % measurement in sniffs
params.windows = 0:step:1;     % ends of windows
params.bin_size = step;         % size of window if moving window = 1 
params.start = 0;               % start of window if moving window = 0 (and when it is 1, if the beginning of the window will be prior to 'start', the window will be from 'start')
odor_corr_in_sniff_windows(M_all_data, params);
%% E: trial variability (coefficient of variation) in first sniff
% params for trial variability
clear params
params.evoked_flag = 0;    % 1: evoked response, 0: absolute response
params.rate_flag = 0;      % evaluate response by 1: spike rate; 0: spike count
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
params.start_sniff_phase = 0;   % index + phase of start start of sniff range
params.end_sniff_phase = 1; % index + phase of sniff end of sniff range
params.pre_end_sniff_phase = 0; % for evoked_flag = 1: index + phase of end of baseline sniff range
[CV_mean_M, CV_ste_M, CV_p_M] = trial_variability(M_all_data, params);
%% F: decoding as a function of # neurons
clear params
params.num_rep = 100;           % number of bootstrapping repetitions in which to sample random subsets of neurons
params.dist = 'euclidean';      % distance measure for decoding algorithm
params.sniff_window = [0 3];    % beginning and end of window (0 marks 1st inhalation time post odor onset, 3 marks the end of the 3rd sniff) 
params.num_neurons_array = 10:10:100;   % array of numbers of neurons to use for decoding 
params.num_trials = 15;         % # trials to use in decoding
params.evoked_flag = 0;         % 1: evoked response, 0: absolute response
params.rate_flag = 0;           % evaluate response by 1: spike rate; 0: spike count
[h_Mor, mean_mor, sd_mor] = decoding_by_num_neurons_array(M_all_data, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% *** Supplementary Figure 2: odor representation quality
%% A: compare similar and dissimilar odors as defined by molecular descriptors
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
params.entire_sniff_flag = 1; % use activity in: 1: entire sniff; 0: sniff range/phase 
params.post_sniff = 1;  % use activity in post odor sniff. NOTE: 1st sniff is 1, not 0
params.pre_sniff = -1;  % pre odor sniff baseline
params.mean_trials = 1; % 1: take mean of trials before calculating correlation; 0: don't
params.dist_flag = 0;   % 1: distance metric instead of correlation; 0: correlation
params.mol_ref_flag = 1; % 1: compare neural response odor correlations to physicochemical odor correlations
params.dataset_name = database_name_M;  % required if mol_ref_flag = 1
params.show_diff = 1;   % display the difference in correlations between cortical regions and OB (1st region)
[all_meanR_mol_M, all_steR_mol_M, p_bw_regions_mol_M] = odor_corr_scatterplot(M_all_data, params);
%% B: correlations across sections of first sniff - MOVING windows
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor) 
params.moving_window_flag = 1;  % calculate correlations in moving sniff windows
step = 0.125;                    % measurement in sniffs
params.windows = 0:step:1;     % ends of windows
params.bin_size = step;         % size of window if moving window = 1 
params.start = 0;               % start of window if moving window = 0 (and when it is 1, if the beginning of the window will be prior to 'start', the window will be from 'start')
odor_corr_in_sniff_windows(M_all_data, params);
%% C: general params for correlations across sniffs
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor) 
params.sniffs = 1:3;   % array of sniffs to display odor correlations for. NOTE: 1st sniff is 1, not 0
params.pre_sniff = -1;  % pre odor sniff baseline for post odor sniffs
[means_all_sniffs_M, ste_all_sniffs_M] = odor_corr_across_sniffs(M_all_data, params);
%% D: Trial variability across sniffs
clear params
params.evoked_flag = 0;    % 1: evoked response, 0: absolute response
params.rate_flag = 0;      % evaluate response by 1: spike rate; 0: spike count
params.moving_window_flag = 1;  % calculate variability in moving sniff windows
step = 1;                    % measurement in sniffs
params.windows = 1:step:3;     % ends of windows
params.bin_size = step;         % size of window if moving window = 1 
params.start = 0;               % start of window if moving window = 0 (and when it is 1, if the beginning of the window will be prior to 'start', the window will be from 'start')
[CV_mean_sniffs_M, CV_ste_sniffs_M, CV_p_sniffs_M] = trial_variability_in_sniff_windows(M_all_data, params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3: verification with awake mice - Bolding's data
% NOTE: to run this code, download data of simultaneous OB and PC
% recordings from http://dx.doi.org/10.6080/K00C4SZB. Use data from
% sessions in which 6 odors were presented 15 times. Build data structures 
% of odor response spike times and respiration times in a similar format to 
% the datasets used for the code above. Name them 'OB_DS_Bolding' and
% 'PC_DS_Bolding'. 
% Save separate data structure of blank trials in same format. Name them 
% 'OB_DS_Bolding_blank' and 'PC_DS_Bolding_blank'. 
% Save OB_DS_Bolding and OB_DS_Bolding_blank together as 
% 'OB_DS_Bolding_odors_and_blank.mat', and save under 'OB' folder.
% Save PC_DS_Bolding and PC_DS_Bolding_blank together as 
% 'PC_DS_Bolding_odors_and_blank.mat', and save under 'PC' folder.

% general database params
database_name_B = 'Bolding';    
regions_B = {'OB', 'PC'};
colors_B = {[241    95    106]/255; [73    161    218]/255};
num_neurons_B = 271; % number of neurons in OB dataset 
% load data
[B_all_data] = prepare_data(regions_B, database_name_B, colors_B);  % load data with all neurons in each region

%% A-B: lifetime & population sparseness
clear params
params.post_sniff = 1; % post odor sniff (Note: 1st is 1, not 0)  
params.pre_sniff = -1; % pre-odor sniff baseline
params.rate_flag = 0;  % 1: spike rate in sniff, 0: spike count in sniff
params.evoked_flag = 0; % for TR sparseness: 1: evoked response, 0: absolute response
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
[lifetime_TR_B, population_TR_B] = TR_sparseness_in_regions_boxplot(B_all_data, params);
%% C-D: odor correlations 
%% general params for odor correlations
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
params.entire_sniff_flag = 1; % use activity in: 1: entire sniff; 0: sniff range/phase 
params.post_sniff = 1;  % use activity in post odor sniff. NOTE: 1st sniff is 1, not 0
params.mean_trials = 1; % 1: take mean of trials before calculating correlation; 0: don't
params.dist_flag = 0;   % 1: distance metric instead of correlation; 0: correlation
%% C: odor correlations - scatter plot
[all_meanR_B, all_steR_B, p_bw_regions_B] = odor_corr_scatterplot(B_all_data, params);
%% D: compare similar and dissimilar odors
params.show_diff = 1;
[all_means_B, all_ste_B, all_p_bw_reg_B, all_p_sim_B] = odor_corr_similar_odors_vs_nonsimilar_odors(B_all_data,params);
%% E: Trial variability - CV across sniffs
clear params
params.evoked_flag = 0;    % 1: evoked response, 0: absolute response
params.rate_flag = 0;      % evaluate response by 1: spike rate; 0: spike count
params.moving_window_flag = 1;  % calculate correlations in moving sniff windows
step = 1;                    % measurement in sniffs
params.windows = 1:step:3;     % ends of windows
params.bin_size = step;         % size of window if moving window = 1 
params.start = 0;               % start of window if moving window = 0 (and when it is 1, if the beginning of the window will be prior to 'start', the window will be from 'start')
[CV_mean_sniffs_B, CV_ste_sniffs_B, CV_p_sniffs_B] = trial_variability_in_sniff_windows(B_all_data, params);
%% F: Decoding as a function of # neurons
clear params
params.num_rep = 100;           % number of bootstrapping repetitions in which to sample random subsets of neurons
params.dist = 'euclidean';      % distance measure for decoding algorithm
params.sniff_window = [0 2];    % beginning and end of window (0 marks 1st inhalation time post odor onset, 3 marks the end of the 3rd sniff) 
params.num_neurons_array = 10:10:100;   % array of numbers of neurons to use for decoding 
params.num_trials = 15;         % # trials to use in decoding
params.evoked_flag = 0;         % 1: evoked response, 0: absolute response
params.rate_flag = 0;           % evaluate response by 1: spike rate; 0: spike count
[h_Bolding, mean_Bolding, sd_Bolding] = decoding_by_num_neurons_array(B_all_data, params);


%% Supplementary Figure 3: verification with awake mice - Bolding's data
%% A: odor spread pca
%% B: compare similar and dissimilar odors as defined by molecular descriptors 
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)
params.entire_sniff_flag = 1; % use activity in: 1: entire sniff; 0: sniff range/phase 
params.post_sniff = 1;  % use activity in post odor sniff. NOTE: 1st sniff is 1, not 0
params.mean_trials = 1; % 1: take mean of trials before calculating correlation; 0: don't
params.dist_flag = 0;   % 1: distance metric instead of correlation; 0: correlation
params.mol_ref_flag = 1;
params.dataset_name = database_name_B;
params.show_diff = 1;
[all_meanR_mol_B, all_steR_mol_B, p_bw_region_mol_B] = odor_corr_scatterplot(B_all_data, params);
%% C: correlations across sections of first sniff - ACCUMULATIVE windows
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor) 
params.moving_window_flag = 0;  % calculate correlations in moving sniff windows
step = 0.125;                    % measurement in sniffs
params.windows = 0:step:1;     % ends of windows
params.bin_size = step;         % size of window if moving window = 1 
params.start = 0;               % start of window if moving window = 0 (and when it is 1, if the beginning of the window will be prior to 'start', the window will be from 'start')
odor_corr_in_sniff_windows(B_all_data, params);
%% D: general params for correlations across sniffs
clear params
params.corr_type = 'Pearson';   % correlation type (can also use 'Spearman' or 'Kendall')
params.evoked_flag = 1; % 1: use evoked activity; 0: use absolute activity
params.rate_flag = 0;   % 1: use spike rate in sniff; 0: use spike count in sniff
params.preodor_bl_flag = 0; % 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor) 
params.sniffs = 1:3;   % array of sniffs to display odor correlations for. NOTE: 1st sniff is 1
[means_all_sniffs_B, ste_all_sniffs_B] = odor_corr_across_sniffs(B_all_data, params);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
