function [ dens ] = get_rho(dc, dm, type)
% this function calculates the local density of each point. The
% local density can be calculates by: 1) step function 2) gaussian
% function. Default is set Gaussian. 
% INPUTS:
%       dc: dc value (chosen manually or caluclated using choose_dc)
%       dm: distance matrix of input data (obtained for example by using
%           squareform(pdist(x)) where x is the set of inut vectors
%       type: 'Gaussian' or 'step'
% RETURNS:
%       dens: structure containing 
%       - the vector of local densities of each point
%       - the same vector sorted in descending order
%       - indiced of sorted values

if nargin < 3 || isempty(type)
  type = 'gaussian';
end

[len,~] = size(dm);
rho = zeros(len, 1);

if dc>0
    if strcmp(type, 'gaussian')
        gaussian = @(x, y) exp(-(x/y)^2);
        for i = 1:len
            for j = i+1:len
                rho(i) = rho(i) + gaussian(dm(i,j), dc);
                rho(j) = rho(j) + gaussian(dm(j,i), dc);
            end
        end
    elseif strcmp(type, 'step')
        for i = 1:len
            for j = i+1:len
                if dm(i,j) < dc
                    rho(i) = rho(i) + 1.;
                    rho(j) = rho(j) + 1.;
                end
            end
        end
    else
        disp('ERROR: incorrect type in local_density()')
    end
end

[rho_sorted,ord_sorted]=sort(rho,'descend');

dens.rho = rho;
dens.rho_sorted = rho_sorted;
dens.ord_sorted = ord_sorted;



