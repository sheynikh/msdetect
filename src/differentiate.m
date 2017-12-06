function [ data_diff ] = differentiate( data, sample_rate, kernel_size )

% this function will compute the first order derivative of the input
% sequence. 
% INPUT:
%   data: input sequence, can be position profile or velocity profile
%   sample_rate: to give an accurate scale unit for derivatives, default as 1000HZ
%   kernel_size: the length of smoothing average filter, default is 12.
%       Suggest to set as 6 if sample_rate is 500HZ

if nargin < 2 || isempty(sample_rate)
  sample_rate = 1000;
end

if nargin < 3 || isempty(kernel_size)
  kernel_size = 12;
end

if kernel_size == 6
    kernel = [1,1,0,-1,-1] .* (sample_rate / 6);
elseif kernel_size == 12
    %kernel = [1,1,1,1,1,0,-1,-1,-1,-1,-1] .* (sample_rate / 12);
    kernel = [1,1,1,1,1,0,-1,-1,-1,-1,-1] .* (sample_rate / 30);
else
    disp(['ERROR: wrong kernel size in differentiate(): ', kernel_size])
end

%% convolve the smoothing kernel with input sequence
pad_length = ceil(length(kernel)/2);
data = padding(data, pad_length, 'mean');    
data_diff = convn(data, kernel', 'same');
data_diff = padding(data_diff, pad_length, 'remove');


function [data_pad] = padding( data, pad_length, type )
% this function is used to pad or remove values at the begining and at the end of
% trace. 
if nargin < 3 || isempty(type)
  type = 'mean';
end

if strcmp(type,'mean')
    pad = min( pad_length, floor(size(data,1)/2) );
    premean = mean(data(1:pad, :));
    postmean = mean(data(end-pad:end,:));
    data_pad = [premean * ones(pad_length, size(data,2)); data; postmean * ones(pad_length, size(data,2))];
    
else if strcmp(type, 'remove')
            data_pad = data(1+pad_length:end-pad_length, :);
    end
end

%% same method as convolution, just different way of calulation
% [N, M] = size(data);
% 
% w = window(@bartlett, kernel_size);
% xf = filter(w/sum(w),1,data);
% dxf = diff(xf)*sample_rate;
% 
% v = zeros(N,M);
% v(1:end-3,:) = dxf(3:end,:);
% data_diff = v;
