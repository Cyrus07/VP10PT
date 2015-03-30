function FormatedFigure(FigSize)

if nargin<1
    FigSize = [6 6];
end

% FontName = 'Times New Roman';
FontName = 'Arial';
FontSize= 8;

figure;
set (gcf, 'Units', 'centimeter');
pos = get (gcf, 'Position');
pos(3) = FigSize(1);
pos(4) = FigSize(2);
set(gcf, 'Position', pos);
set(gcf, 'PaperPositionMode', 'auto');
set(gca, 'Units', 'centimeter');
% set(gca, 'LineStyleOrder', {'-','--','-.',':'});
% set(gca, 'ColorOrder', {'-*',':','o'});

% set(gca,'FontWeight','bold');
set(gca,'FontName',FontName);
set(gca, 'yscale', 'log');
set(findobj('FontSize',10),'FontSize',FontSize);
set(get(gca,'XLabel'),'FontSize',FontSize,'Vertical','top');
set(get(gca,'YLabel'),'FontSize',FontSize,'Vertical','middle');
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'Box', 'on');
grid on;
hold on;
end