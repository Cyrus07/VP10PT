function h = w_figure(varargin)
%
% Copyright:2011 (dawei.zju@gmail.com)

scrsz = get(0,'ScreenSize');
figsz = [scrsz(3)/4 scrsz(4)/4 scrsz(3)/2 scrsz(4)/1.6];
h = figure('OuterPosition', figsz, varargin{:});