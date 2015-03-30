function h = w_figure2(varargin)
% Copyright: ?2011 (dawei.zju@gmail.com)
scrsz = get(0,'ScreenSize');
figsz = [0 scrsz(4)/4 scrsz(3) scrsz(4)/2.11];
h = figure('OuterPosition', figsz, varargin{:});