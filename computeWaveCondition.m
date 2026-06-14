function out = computeWaveCondition(H, T, d, varargin)
% COMPUTEWAVECONDITION  Non-dimensional wave params + theory recommendation.
% Supports regular and irregular waves with Rayleigh-statistic conversion.
%
% Usage:
%   out = computeWaveCondition(H, T, d)
%   out = computeWaveCondition(Hs, Tp, d, 'waveType','irregular', ...
%                              'Hkind','Hs','plotKind','Hmax','Nwaves',1000)

    p = inputParser;
    addParameter(p,'g',9.81);
    addParameter(p,'waveType','regular');
    addParameter(p,'Hkind','Hs');
    addParameter(p,'plotKind','Hs');
    addParameter(p,'Nwaves',1000);
    parse(p,varargin{:});
    g        = p.Results.g;
    waveType = lower(p.Results.waveType);
    Hkind    = p.Results.Hkind;
    plotKind = p.Results.plotKind;
    Nwaves   = p.Results.Nwaves;

    % linear dispersion: omega^2 = g*k*tanh(k*d)
    omega = 2*pi/T;
    k = omega^2/g;
    for it = 1:200
        f  = g*k*tanh(k*d) - omega^2;
        fp = g*tanh(k*d) + g*k*d*sech(k*d)^2;
        dk = -f/fp; k = k + dk;
        if abs(dk) < 1e-12, break; end
    end
    L = 2*pi/k;

    if strcmp(waveType,'regular')
        Hs = H; Hplot = H;
    else
        Hs    = toHs(H, Hkind, Nwaves);
        Hplot = fromHs(Hs, plotKind, Nwaves);
    end

    out.waveType = waveType;
    out.Hkind    = Hkind;
    out.plotKind = plotKind;
    out.Hinput   = H;
    out.Hs       = Hs;
    out.Hplot    = Hplot;
    out.T        = T;
    out.d        = d;
    out.L        = L;
    out.k        = k;
    out.dL       = d/L;
    out.HL       = Hplot/L;
    out.Ur       = (Hplot/L)/(d/L)^3;
    out.dgT2     = d/(g*T^2);
    out.HgT2     = Hplot/(g*T^2);

    if out.dL < 0.05,      out.regime = 'Shallow water';
    elseif out.dL > 0.5,   out.regime = 'Deep water';
    else,                  out.regime = 'Intermediate depth';
    end

    x = out.dL;
    out.HLbreak = x*(0.141063*x^2 + 0.0095721*x + 0.0077829) / ...
                   (x^3 + 0.0788340*x^2 + 0.0317567*x + 0.0093407);
    out.broken = out.HL > out.HLbreak;

    if out.broken
        out.theory = 'BREAKING - no periodic theory valid';
        return
    end

    if out.Ur > 26
        out.theory = 'Cnoidal wave theory';
    else
        [HL2,HL3,HL4,HL5] = stokesOrderCurves(out.dL);
        if     out.HL <= HL2, out.theory = 'Linear (Airy) wave';
        elseif out.HL <= HL3, out.theory = 'Stokes 2nd order';
        elseif out.HL <= HL4, out.theory = 'Stokes 3rd order';
        elseif out.HL <= HL5, out.theory = 'Stokes 4th order';
        else,                 out.theory = 'Stokes 5th order';
        end
    end
end

function Hs = toHs(H, kind, N)
    switch upper(strrep(kind,'/',''))
        case {'HS','HM0','H13'}, Hs = H;
        case 'HRMS',             Hs = H * sqrt(2);
        case 'HMAX',             Hs = H / sqrt(0.5*log(N));
        otherwise, error('Unknown Hkind: %s', kind);
    end
end

function Ht = fromHs(Hs, kind, N)
    switch upper(strrep(kind,'/',''))
        case {'HS','HM0','H13'}, Ht = Hs;
        case 'HRMS',             Ht = Hs / sqrt(2);
        case 'HMAX',             Ht = Hs * sqrt(0.5*log(N));
        otherwise, error('Unknown plotKind: %s', kind);
    end
end