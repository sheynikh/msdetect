function [ data_aligned ] = alignment( data, breakpts )
% this function is used to align the trace before and after the blink. It
% detects the break points from timestamp and then align value after the break to 
% the value before the break

[m,n] = size(data);

breakpts = unique([1, breakpts(:)', m]);

for i = 1:n
    for j = 2:length(breakpts)-1
        diff = data(breakpts(j),i) - data(breakpts(j)+1,i);
        data(breakpts(j)+1:breakpts(j+1),i) = data(breakpts(j)+1:breakpts(j+1),i) + diff;
    end
end

data_aligned = data;
