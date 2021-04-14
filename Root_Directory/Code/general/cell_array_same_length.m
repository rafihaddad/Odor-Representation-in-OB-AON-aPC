function [char_cell_1, char_cell_2] = cell_array_same_length(char_cell_1, char_cell_2)
% input:
%       char_cell_1: char array OR cell array of names
%       char_cell_2: char array OR cell array of names
% output:
%       char_cell_1: cell array same length as char_cell_2
%       char_cell_2: cell array same length as char_cell_1

if ischar(char_cell_1) && ~ischar(char_cell_2)
    % same char_cell_1 name for all char_cell_2 - create cell array of 
    % length of char_cell_2 with repeated char_cell_1
    C = cell(1, length(char_cell_2));
    C(:) = {char_cell_1};
    char_cell_1 = C;
elseif ischar(char_cell_2) && ~ischar(char_cell_1)
    % same char_cell_2 name for all char_cell_1 - create cell array of 
    % length of char_cell_1 with repeated char_cell_2
    C = cell(1, length(char_cell_1));
    C(:) = {char_cell_2};
    char_cell_2 = C;
end
if ischar(char_cell_2) && ischar(char_cell_1)
    % both are char arrays - create cell array of length 1 for both
    char_cell_1 = {char_cell_1};
    char_cell_2 = {char_cell_2};        
end

end

