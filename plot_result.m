%% init
clear all; %close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script loads the result structure created by 'detectms.m' program.
% It plots MDS representation of detected clusters, sorted K-dist graph
% and decision graph. It also plots X trace with marked microsaccades
% detected by the algo.
% 
% Author: Denis SHEYNIKHOVICH, denis.sheynikhovich@upmc.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load clustering data
result_file = 'result.mat';
load(result_file)
fprintf('Clustering results loaded from %s\n', result_file)


%% MDS representation of clusters

N = size(clusters.features,1);
smpl = randsample(N, min(N, 1000));  % choose random subset of 1000 points
smpl = [clusters.cindex; smpl];      % add cluster centers
smpl = unique(smpl);                
[Y,~] = cmdscale(clusters.dm(smpl,smpl),2); % apply MDS

% assign colors according to clusters
c = [];
for i=1:length(smpl)
    pt = smpl(i);
    if clusters.labels(pt) == 0
        c = [c; [0 0 0]];               % noise
    elseif clusters.labels(pt) == 1
        c = [c; [1 0 0]];               % microsaccade (1st cluster)
    elseif clusters.labels(pt) == 2
        c = [c; [0 1 0]];               % microsaccade (2nd cluster)
    else
        disp('ERROR: unknown labels')
    end
end    

%% plotting
subplot(2,3,1)
scatter(Y(:,1),Y(:,2), 8, c, 'filled');
hold on
for i=1:length(clusters.cindex)
    idx = find(smpl==clusters.cindex(i));
    plot(Y(idx,1), Y(idx,2), 'ok', 'LineWidth', 2, 'MarkerSize', 7)
end
hold off
axis('equal')
xlabel('1st MDS component')
ylabel('2nd MDS component')
title('Clusters in MDS space')

subplot(2,3,2); cla;
plot(clusters.kd_sorted, '.k', 'MarkerSize', 10);
hold on
plot([0,N],[clusters.dc,clusters.dc], 'r-', 'LineWidth',2)
hold off
xlabel('Data point index')
ylabel('K-dist')
legend('k-dist','dc')
title('Sorted K-dist graph')

subplot(2,3,3)
plot(clusters.rho.rho, clusters.delta.delta, 'o')
xlabel('rho')
ylabel('delta')
title('Decision graph')

% This plot represents detected microsaccades by green vertical lines
% over the horizontal position of the eye
% For the data file submitted together with the manuscript, expert labels
% are also represented by blue dashed lines.
% Zoom out to see the complete trace.
% Note that only 2nd trials of each experimental session were labeled.
subplot(2,1,2)
plot(trace.time, trace.x, 'k-')
for i=1:length(ms_time)
    mspos = ms_time(i);
    line([mspos,mspos], [trace.x(mspos)-1, trace.x(mspos)+1], 'LineStyle', '-', 'Color', 'g', 'LineWidth', 2);
end
xlabel('Time, ms')
ylabel('X position')
xlim([33000, 60000])

% PLEASE COMMENT THE FOLLWOING LINES OUT IF YOU USE YOUR OWN DATA FILE
load('labels/expert_labels.mat');  % loads manual labels for the data
subj = 1;
cond = 1;
true_pos = ref{1,1}{subj,cond};
labels = ref{1,2}{subj,cond};
for i=1:length(true_pos)
    pos = true_pos(i);
    if labels(i)==1 || labels(i)==2
        col = 'b';      % microsaccade
    elseif labels(i) == 3
        col = 'k';      % amibiguous event
    else
        col = 'r';      % artifact
    end
    if pos>0 && pos<length(trace.time)
        subplot(2,1,2)
        line([pos+100,pos+100], [trace.x(pos)-3, trace.x(pos)+3], 'LineStyle', '--', 'Color', col);
    end
end




