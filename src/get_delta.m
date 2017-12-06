function [ min_dist ] = get_delta( rho, dm )
% this function is calcultes, for each data point, its characteristic
% distance delta its nearest neighbor with a higher density. 
% INPUT:
%       rho: the vector of local densities (calculated by local_density() )
%       dm: distance matrix of the data
% RETURN:
%       min_dist: structure containing
%       - the vector of characteristic distances delta
%       - the vector of nearest neighbours with a higher density

len = length(rho.rho);

delta = repmat(max(max(dm)), len, 1);
nneighbour = zeros(len,1);

for i = 2:len                                               % start with the point of second highest rho and go in descending order
    dist = dm(rho.ord_sorted(i), rho.ord_sorted(1:i-1));    % distances between the current point and all points with a higher rho 
    [delta(rho.ord_sorted(i)), idx] = min(dist);            % set delta to min dist, and idx to the index of the closest point with a higher rho 
    pts_dense = rho.ord_sorted(1:i-1);                      % indices of all elements with density higher than the current point
    nneighbour(rho.ord_sorted(i)) = pts_dense(idx);         % set nneighbour of that element to the index of the closest element with a higher rho
end

min_dist.delta = delta;
min_dist.nneighbour = nneighbour;


