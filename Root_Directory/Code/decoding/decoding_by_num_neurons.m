function [meanSuccessRate, sdSuccessRate] = decoding_by_num_neurons(data, params)
% input:
%           data: region data: struct with fields:
%               data: odors responses data
%               data_blank (optional, use if baseline is blank): blank responses data
%           params: decoding params:
%                   struct with fields:
%                           evoked_flag: 1: evoked response, 0: absolute response
%                           rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%                           preodor_bl_flag: (optional): 1: always use pre-odor sniff baseline; 0: use blank baseline when available (otherwise, pre-odor)                     
%                           sniff_window: window for decoding
%                           pre_sniff_window_end (required if evoked_flag =
%                               1 and using pre-odor baseline): end of pre-odor baseline window
%                           num_neurons: # neurons to use in decoding
%                           num_odors: # odors to decode
%                           num_trials: # trials to use in decoding
%                           num_rep: number of bootstrapping repetitions
%                           dist: the distance measure for decoding algorithm
% runs decoding algorithm on data set in sniff window
% repeats decoding num_rep times, each repetition uses a random set of neurons of size num_neurons
% output:
%           meanSuccessRate: mean across bootstrapping repetitions of
%                            success rates (%) of sniff window
%           sdSuccessRate: standard deviation across bootstrapping
%                          repetitions of success rates (%) of sniff window

meanSuccessRate = NaN;
sdSuccessRate = NaN;

% spike activity parameters
matFR_params.evoked_flag = params.evoked_flag;
matFR_params.rate_flag = params.rate_flag;
% decoding window
matFR_params.start_sniff_phase = params.sniff_window(1);   % beginning of decoding window
matFR_params.end_sniff_phase = params.sniff_window(2);   % end of decoding window
% for evoked activity, check what the baseline is
if matFR_params.evoked_flag
    matFR_params.preodor_bl_flag = params.preodor_bl_flag;
    if params.preodor_bl_flag || ~isfield(data, 'data_blank')
        % baseline is pre-odor sniffs
        matFR_params.pre_end_sniff_phase = params.pre_sniff_window_end;   
    end
end
% get spike activity in sniff range
[mat_FR] = get_mat_fr_phase_3d(data, matFR_params);

odors = 1:params.num_odors;
    
successRateAll = NaN(1,params.num_rep);
% in each repetition, choose a random subset of neurons for decoding
for rep=1:params.num_rep
    % choose random num_neurons neurons
    neurons = randperm(size(data.data,1),min(params.num_neurons,size(data.data,1)));   
    % create samples of labels and features
    decoding_data = struct();
    sample_size = length(neurons)*length(odors);
    labels = NaN(1,sample_size); decoding_data(1,sample_size) = struct();
    label_ids = odors;
    kk=1;
    for ii=neurons
        for jj=odors
            labels(kk) = jj;
            fr = squeeze(mat_FR(ii,jj,:));
            fr = fr(~isnan(fr));
            decoding_data(kk).features = fr;
            kk = kk + 1;
        end
    end
    % run decoding: calculate success rate
    [successRate] =  leave_1_out_decoder(labels, decoding_data, label_ids, params.num_trials, params.dist);
    successRateAll(rep) = successRate;
end

successRateAll = successRateAll * 100;
% mean & standard deviation across bootstrapping repetitions of success rates of sniff windows
meanSuccessRate = mean(successRateAll);
sdSuccessRate = std(successRateAll);

end