function [ matN ] = normalize(mat, x, y)
% this function is to normalize the input data into a certain range (x, y)

matN = zeros(size(mat));
for i = 1:size(mat,1)
    m = min(mat(i,:));
    range = max(mat(i,:)) - m;
    
    if range~=0
        mat(i,:) = (mat(i,:) - m) / range;
    else
        mat(i,:) = (mat(i,:) - m);  % all values are the same, so set to zeroes
    end

    range2 = y - x;
    matN(i,:) = (mat(i,:) * range2) + x;
end