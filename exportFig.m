function exportFig(fig, filepath, res)
%EXPORTFIG 导出图形（默认 png+svg 1200dpi）
%   exportFig(fig, 'output/fig1')            % 默认 png+svg
%   exportFig(fig, 'output/fig1', 600)       % 指定分辨率
%
%   自动创建目录，导出后关闭图形。

    if nargin < 3, res = 1200; end

    [folder, ~, ~] = fileparts(filepath);
    if ~isempty(folder) && ~exist(folder, 'dir')
        mkdir(folder);
    end

    resStr = ['-r' num2str(res)];
    print(fig, filepath, '-dpng', resStr);
    print(fig, filepath, '-dsvg', resStr);
end
