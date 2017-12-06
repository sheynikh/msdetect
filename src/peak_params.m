function [ stats ] = peak_params( mv, peaks, deltap)
    % microsaccade parameters
    % calculate for each event its parameters: index, peak
    % velocity, displacement in xy, amplitude in xy, amplitude, variance of
    % pupil size during the event
    % INPUT:
    %   mv: eyemovement structure
    %   peaks: indices of detected velocity peaks
    %   deltap:  interval over which to calculate statistics
    
    % remove the peaks detected at the beginning and at the end which cannot
    % support a window size of 2*deltap+1
    idx = peaks((peaks-deltap>=1) & (peaks+deltap<=length(mv.vel)));
    if length(peaks)>length(idx)
        fprintf('  %d peaks too close to start or end of trace, removed\n', length(peaks)-length(idx));
    end

    stats.idx       = [];
    stats.x         = [];
    stats.y         = [];
    stats.xp        = [];
    stats.yp        = [];
    stats.xpp       = [];
    stats.ypp       = [];
    %stats.pupil     = [];
    
    stats.velocity  = []; 
    stats.dx        = [];
    stats.dy        = [];
    stats.dX        = [];
    stats.dY        = [];
    stats.amp       = [];
    %stats.pup_var   = [];
    
    for i = 1:length(idx)
        
        rng = idx(i)-deltap : idx(i)+deltap;
        x   = mv.x(rng)';
        y   = mv.y(rng)';
        vx  = mv.velx(rng)';
        vy  = mv.vely(rng)';
        ax  = mv.accx(rng)';
        ay  = mv.accy(rng)';
        %pup = mv.pupil_size(rng)';
        
        if std(x)~=0 && std(y)~=0 && std(vx)~=0 && std(vy)~=0 && std(ax)~=0 && std(ay)~=0 %&& std(pup)~=0
            stats.idx   = [stats.idx;   idx(i)];
            stats.x     = [stats.x;     x];
            stats.y     = [stats.y;     y];
            stats.xp    = [stats.xp;    vx];
            stats.yp    = [stats.yp;    vy];
            stats.xpp   = [stats.xpp;   ax];
            stats.ypp   = [stats.ypp;   ay];
            %stats.pupil = [stats.pupil; pup];

            stats.velocity  = [stats.velocity;  mv.vel(idx(i)) ];
            stats.dx        = [stats.dx;        x(end) - x(1)  ];
            stats.dy        = [stats.dy;        y(end) - y(1)  ];
            [vmax, pmax]    = max(x);
            [vmin, pmin]    = min(x);
            stats.dX        = [stats.dX; (vmax-vmin)*sign(pmax-pmin)];
            [vmax, pmax]    = max(y);
            [vmin, pmin]    = min(y);
            stats.dY        = [stats.dY; (vmax-vmin)*sign(pmax-pmin)];
            %stats.pup_var   = [stats.pup_var; var(pup)];
        end
    end    

    stats.amp = sqrt(stats.dX.^2 +stats.dY.^2);