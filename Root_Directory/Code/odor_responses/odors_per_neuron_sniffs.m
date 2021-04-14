function [numOdorsPerNeuron, percNeuronsPerNumOdors] = odors_per_neuron_sniffs(all_data, params)
% plot proportion of neurons per # odors for each region/database
% input:
%       all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%       params: struct with the following fields:
%               rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%               post_sniff: post odor sniff (1st is 1, not 0)
%               preodor_bl_flag: 1: pre-odor sniff baseline; 0: blank
%                                response baseline when available
%                   Note: if database doesn't have blank response, the
%                   preodor baseline will be used automatically
%               pre_sniff: pre-odor sniff baseline
%                   Note: required if a dataset doesn't have blank response
%                   or if preodor_bl_flag is 1
%               ks_flag: 1: use ks test, 0: use rank-sum test
%                       Note: optional, default - rank-sum
% figure:
%           bar graph: proportion of neurons that respond to # of odors
% output:
%       numOdorsPerNeuron: # odors each neuron responsds to
%       percNeuronsPerNumOdors: % neurons that respond to each # of odors

if isfield(params,'ks_flag') && params.ks_flag
    use_ks_test = 1;
else
    use_ks_test = 0;
end

figure;
percNeuronsPerNumOdors = []; legendName = []; new_colors = [];
numOdorsPerNeuron = [];
for ii=1:length(all_data)
    
    data_odors = all_data{ii}.data;
    if isfield(all_data{ii}, 'data_blank')
        has_blank = 1;
        data_blank = all_data{ii}.data_blank;
    else
        has_blank = 0;
    end
    % proportion of neurons that respond to # of odors
    color_percent = 1;
    for sniff=params.post_sniff
        color = all_data{ii}.color;
        new_colors{end+1} = color*color_percent; % darken
        if ~params.preodor_bl_flag && has_blank
            if ~use_ks_test
                [responses, responses_pvals] = responses_compared_to_blank(data_odors, data_blank, sniff, params.rate_flag);
            else
                [responses, responses_pvals] = responses_ks_blank_bl(data_odors, data_blank, sniff);
            end
        else
            if ~use_ks_test
                [responses, responses_pvals] = responses_preodor_baseline(data_odors, params.pre_sniff, sniff, params.rate_flag);
            else
                [responses, responses_pvals] = responses_ks_preodor_bl(data_odors, params.pre_sniff, sniff);
            end
        end
        
        numOdorsPerNeuron{end+1} = nansum(responses,2);
        
     
        [a,b] = hist(numOdorsPerNeuron{end}, 0:1:size(data_odors,2));
        a_prob = (a/size(data_odors,1)) * 100;  % !!
        percNeuronsPerNumOdors{end+1} = a_prob';
        legendName{end+1} = [all_data{ii}.name ', sniff ' num2str(sniff)];
        color_percent = color_percent - (1/length(params.post_sniff));
    end
end

x = 0:size([percNeuronsPerNumOdors{:}],1)-1;
hb = bar(x, [percNeuronsPerNumOdors{:}], 'EdgeColor', 'none');
xlim([x(1)-0.5 x(end)+0.5]);
for jj=1:length(new_colors)
    set(hb(jj), 'FaceColor', new_colors{jj});
end
l = legend(legendName);
font_size = 16;
xlabel('# odors', 'fontSize', font_size);
ylabel('Responding neurons (%)', 'fontSize', font_size);
set(gca, 'fontSize', font_size);
set(l, 'fontSize', font_size-2);
y_lim = ylim;
ylim([0 ceil(y_lim(2)/10)*10]);
y_lim = ylim;
yticks = y_lim(1):(y_lim(2)-y_lim(1))/2:y_lim(2);
set(gca, 'YTick', yticks, 'YTickLabel', yticks);
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
legend off
axis square
box off; hold off
end




