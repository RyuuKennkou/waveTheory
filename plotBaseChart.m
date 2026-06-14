function ax = plotBaseChart(parentAx, opts)
% PLOTBASECHART  Wave-theory regime-selection chart (v4).
%   Filled colour regions for each theory domain, curves clipped at the
%   breaking criterion.  Stokes 2-5 order, Cnoidal (Ur = 26), and Fenton
%   breaking criterion.  Depth-regime dividers at d/L = 0.05 and 0.5.
%
% Usage
%   plotBaseChart();
%   plotBaseChart(ax);
%   plotBaseChart([], struct('widthCm',12));
%
% opts (all optional):
%   widthCm           default 12   (only when creating own figure)
%   heightCm          default 12
%   axisLabelFontSize default 10 pt
%   tickFontSize      default 9  pt
%   textFontSize      default 8  pt
%   fontName          default 'Times New Roman'

    def = struct('widthCm',12,'heightCm',12, ...
                 'axisLabelFontSize',10,'tickFontSize',9,'textFontSize',8, ...
                 'fontName','Times New Roman');
    if nargin < 2 || isempty(opts), opts = struct(); end
    f0 = fieldnames(def);
    for i = 1:numel(f0)
        if ~isfield(opts,f0{i}), opts.(f0{i}) = def.(f0{i}); end
    end
    fzAx  = opts.axisLabelFontSize;
    fzTk  = opts.tickFontSize;
    fzTx  = opts.textFontSize;
    fname = opts.fontName;

    if nargin < 1 || isempty(parentAx)
        fig = figure('Color','w','Units','centimeters', ...
                     'PaperUnits','centimeters');
        pos = get(fig,'Position');
        set(fig,'Position',[pos(1) pos(2) opts.widthCm opts.heightCm], ...
                'PaperSize',[opts.widthCm opts.heightCm], ...
                'PaperPosition',[0 0 opts.widthCm opts.heightCm]);
        ax = axes(fig);
        set(ax,'Units','normalized','Position',[0.15 0.13 0.80 0.82]);
    else
        ax = parentAx;
        cla(ax,'reset');
    end
    hold(ax,'on'); box(ax,'on');
    set(ax,'XScale','log','YScale','log', ...
        'FontName',fname,'FontSize',fzTk,'LineWidth',0.8, ...
        'TickDir','in','XMinorTick','on','YMinorTick','on', ...
        'Layer','top');
    set(ax,'XColor','k','YColor','k');
    xlabel(ax,'{\itd} / {\itL}  [-]','FontName',fname,'FontSize',fzAx);
    ylabel(ax,'{\itH} / {\itL}  [-]','FontName',fname,'FontSize',fzAx);

    xMin = 1e-2; xMax = 1; yMin = 1e-5; yMax = 0.3;
    xlim(ax,[xMin xMax]); ylim(ax,[yMin yMax]);

    % ---- compute all curves ----
    dL = logspace(log10(xMin), log10(xMax), 400);
    [HL2, HL3, HL4, HL5] = stokesOrderCurves(dL);

    % Breaking criterion (Fenton 1990 eq.7)
    HLbreak = dL .* (0.141063*dL.^2 + 0.0095721*dL + 0.0077829) ./ ...
                  (dL.^3 + 0.0788340*dL.^2 + 0.0317567*dL + 0.0093407);

    % Cnoidal cutoff  Ur = (H/L)/(d/L)^3 = 26   =>   H/L = 26*(d/L)^3
    HL_Ur = 26 * dL.^3;

    % ---- helper: fill a band between two curves ----
    function fillBand(ylo, yhi, col, alpha)
        ylo = max(ylo, yMin);
        yhi = min(yhi, yMax);
        ok = ylo < yhi;
        if ~any(ok), return; end
        xf = [dL(ok), fliplr(dL(ok))];
        yf = [ylo(ok), fliplr(yhi(ok))];
        fill(ax, xf, yf, col, 'EdgeColor','none', ...
             'FaceAlpha', alpha, 'HandleVisibility','off');
    end

    % ---- filled regions  (bottom → top, later overlays earlier) ----
    % Linear
    fillBand(repmat(yMin, size(dL)), min(min(HL2, HL_Ur), HLbreak), ...
             [0.94 0.97 0.99], 0.55);
    % Stokes 2nd
    fillBand(HL2, min(min(HL3, HL_Ur), HLbreak), ...
             [0.78 0.90 0.98], 0.55);
    % Stokes 3rd
    fillBand(HL3, min(min(HL4, HL_Ur), HLbreak), ...
             [0.62 0.82 0.96], 0.55);
    % Stokes 4th
    fillBand(HL4, min(min(HL5, HL_Ur), HLbreak), ...
             [0.48 0.72 0.94], 0.55);
    % Stokes 5th  (where Ur <= 26, i.e. below the Cnoidal cutoff)
    fillBand(HL5, min(HL_Ur, HLbreak), ...
             [0.35 0.60 0.90], 0.55);
    % Cnoidal  (Ur > 26, below breaking)
    fillBand(HL_Ur, HLbreak, ...
             [0.98 0.82 0.60], 0.60);
    % White cover above breaking  (no valid theory)
    yTop = repmat(yMax, size(dL));
    fillBand(HLbreak, yTop, [1 1 1], 1.0);

    % ---- clip curves at breaking criterion (erase above) ----
    HL2(HL2 > HLbreak) = NaN;
    HL3(HL3 > HLbreak) = NaN;
    HL4(HL4 > HLbreak) = NaN;
    HL5(HL5 > HLbreak) = NaN;
    HL_Ur(HL_Ur > HLbreak) = NaN;

    % ---- depth-regime dividers ----
    yLine = [yMin yMax];
    plot(ax,[0.05 0.05],yLine,'--','Color',[.45 .45 .45],'LineWidth',0.6);
    plot(ax,[0.5  0.5 ],yLine,'--','Color',[.45 .45 .45],'LineWidth',0.6);

    % Curves on top of fills
    plot(ax,dL,HL2,'k-','LineWidth',0.8);
    plot(ax,dL,HL3,'k-','LineWidth',0.8);
    plot(ax,dL,HL4,'k-','LineWidth',0.8);
    plot(ax,dL,HL5,'k-','LineWidth',0.8);
    plot(ax,dL,HLbreak,'-','Color',[0.10 0.45 0.85],'LineWidth',1.5);
    msk_u = HL_Ur >= yMin & HL_Ur <= yMax & ~isnan(HL_Ur);
    plot(ax,dL(msk_u),HL_Ur(msk_u),':','Color',[0.85 0.35 0.10],'LineWidth',1.3);

    % ---- text labels ----
    % depth regime
    text(ax,0.022,3.5e-5,'Shallow',     'HorizontalAlignment','center', ...
        'FontName',fname,'FontSize',fzTx,'Color',[.3 .3 .3]);
    text(ax,0.158,3.5e-5,'Intermediate','HorizontalAlignment','center', ...
        'FontName',fname,'FontSize',fzTx,'Color',[.3 .3 .3]);
    text(ax,0.72, 3.5e-5,'Deep',        'HorizontalAlignment','center', ...
        'FontName',fname,'FontSize',fzTx,'Color',[.3 .3 .3]);

    text(ax,0.05,6e-4,'{\itd}/{\itL} = 0.05','Rotation',90, ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontName',fname,'FontSize',fzTx*0.9,'Color',[.3 .3 .3], ...
        'BackgroundColor','w','Margin',1);
    text(ax,0.5, 6e-4,'{\itd}/{\itL} = 0.5','Rotation',90, ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontName',fname,'FontSize',fzTx*0.9,'Color',[.3 .3 .3], ...
        'BackgroundColor','w','Margin',1);

    % Stokes order labels
    text(ax,0.93,0.0090,'2nd order','HorizontalAlignment','right', ...
        'FontName',fname,'FontSize',fzTx);
    text(ax,0.93,0.058 ,'3rd order','HorizontalAlignment','right', ...
        'FontName',fname,'FontSize',fzTx);
    text(ax,0.93,0.0795 ,'4th order','HorizontalAlignment','right', ...
        'FontName',fname,'FontSize',fzTx);
    text(ax,0.93,0.115 ,'5th order','HorizontalAlignment','right', ...
        'FontName',fname,'FontSize',fzTx);

    % Breaking
    text(ax,0.11,0.20,'Breaking criterion', ...
        'Color',[0.10 0.45 0.85],'FontName',fname, ...
        'FontSize',fzTx,'FontWeight','bold');

    % Cnoidal
    text(ax,0.027,1.2e-3,'Cnoidal wave theory', ...
        'Color',[0.85 0.35 0.10],'FontName',fname, ...
        'FontSize',fzTx,'Rotation',58);
    text(ax,0.055,2.0e-3,'{\itUr} = 26', ...
        'Color',[0.10 0.45 0.85],'FontName',fname, ...
        'FontSize',fzTx,'Rotation',58);

    % Stokes / linear
    text(ax,0.12,7e-4,'Stokes wave, linear', ...
        'FontName',fname,'FontSize',fzTx+1);

    % 重新设置tick颜色，显示在色块之上
    set(ax,'XColor','k','YColor','k');
    
    hold(ax,'off');
end
