%% init
clear all; %close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script load a data file and performs (micro)saccade detection
% The data file consisits of three columns [t,x,y] corresponding to 
% x and y coordinates of detected eye position and recording time.
% The data file can contain concatenated matrices from several trials
% This script attempts to estimate optimal value of the DC parameter 
% using sorted K-dist graph (see choose_dc() function)
% The result of the script is stored into result.mat file
% The script 'plot_result can be used to visualize the result of the algorithm'
% 
% Author: Denis SHEYNIKHOVICH, denis.sheynikhovich@upmc.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('src'); % add functions implementing the algorithm to the Matlab path

%% params
sample_frequency = 1000;    % the method was tested for 1Khz
deltap = 50;                % feature vectors consist of the interval [-deltap,deltap] around a velocity peak

%% load data
datafile = 'data/O01OF.mat';
eyedata = load(datafile);    
fprintf('Eye tracking data loaded from %s\n', datafile);

%% extract features
data = eyedata.recording;
t = data(:,1);   % time stamps concatenated from multiple trials
x = data(:,2);
y = data(:,3);

disp('Extracting position, velocity and acceleration features ...')

% align traces at non consecutive time points
breakpts = find(diff(t)~=1);
x = alignment(x, breakpts);
y = alignment(y, breakpts);

% center the trace
x = x - mean(x);
y = y - mean(y);

% extract features
trace.time = (1:length(x))';
trace.time_orig = t(:);
trace.x = double(x(:));
trace.y = double(y(:));
trace.velx = double(differentiate( trace.x, sample_frequency ));
trace.vely = double(differentiate( trace.y, sample_frequency ));
trace.vel = double(sqrt(trace.velx.^2 + trace.vely.^2));
trace.accx = double(differentiate( trace.velx, sample_frequency ));
trace.accy = double(differentiate( trace.vely, sample_frequency ));
trace.acc = double(sqrt(trace.accx.^2 + trace.accy.^2));
trace.peaks = detect_peak(trace, deltap);

%% choose features
% only horizontal velocity component (only one microsaccade cluster)
n_clusters  = 1;            
features = [normalize(abs(trace.peaks.xp), 0,1)];

% two velocity components (only one microsaccade cluster)
% n_clusters  = 1;            
% features = [normalize(abs(trace.peaks.xp), 0,1), normalize(abs(trace.peaks.yp), 0,1)];

% horizontal position and velocity components (two microsaccade clusters for opposite microsaccades)
%n_clusters  = 2;            
%features = [normalize(abs(trace.peaks.x), 0,1), normalize(abs(trace.peaks.xp), 0,1)];

clusters.features       = features;
clusters.distance_type  = 'correlation';
clusters.dm             = squareform(pdist(clusters.features, clusters.distance_type));

%% determine DC
disp('Estimating DC parameter from data...')
[clusters.dc, clusters.kd_sorted] = choose_dc(clusters.dm);
fprintf('  Dc = %f\n', clusters.dc)

%% clustering
disp('Clustering...')
clusters.rho        = get_rho(clusters.dc, clusters.dm);
clusters.delta      = get_delta(clusters.rho, clusters.dm);
clusters.gamma      = get_gamma(clusters.rho.rho, clusters.delta.delta);
[clusters.labels, clusters.centers, clusters.cindex] = get_clusters(n_clusters, clusters.features, clusters.rho, clusters.delta, clusters.gamma);

%% determine noise
disp('Noise separation ...');
clusters = separate_noise(clusters);                                % determine noise points (they have label 0)
%fprintf('Outliers %d; Total %d\n', length(find(clusters.labels==0)), size(clusters.features,1));

%% get timestamps of detected (micro)saccades
ms_idx = find(clusters.labels ~= 0);            % indices of detected microsaccades
ms_time = trace.peaks.params.idx(ms_idx);       % timestamps of detected microsaccades

%% store result
out_name = 'result';
save(out_name, 'clusters', 'trace', 'ms_time')
fprintf('Clustering results stored into %s.mat\n', out_name)

disp('Done.');




