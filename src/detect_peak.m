function [ peaks ] = detect_peak( mv, deltap)
    % this function is used to select velocity peaks in a trace, generate the potential microsaccade 
    % event features and return several event properties. 
    % INPUT :
    %   mv: stucture variable for eye movement
    %   deltap: minimum distance between neighbouring velocity peaks
    % OUTPUT :
    %   peaks: structure variable contains peaks index and event parameters

    %% default value 
    LAMBDA = 5;
    mindist = 30;

    % find local maxima on velocity trace 
    vx = mv.velx;
    vy = mv.vely; 
    v = mv.vel;
    [pks,locs] = findpeaks(v);

    % remove extreme peaks with too high speed (1000 deg/s)
    ix = find(pks <= 1000);
    locs = locs(ix);
    pks = pks(ix);

    % detect high-speed events using Engber's method 
    % (Engbert & Kiegl,2003)
    mx = MSD(vx, LAMBDA);
    my = MSD(vy, LAMBDA);
    radius = (vx(locs)/mx).^2 + (vy(locs)/my).^2;

    ix = find(radius>1);
    locs = locs(ix);
    pks = pks(ix);

    criteria = radius(ix);

    peaks.index = locs;

    [~, ord] = sort(criteria, 'descend');
    index_sorted = peaks.index(ord);

    % remove peaks which are closer then deltap
    truepeaks = ones(length(index_sorted),1);
    i = 1;
    while i <= length(index_sorted)
        endL = max(1, index_sorted(i)- mindist);
        endR = min(index_sorted(i) + mindist, length(v(:)));
        vel = v(endL:endR);
        overlap = find(index_sorted((i+1):end) > endL & index_sorted((i+1):end) < endR);

        if isempty(find(vel > v(index_sorted(i)), 1))
            truepeaks(i+overlap) = 0;
            i = i+1;
        else
            truepeaks(i) = 0;
        end

        index_sorted(truepeaks == 0) = [];
        truepeaks(truepeaks == 0) = [];
    end

    peaks.index = sort(index_sorted);

    % calculate statistics over interval 
    stats = peak_params(mv, peaks.index, deltap);

    peaks.x = stats.x;
    peaks.y = stats.y;
    peaks.xp = stats.xp;
    peaks.yp = stats.yp;
    peaks.xpp = stats.xpp;
    peaks.ypp = stats.ypp;
    %peaks.pupil = stats.pupil;

    peaks.params.idx = stats.idx;
    peaks.params.velocity = stats.velocity; 
    peaks.params.dx = stats.dx;
    peaks.params.dy = stats.dy;
    peaks.params.dX = stats.dX;
    peaks.params.dY = stats.dY;
    peaks.params.amp = stats.amp;
    %peaks.params.pup_var = stats.pup_var;


function [value] = MSD( data, threshold )
    % this function is used to calculate the median standard deviation of input
    % values
    value = sqrt(median(data.^2)- median(data)^2);    
    if value <= realmin
        value = sqrt(mean(data.^2)- mean(data)^2);
    end
    value = threshold * value;     