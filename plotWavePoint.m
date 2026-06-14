function h = plotWavePoint(ax, cond, label, varargin)
% PLOTWAVEPOINT  Overlay one wave condition on the base chart.
%
% Name-value options:
%   'MarkerSize' (default 24), 'FontSize' (default 10),
%   'FontName'   (default 'Times New Roman'),
%   'MarkerColor'(default []), 'ShowLabel' (default true)

    p = inputParser;
    addParameter(p,'MarkerSize',24);
    addParameter(p,'FontSize',10);
    addParameter(p,'FontName','Times New Roman');
    addParameter(p,'MarkerColor',[]);
    addParameter(p,'ShowLabel',true);
    parse(p,varargin{:});

    if nargin < 3, label = ''; end
    
    if ~isempty(p.Results.MarkerColor)
        col = p.Results.MarkerColor;
    elseif cond.broken
        col = [1 0 0];
    elseif strcmp(cond.waveType,'irregular')
        col = [0 .35 .8];
    else
        col = [0 .55 0];
    end
    
    if cond.broken
        mk = 'x'; sz = p.Results.MarkerSize+12;
    else
        mk = 'o'; sz = p.Results.MarkerSize;
    end
    
    hold(ax,'on');
    h = scatter(ax, cond.dL, cond.HL, sz, col, mk, 'filled', ...
                'LineWidth',1.5);
    if p.Results.ShowLabel && ~isempty(label)
        text(ax, cond.dL*1.08, cond.HL*1.05, label, ...
            'FontName',p.Results.FontName,'FontSize',p.Results.FontSize, ...
            'FontWeight','bold','Color',col);
    end
    hold(ax,'off');
end