function [all_data] = prepare_data(regions, database_names, colors, preodor_bl_flag, num_neurons)
% prepare 1 structure with all of the data for odor correlations functions
% input:
%       regions: char array of name of region (e.g. 'OB') 
%                OR cell array of region names, same length as 
%                database_names (e.g. {'OB', 'PC'})
%                Note: name of regions must be as they appear in the 
%                names of the saved matlab data structures
%       database_names: char array of name of database (e.g. 'Bolding')
%                       OR cell array of names of databases, same length as 
%                       length of regions (e.g. {'Bolding', 'Mor'}
%                       Note: name of databases must be as they appear in the 
%                       names of the saved matlab data structures
%       colors: cell array of colors (same length as regions)
%       preodor_bl_flag: 1: don't take blank response, even if it's available 
%                        0: take blank response when it's available
%       num_neurons: number of neurons to take from each database
% output:
%       all_data: struct array with fields: data, (data_blank), name, color. 

if nargin < 4 || isnan(preodor_bl_flag)
    preodor_bl_flag = 0;
end

all_data = [];

global root_dir; 
if isempty(root_dir), error(['Missing location of root directory.' char(10)...
        'Change the current folder to the root directory and run the script "set_global_variables".']); end
data_dir = [root_dir '\Data\']; % directory of all data

[database_names, regions] = cell_array_same_length(database_names, regions);

for ii=1:length(regions)
    region = regions{ii};
    region_dir = [data_dir '\' region '\']; % directory of chosen region
    if exist([region_dir '\' region '_DS_' database_names{ii} '_odors_and_blank.mat'], 'file')
        data = load([region_dir '\' region '_DS_' database_names{ii} '_odors_and_blank.mat']); % load region data: 2 structs: odors and blank
        all_data{ii}.data = eval(['data.' region '_DS_' database_names{ii}]); % odors struct
        if ~preodor_bl_flag
            all_data{ii}.data_blank = eval(['data.' region '_DS_' database_names{ii} '_blank']); % blank struct
        end
    else
        data = load([region_dir '\' region '_DS_' database_names{ii} '.mat']); % load region data: 1 struct: odors
        all_data{ii}.data = eval(['data.' region '_DS_' database_names{ii}]);  % odors struct
    end
    % choose neurons
    if nargin < 5 || isempty(num_neurons)
        neurons = 1:size(all_data{ii}.data,1);
    else
        neurons = randperm(size(all_data{ii}.data,1), num_neurons);
    end
    all_data{ii}.data = all_data{ii}.data(neurons,:,:);
    if isfield(all_data{ii},'data_blank'), all_data{ii}.data_blank = all_data{ii}.data_blank(neurons,:,:); end
    all_data{ii}.name = region; 
    all_data{ii}.color = colors{ii};
end

end

