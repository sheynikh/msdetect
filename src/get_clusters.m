function [ labels, centers, cindex] = get_clusters(n_clusters, features, rho, delta, gamma)
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

    if n_clusters<1
        fprintf('ERROR: number of clusters incorrect (%d) in get_clusters()\n', n_clusters);
    end

    N = size(features,1);
    labels  = zeros(N,1);
    centers = [];
    cindex  = [];

    for c = 1:n_clusters
        ind = gamma.ord_sorted(c);               % index of the center of the cluster
        centers = [centers; features(ind,:)];    % add features of the cluster center
        cindex = [cindex; ind];                  % add index of the cluster center
        labels(ind) = c;                         % assign cluster label to the cluster center (label is the cluster index)
    end

    % assign points to clusters
    if n_clusters>1
        % if more than 1 cluster, assign to each point the same label as its nearest neighbour with higher density
        for i = 1:N                             % go through all points in descending rho order
            ind = rho.ord_sorted(i);        % index of the point with next highest rho
            if ~any(cindex==ind) 
                % if not a cluster center, assign the same label as its nearest
                % neighbour of higher density
                labels(ind) = labels(delta.nneighbour(ind));       % label of the nearest neighbour
            end
        end
    else
        % if only one cluster, all point have the same label (1)
        labels = ones(N,1);
    end


% clusters.rho        = get_rho(clusters.dc, clusters.dm);
% clusters.delta      = get_delta(clusters.rho, clusters.dm);
% clusters.gamma      = get_gamma(clusters.rho.rho, clusters.delta.delta);
% 
% clusters.labels  = zeros(N,1);
% clusters.centers = [];
% clusters.index   = [];
% 
% % cluster centers
% for cidx = 1:n_clusters
%     ind = clusters.gamma.ord_sorted(cidx);                              % index of the center of the cluster
%     clusters.centers = [clusters.centers; clusters.features(ind,:)];    % add features of the cluster center
%     clusters.index = [clusters.index; ind];                             % add index of the cluster center
%     clusters.labels(ind) = cidx;                                        % assign cluster label to the cluster center (label is the cluster index)
% end
% 
% % assign points to clusters
% neighbours = clusters.delta.nneighbour;
% rho_ord_sorted = clusters.rho.ord_sorted;
% for i = 1:N                         % go through all points in descending rho order
%     ind = rho_ord_sorted(i);        % index of the point with next highest rho
%     if ~any(assigned.index==ind) 
%         % if not a cluster center, assign the same label as its nearest
%         % neighbour of higher density
%         label = assigned.labels(neighbours(ind));       % label of the nearest neighbour
%         if label ~= 0
%             assigned.labels(ind) = label;
%         else
%             fprintf('\n ERROR: There are unassigned points %d\n\n');
%         end
% 
%     end
% end    


