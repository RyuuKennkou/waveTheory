function fns = exportChart(results, fileBase, varargin)
% EXPORTCHART  Export the wave-theory chart to PNG + SVG at journal quality.
%
% Uses YOUR helper:  exportFig(f, basename, dpi)  if it is on the MATLAB
% path.  Otherwise falls back to exportgraphics (PNG) + print -dsvg (SVG).
%
% Usage:
%   exportChart(results)
%   exportChart(results,'fig_le_mehaute','widthCm',12,'dpi',1200)
%   exportChart([], 'fig_base_only','widthCm',15,'dpi',1200)

    p = inputParser;
    addParameter(p,'widthCm',12);
    addParameter(p,'heightCm',[]);
    addParameter(p,'dpi',1200);
    addParameter(p,'fontName','Times New Roman');
    addParameter(p,'axisLabelFontSize',10);
    addParameter(p,'tickFontSize',9);
    addParameter(p,'textFontSize',8);
    parse(p,varargin{:});
    w   = p.Results.widthCm;
    hh  = p.Results.heightCm; if isempty(hh), hh = w; end
    dpi = p.Results.dpi;
    fname = p.Results.fontName;

    if nargin < 2 || isempty(fileBase)
        fileBase = sprintf('wave_theory_chart_%s', ...
                           datestr(now,'yyyymmdd_HHMMSS'));
    end

    % off-screen, exact-size figure
    fig = figure('Color','w','Units','centimeters', ...
                 'PaperUnits','centimeters','Visible','off');
    set(fig,'Position',[2 2 w hh], ...
            'PaperSize',[w hh],'PaperPosition',[0 0 w hh]);
    ax = axes(fig);

    opts = struct('widthCm',w,'heightCm',hh, ...
        'axisLabelFontSize',p.Results.axisLabelFontSize, ...
        'tickFontSize',     p.Results.tickFontSize, ...
        'textFontSize',     p.Results.textFontSize, ...
        'fontName',fname);
    plotBaseChart(ax, opts);

    if nargin >= 1 && ~isempty(results)
        for i = 1:numel(results)
            plotWavePoint(ax, results(i).cond, results(i).label, ...
                          'FontName',fname, ...
                          'FontSize',p.Results.textFontSize+1, ...
                          'MarkerSize',48);
        end
    end

    % Prefer user's exportFig; fallback otherwise
    if exist('exportFig','file') == 2
        try
            exportFig(fig, fileBase, dpi);
            fns = {[fileBase '.png'], [fileBase '.svg']};
        catch ME
            warning('exportFig failed (%s); falling back.', ME.message);
            fns = fallbackExport(fig, fileBase, dpi);
        end
    else
        fns = fallbackExport(fig, fileBase, dpi);
    end
    close(fig);
end

function fns = fallbackExport(fig, fileBase, dpi)
    fns = {[fileBase '.png']};
    exportgraphics(fig, fns{1}, 'Resolution', dpi);
    try
        set(fig,'Renderer','painters');
        print(fig, [fileBase '.svg'], '-dsvg');
        fns{end+1} = [fileBase '.svg'];
    catch
        warning('SVG export failed; only PNG saved.');
    end
end