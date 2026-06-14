function waveTheoryGUI
% WAVETHEORYGUI v5 - Left-right layout
%   - Chart is an independent figure (centimeter-based, 12x12 cm)
%   - GUI panel with left-right layout
%   - Left: single-point input + result; Right: batch + export

    FN = 'Times New Roman';

    screenDPI = get(groot,'ScreenPixelsPerInch');
    px2cm = @(px) px / screenDPI * 2.54;
    cm2px = @(cm) cm / 2.54 * screenDPI;

    chartFig = figure('Name','Wave Theory Chart  (12 x 12 cm)', ...
                      'Units','centimeters', ...
                      'Position',[0 0 12 12], ...
                      'PaperUnits','centimeters', ...
                      'PaperSize',[12 12], ...
                      'PaperPosition',[0 0 12 12], ...
                      'Color','w', ...
                      'Visible','off', ...
                      'HandleVisibility','on');
    chartAx = axes(chartFig);
    set(chartAx,'Units','normalized','Position',[0.15 0.13 0.80 0.82]);

    guiOpts = struct('widthCm',12,'heightCm',12, ...
                     'fontName',FN, ...
                     'textFontSize',8,'axisLabelFontSize',10,'tickFontSize',9);

    f = uifigure('Name','Wave Theory Controls v5', ...
                 'Position',[60 40 560 710], ...
                 'CloseRequestFcn',@(~,~) onClose());

    chartLeft_cm = px2cm(60 + 520 + 12);
    chartBot_cm  = px2cm(40 + max(0,(680 - cm2px(12))/2));
    chartFig.Position = [chartLeft_cm chartBot_cm 12 12];
    chartFig.Visible = 'on';

    plotBaseChart(chartAx, guiOpts);
    results = struct('label',{},'cond',{},'color',{});
    colorbarVisible = false;
    legendH = [];

    % ======== LEFT COLUMN ========
    % --- Panel 1: single-point input (left-top) ---
    p1 = uipanel(f,'Title','Single wave condition', ...
        'Position',[10 340 245 340],'FontWeight','bold','FontName',FN);

    uilabel(p1,'Position',[10 295 80 18],'Text','Wave type','FontName',FN);
    ddType = uidropdown(p1,'Position',[95 293 140 22], ...
        'Items',{'regular','irregular'},'Value','regular','FontName',FN, ...
        'ValueChangedFcn',@(s,~) onTypeChanged(s));

    uilabel(p1,'Position',[10 265 80 18],'Text','H  (m)','FontName',FN);
    eH = uieditfield(p1,'numeric','Position',[95 263 60 22], ...
                     'Value',1.0,'FontName',FN);

    uilabel(p1,'Position',[10 235 80 18],'Text','T  (s)','FontName',FN);
    eT = uieditfield(p1,'numeric','Position',[95 233 60 22], ...
                     'Value',6.0,'FontName',FN);

    uilabel(p1,'Position',[10 205 80 18],'Text','d  (m)','FontName',FN);
    eh = uieditfield(p1,'numeric','Position',[95 203 60 22], ...
                     'Value',5.0,'FontName',FN);

    uilabel(p1,'Position',[10 175 80 18],'Text','Label','FontName',FN);
    eLab = uieditfield(p1,'text','Position',[95 173 60 22], ...
                       'Value','C1','FontName',FN);

    uilabel(p1,'Position',[10 145 80 18],'Text','Marker color','FontName',FN);
    ddMarker = uidropdown(p1,'Position',[95 143 140 22], ...
        'Items',{'Auto','Red','Green','Blue','Yellow','Magenta','Cyan','Black','White'}, ...
        'Value','Auto','FontName',FN);

    uilabel(p1,'Position',[10 115 80 18],'Text','Point size','FontName',FN);
    eSize = uieditfield(p1,'numeric','Position',[95 113 50 22], ...
                        'Value',24,'Limits',[6 60],'FontName',FN);

    cbLabel = uicheckbox(p1,'Position',[10 88 100 18], ...
        'Text','Show label','Value',true,'FontName',FN);

    % Irregular-only fields
    lblHkind = uilabel(p1,'Position',[10 58 80 18], ...
                       'Text','Input H is','FontName',FN);
    ddHkind  = uidropdown(p1,'Position',[95 56 140 22], ...
        'Items',{'Hs','H1/3','Hm0','Hrms','Hmax'},'Value','Hs','FontName',FN);
    lblPlot  = uilabel(p1,'Position',[10 30 80 18], ...
                       'Text','Plot as','FontName',FN);
    ddPlot   = uidropdown(p1,'Position',[95 28 140 22], ...
        'Items',{'Hs','H1/3','Hrms','Hmax'},'Value','Hs','FontName',FN);
    lblN     = uilabel(p1,'Position',[10 5 80 18], ...
                       'Text','N waves','FontName',FN);
    eN       = uieditfield(p1,'numeric','Position',[95 3 60 22], ...
                           'Value',1000,'FontName',FN);

    onTypeChanged(ddType);

    % --- Panel 3: result (left-bottom) ---
    p3 = uipanel(f,'Title','Result','Position',[10 10 245 320], ...
                 'FontWeight','bold','FontName',FN);
    res = uitextarea(p3,'Position',[8 8 228 288],'Editable','off', ...
        'FontName','Consolas','FontSize',10, ...
        'Value',{'Result will be shown here.'});

    % ======== RIGHT COLUMN ========
    % --- Panel 2: batch table (right-top) ---
    p2 = uipanel(f,'Title','Batch input', ...
        'Position',[265 340 285 340],'FontWeight','bold','FontName',FN);

    tbl = uitable(p2,'Position',[8 55 268 260], ...
        'Data',{1.0,6.0,5.0,'regular','C1'; ...
                2.0,8.0,5.0,'irregular','C2'}, ...
        'ColumnName',{'H(m)','T(s)','d(m)','Type','Label'}, ...
        'ColumnEditable',true(1,5), ...
        'ColumnWidth',{45,45,45,70,65}, ...
        'FontName',FN);

    uibutton(p2,'Position',[8 15 70 30],'Text','Add', ...
        'FontName',FN,'ButtonPushedFcn',@(~,~) addRow());
    uibutton(p2,'Position',[82 15 70 30],'Text','Remove', ...
        'FontName',FN,'ButtonPushedFcn',@(~,~) removeRow());
    uibutton(p2,'Position',[155 15 105 30],'Text','Plot all', ...
        'FontWeight','bold','FontName',FN, ...
        'BackgroundColor',[.80 .95 .80], ...
        'ButtonPushedFcn',@(~,~) onPlotBatch());

    % --- Action buttons (right-middle) ---
    uibutton(f,'Position',[265 285 90 45],'Text','Plot', ...
        'FontWeight','bold','FontName',FN, ...
        'BackgroundColor',[.80 .95 .80], ...
        'ButtonPushedFcn',@(~,~) onPlotSingle());
    uibutton(f,'Position',[360 285 90 45],'Text','Clear', ...
        'FontWeight','bold','FontName',FN, ...
        'BackgroundColor',[1 .82 .82], ...
        'ButtonPushedFcn',@(~,~) onClear());
    uibutton(f,'Position',[455 285 90 45],'Text','Legend', ...
        'FontWeight','bold','FontName',FN, ...
        'BackgroundColor',[.85 .88 .98], ...
        'ButtonPushedFcn',@(~,~) onToggleColorbar());

    % --- Panel 4: export (right-bottom) ---
    p4 = uipanel(f,'Title','Export', ...
        'Position',[265 10 285 265],'FontWeight','bold','FontName',FN);

    uilabel(p4,'Position',[10 220 65 18],'Text','Width (cm)','FontName',FN);
    eWcm = uieditfield(p4,'numeric','Position',[80 218 50 22], ...
                       'Value',12,'Limits',[9 15],'FontName',FN);

    uilabel(p4,'Position',[145 220 30 18],'Text','DPI','FontName',FN);
    eDPI = uieditfield(p4,'numeric','Position',[180 218 70 22], ...
                       'Value',1200,'Limits',[150 4800],'FontName',FN);

    uibutton(p4,'Position',[10 170 265 35],'Text','Export PNG + SVG', ...
        'FontWeight','bold','FontName',FN, ...
        'BackgroundColor',[.95 .88 .80], ...
        'ButtonPushedFcn',@(~,~) onExportFigure());

    uibutton(p4,'Position',[10 125 265 35],'Text','Export CSV', ...
        'FontWeight','bold','FontName',FN, ...
        'BackgroundColor',[.90 .90 .95], ...
        'ButtonPushedFcn',@(~,~) exportCSV());

    uilabel(p4,'Position',[10 100 260 28],'Text', ...
        'Note: Batch table uses H,T,d,Type,Hkind,Plot,N,Label.', ...
        'FontName',FN,'FontSize',8,'FontColor',[.4 .4 .4]);

    % ===== callbacks =====
    function onTypeChanged(src)
        isIrr = strcmp(src.Value,'irregular');
        if isIrr
            stIrr = 'on';  colIrr = [0 0 0];
        else
            stIrr = 'off'; colIrr = [0.55 0.55 0.55];
        end
        ddHkind.Enable = stIrr; ddPlot.Enable = stIrr; eN.Enable = stIrr;
        lblHkind.FontColor = colIrr;
        lblPlot.FontColor  = colIrr;
        lblN.FontColor     = colIrr;
    end

    function ensureChart()
        if ~isvalid(chartFig) || ~isvalid(chartAx)
            error('Chart figure was closed. Please restart the GUI.');
        end
    end

    function onPlotSingle()
        try ensureChart(); catch ME, res.Value={ME.message}; return; end
        H = eH.Value; T = eT.Value; d = eh.Value;
        if H<=0 || T<=0 || d<=0
            res.Value = {'Error: H, T, d must all be positive.'}; return
        end
        if strcmp(ddType.Value,'regular')
            c = computeWaveCondition(H,T,d);
        else
            c = computeWaveCondition(H,T,d, ...
                'waveType','irregular','Hkind',ddHkind.Value, ...
                'plotKind',ddPlot.Value,'Nwaves',eN.Value);
        end
        
        markerColor = parseMarkerColor(ddMarker.Value);
        actualColor = getActualColor(c, markerColor);
        plotWavePoint(chartAx,c,eLab.Value,'FontName',FN, ...
                      'FontSize',guiOpts.textFontSize+1, ...
                      'MarkerSize',eSize.Value, ...
                      'MarkerColor',markerColor, ...
                      'ShowLabel',cbLabel.Value);
        results(end+1) = struct('label',eLab.Value,'cond',c,'color',actualColor);
        res.Value = formatResult(c, eLab.Value);
    end

    function onPlotBatch()
        try ensureChart(); catch ME, res.Value={ME.message}; return; end
        D = tbl.Data; msgs = {};
        markerColor = parseMarkerColor(ddMarker.Value);
        for i = 1:size(D,1)
            try
                H = D{i,1}; T = D{i,2}; d = D{i,3};
                type = D{i,4}; lab = D{i,5};
                if isempty(H) || isempty(T) || isempty(d), continue; end
                if strcmpi(type,'regular')
                    c = computeWaveCondition(H,T,d);
                else
                    c = computeWaveCondition(H,T,d, ...
                        'waveType','irregular','Hkind','Hs', ...
                        'plotKind','Hs','Nwaves',1000);
                end
                markerColor = parseMarkerColor(ddMarker.Value);
                actualColor = getActualColor(c, markerColor);
                plotWavePoint(chartAx,c,lab,'FontName',FN, ...
                              'FontSize',guiOpts.textFontSize+1, ...
                              'MarkerSize',eSize.Value, ...
                              'MarkerColor',markerColor, ...
                              'ShowLabel',cbLabel.Value);
                results(end+1) = struct('label',lab,'cond',c,'color',actualColor);
                msgs{end+1} = sprintf('%s: %s', lab, c.theory); %#ok<AGROW>
            catch ME
                msgs{end+1} = sprintf('Row %d ERROR: %s', i, ME.message); %#ok<AGROW>
            end
        end
        if isempty(msgs), msgs = {'No rows to plot.'}; end
        res.Value = msgs;
    end

    function addRow()
        D = tbl.Data;
        D(end+1,:) = {1.0,6.0,5.0,'regular', ...
                      sprintf('C%d',size(D,1)+1)};
        tbl.Data = D;
    end

    function removeRow()
        D = tbl.Data;
        if size(D,1) > 0, D(end,:) = []; end
        tbl.Data = D;
    end

    function onClear()
        try ensureChart(); catch ME, res.Value={ME.message}; return; end
        plotBaseChart(chartAx, guiOpts);
        results = struct('label',{},'cond',{});
        if ~isempty(legendH) && isvalid(legendH)
            delete(legendH);
            legendH = [];
        end
        colorbarVisible = false;
        res.Value = {'Cleared all points.'};
    end

    function onToggleColorbar()
        try ensureChart(); catch ME, res.Value={ME.message}; return; end
        if isempty(results)
            res.Value = {'No points to show in legend.'}; return
        end
        colorbarVisible = ~colorbarVisible;
        if colorbarVisible
            updateColorbar();
            res.Value = {'Legend shown.'};
        else
            if ~isempty(legendH) && isvalid(legendH)
                delete(legendH);
                legendH = [];
            end
            res.Value = {'Legend hidden.'};
        end
    end

    function updateColorbar()
        if ~isempty(legendH) && isvalid(legendH)
            delete(legendH);
        end
        
        % 合并同类标签，使用每个点保存的颜色
        uniqueLabels = {};
        uniqueColors = {};
        uniqueMarkers = {};
        for i = 1:numel(results)
            lab = results(i).label;
            c = results(i).cond;
            
            % 检查是否已存在相同标签
            found = false;
            for j = 1:numel(uniqueLabels)
                if strcmp(uniqueLabels{j}, lab)
                    found = true;
                    break;
                end
            end
            
            if ~found
                uniqueLabels{end+1} = lab;
                uniqueColors{end+1} = results(i).color;
                if c.broken
                    uniqueMarkers{end+1} = 'x';
                else
                    uniqueMarkers{end+1} = 'o';
                end
            end
        end
        
        hold(chartAx,'on');
        h = gobjects(1, numel(uniqueLabels));
        for i = 1:numel(uniqueLabels)
            h(i) = scatter(chartAx, NaN, NaN, 1, uniqueColors{i}, uniqueMarkers{i}, ...
                'filled', 'LineWidth',1.5, 'DisplayName', uniqueLabels{i});
        end
        hold(chartAx,'off');
        
        if ~isempty(uniqueLabels)
            legendH = legend(chartAx, h, 'Location','northwest', ...
                'Orientation','vertical', 'FontSize',8, ...
                'FontName',guiOpts.fontName, 'Box','on');
        end
    end

    function onExportFigure()
        if ~isvalid(chartFig)
            res.Value = {'Error: Chart figure was closed. Restart GUI.'};
            return
        end
        fileBase = sprintf('wave_theory_chart_%s', ...
                           datestr(now,'yyyymmdd_HHMMSS'));
        try
            exportgraphics(chartFig, [fileBase '.png'], ...
                           'Resolution',eDPI.Value,'ContentType','image');
            origRenderer = chartFig.Renderer;
            chartFig.Renderer = 'painters';
            print(chartFig, [fileBase '.svg'], '-dsvg');
            chartFig.Renderer = origRenderer;
            msg = {sprintf('Exported at %.1f cm, %d dpi:', ...
                           eWcm.Value, eDPI.Value), ...
                   ['  ' fileBase '.png'], ['  ' fileBase '.svg']};
            res.Value = msg;
        catch ME
            res.Value = {sprintf('Export error: %s', ME.message)};
        end
    end

    function exportCSV()
        if isempty(results)
            res.Value = {'No results to export.'}; return
        end
        fn = sprintf('wave_theory_results_%s.csv', ...
                     datestr(now,'yyyymmdd_HHMMSS'));
        fid = fopen(fn,'w');
        fprintf(fid,['Label,waveType,Hinput,Hkind,Hplot,plotKind,Hs,', ...
                     'T,d,L,d_over_L,H_over_L,Ur,d_over_gT2,H_over_gT2,', ...
                     'Regime,Breaking,Theory\n']);
        for i = 1:numel(results)
            c = results(i).cond;
            fprintf(fid,['%s,%s,%.4f,%s,%.4f,%s,%.4f,', ...
                         '%.3f,%.3f,%.3f,%.5f,%.5f,%.3f,%.3e,%.3e,', ...
                         '%s,%s,%s\n'], ...
                results(i).label, c.waveType, c.Hinput, c.Hkind, ...
                c.Hplot, c.plotKind, c.Hs, ...
                c.T, c.d, c.L, c.dL, c.HL, c.Ur, c.dgT2, c.HgT2, ...
                c.regime, ternary(c.broken,'YES','no'), c.theory);
        end
        fclose(fid);
        res.Value = {sprintf('Exported %d rows to %s', numel(results), fn)};
    end

    function onClose()
        if isvalid(chartFig)
            close(chartFig);
        end
        delete(f);
    end
end

function lines = formatResult(c, label)
    lines = { ...
        sprintf('Label    : %s', label), ...
        sprintf('Wave     : %s  (input: %s, plot: %s)', ...
                c.waveType, c.Hkind, c.plotKind), ...
        sprintf('Hinput   = %.3f m   Hplot = %.3f m   Hs = %.3f m', ...
                c.Hinput, c.Hplot, c.Hs), ...
        sprintf('T        = %.3f s', c.T), ...
        sprintf('L        = %.3f m', c.L), ...
        sprintf('d/L      = %.4f', c.dL), ...
        sprintf('H/L      = %.4f', c.HL), ...
        sprintf('Ur       = %.2f', c.Ur), ...
        sprintf('Regime   : %s', c.regime), ...
        sprintf('Breaking : %s  (limit H/L = %.3f)', ...
                ternary(c.broken,'YES','no'), c.HLbreak), ...
        '------------------------------', ...
        sprintf('Theory   : %s', c.theory)};
end

function s = ternary(cond,a,b)
    if cond, s = a; else, s = b; end
end

function col = parseMarkerColor(name)
    switch name
        case 'Auto',    col = [];
        case 'Red',     col = [1 0 0];
        case 'Green',   col = [0 0.55 0];
        case 'Blue',    col = [0 0.35 0.8];
        case 'Yellow',  col = [1 1 0];
        case 'Magenta', col = [1 0 1];
        case 'Cyan',    col = [0 1 1];
        case 'Black',   col = [0 0 0];
        case 'White',   col = [1 1 1];
        otherwise,      col = [];
    end
end

function actualColor = getActualColor(cond, userColor)
    if ~isempty(userColor)
        actualColor = userColor;
    elseif cond.broken
        actualColor = [1 0 0];
    elseif strcmp(cond.waveType,'irregular')
        actualColor = [0 .35 .8];
    else
        actualColor = [0 .55 0];
    end
end
