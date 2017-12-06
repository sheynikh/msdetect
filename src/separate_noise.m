function [clusters] = separate_noise(clusters)
    % this function is used to determine noisy points

    N = size(clusters.features,1);  % number of data points

    delta = clusters.delta.delta;
    nneighbour = clusters.delta.nneighbour;
    for i=1:N
        pt = clusters.rho.ord_sorted(i);
        if ~any(pt==clusters.cindex) % skip cluster centers
            if (delta(pt) > clusters.dc) || (clusters.labels(nneighbour(pt)) == 0)
                % if distance to the nearest neighbour with higher density
                % is larger than the threshold, or if the nearest neighbour
                % is an outlier, set this points as outlier
                clusters.labels(pt) = 0;
            end
        end
    end
  
