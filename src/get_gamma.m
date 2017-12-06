function [ rhodelta ] = get_gamma( rho, delta )
% this function calcultes, for each data point, the product of rho and delta. 
% INPUT:
%       rho: the vector of local densities (calculated by local_density() )
%       delta: the vector if charaxteristic distances
% RETURN:
%       gamma:  the vector of products

gamma = ((rho - min(rho))/max(rho)) .* ((delta-min(delta))/max(delta));

[gamma_sorted,ord_sorted]=sort(gamma,'descend');

rhodelta.gamma = gamma;
rhodelta.gamma_sorted = gamma_sorted;
rhodelta.ord_sorted = ord_sorted;
