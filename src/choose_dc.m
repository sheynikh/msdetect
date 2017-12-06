function [ dc, kd_sorted ] = choose_dc( dm )

    % this function chooses the value of DC parameter
    % based on sorted K-dist graph (Ester et al 1996)
    % INPUT:
    %   dm: distance matrix of input data (obtained for example by using
    %   squareform(pdist(x)) where x is the set of inut vectors
    % returns: 
    %   the dc value
    %   the sorted k-dist values

    K       = 4;
    SMOOTH  = 0.1;
    ORDER   = 4;

    N = size(dm,1);
    
    kdist = [];
    for i=1:N
        dist = [dm(i,1:i-1), dm(i,i+1:end)];
        [sorted, ind] = sort(dist);
        kdist = [kdist; sorted(K)];
    end
    kd_sorted = sort(kdist, 'descend');
    framelen = round(SMOOTH*N);
    if ~rem(framelen,2)
        framelen = framelen+1;
    end
    [dx1, dx2, valid] = deriv(kd_sorted, framelen, ORDER, 1);
    [vmax,v_ind] = max(-dx1);
    dc = kd_sorted(v_ind);

function [ dx1, dx2, valid ] = deriv( x, framelen, order, samplerate)

    % this function computes the first and second derivatives of the input
    % sequence using savitzky-golay differentiation filters
    % INPUT:
    %   x: input sequence
    %   framelen: the length of smoothing average filter (must be an odd number), 
    %       Default is 11 for 1KHz .
    %       Set to 6 if samplerate is 500HZ
    %   order: order of the filter, default is 2
    %   samplerate: in Hz, is required to give an accurate scale unit for derivatives, 
    %       Default as 1KHZ
    % returns:
    %   dx1: first derivative
    %   dx2: second derivative
    %   valid: after convolution half-window in the beginning and at the
    %   end of the resulting vector is not usable. This vector returns the
    %   indices of valid points in the output vector

    if nargin < 2 || isempty(framelen)
      framelen = 11;
    end

    if nargin < 3 || isempty(order)
      order = 2;
    end

    if nargin < 4 || isempty(samplerate)
      samplerate = 1000;
    end

    % SG filter
    dt = 1/samplerate;
    [sg1, sg2] = sgolay(order,framelen);

    dx = zeros(length(x),3);
    for p=0:2
        dx(:,p+1) = conv(x, factorial(p)/(-dt)^p * sg2(:,p+1), 'same');
    end

    % valid part of the trace after convolution
    valid = (framelen-1)/2+1:length(x)-(framelen-1)/2;
    dx_valid = dx(valid,:);

    % add startup and terminal transients
    beg = dx_valid(2:(framelen-1)/2+1,:);
    beg = 2*dx_valid(1,:) - beg(length(beg):-1:1,:);
    fin = dx_valid(end-(framelen-1)/2:end-1,:);
    fin = 2*dx_valid(end,:) - fin(length(fin):-1:1,:);
    dx = [beg;dx_valid;fin];

    dx1 = dx(:,2);  % first derivative
    dx2 = dx(:,3);  % second derivative