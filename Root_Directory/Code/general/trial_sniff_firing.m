function [all_sp_cnt, all_sp_rate] = trial_sniff_firing(trials)
% input:
%           trials: cell array of trials of one cell-odor pair,
%                   each trial is struct with fields: times, inh, exh, inh1_idx
% ouput:
%           all_sp_cnt: (#trials x #sniffs) spike count in sniff
%           all_sp_rate: (#trials x #sniffs) spike rate in sniff (count/sniff duration)

num_trials = length(trials);
num_sniffs = length(trials(1).inh)-1;
all_sp_cnt = NaN(num_trials,num_sniffs);
all_sp_rate = NaN(num_trials,num_sniffs);

for ii=1:num_trials
    st = trials(ii).times;
    inh = trials(ii).inh;
    if isempty(inh) || all(isnan(inh))
        continue
    end
    for jj=1:length(inh)-1 
        if isnan(inh(jj)) || isnan(inh(jj+1))
            continue;
        else
            all_sp_cnt(ii,jj) = length(find(st >= inh(jj) & st < inh(jj+1)));
            sniff_dur = inh(jj+1) - inh(jj);
            all_sp_rate(ii,jj) = all_sp_cnt(ii,jj) / sniff_dur;
        end
    end
end

end

