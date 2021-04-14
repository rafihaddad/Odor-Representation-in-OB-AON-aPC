function [corr_matrix] = molSimCorr(DB_name)

global root_dir
if isempty(root_dir), error(['Missing location of root directory.' char(10)...
                'Change the current folder to the root directory and run the script "set_global_variables".']); end
folder = [root_dir '\Data\physicochemical_descriptors\'];

% updated descriptors
mat_name = ['OdorDesc' DB_name];
odorDesc = load([folder mat_name], '-mat').(mat_name);
corr_matrix = corr(odorDesc(:,3:end)');


end

