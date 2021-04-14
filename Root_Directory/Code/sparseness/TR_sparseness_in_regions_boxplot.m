function [lifetimeSparseness, populationSparseness] = TR_sparseness_in_regions_boxplot(all_data, params)
% calculate and plot lifetime sparseness in each dataset
% input:
%       all_data: cell array of structs of regions:
%           each struct has fields:
%           data: odors responses data 
%           data_blank (use if baseline is blank): blank responses data
%           name: name of region
%           color: color for plot
%       params: struct with the following fields:
%               evoked_flag: 1: evoked response, 0: absolute response                               
%               rate_flag: 1: spike rate in sniff, 0: spike count in sniff
%               post_sniff: post odor sniff (1st is 1, not 0)
%               preodor_bl_flag: 1: pre-odor sniff baseline; 0: blank 
%                                response baseline when available
%                   Note: if database doesn't have blank response, a
%                   preodor baseline will be used automatically
%               pre_sniff: pre-odor sniff baseline 
%                   Note: required if a dataset doesn't have blank response
%                   or if preodor_bl_flag is 1
%               
% output:
%       lifetimeSparsenessTT: for each region, Treves-Rolls lifetime 
%                            sparse index for each neuron
%       populationSparsenessTT: for each region, Traves-Rolls population  
%                            sparse index for each odor
% Figures:
%           Plots distribution of sparseness in each region.
%           1. Treves-Rolls lifetime sparseness
%           2. Treves-Rolls population sparseness


gLifeTimeSparseness = [];
lifetimeSparseness = []; 
populationSparseness = []; 
regions = {};
% measure sparsness in each region
for ii=1:length(all_data)
    
    region_data = all_data{ii};
    regions{ii} = all_data{ii}.name;
    
    [matFR, matResp] = get_mat_fr(region_data, params); 
    % lifetime sparseness
    lifetimeSparseness{ii} = lifetimeSparsenessTRInRegion(matFR);
    gLifeTimeSparseness{ii} = repmat({regions{ii}},length(lifetimeSparseness{ii}),1);
    % population sparsenss
    populationSparseness{ii} = populationSparsenessTRInRegion(matFR);
end

figs = [figure(1), figure(2)];
names = {'Lifetime', 'Population'};
% plot lifetime sparseness distribution
lts = cat(1,lifetimeSparseness{:});
g_lts = cat(1,gLifeTimeSparseness{:});
figure(figs(1))
boxplot(lts, g_lts)
% plot population sparseness distribution
figure(figs(2))
boxplot([populationSparseness{:}], regions)
% edit figures
for ii=1:length(figs)
    figure(figs(ii));
    ylabel([names{ii} ' sparseness']);
    set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
    axis square
    box off; hold off;  
end
end

