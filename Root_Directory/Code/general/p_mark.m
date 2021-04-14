function [ label ] = p_mark(p_val)
% input:
%       p_val: p-value (float)
% output:
%       label: marking of p-val (char array)

if p_val < 0.001
    label = '***';
elseif p_val < 0.01
    label = '**';
elseif p_val < 0.05
    label = '*';
else
    label = '';
end
end

