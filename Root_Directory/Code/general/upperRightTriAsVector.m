function [triMat] = upperRightTriAsVector(mat)
% input:
%           mat: 2D matrix
% output:
%           triMat: vector of upper triangle of matrix

I = true(size(mat));
upper = triu(I,1);
triMat = mat;
triMat = triMat(upper);
end

