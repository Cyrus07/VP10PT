function ydisp = OpticalPowerMeter( x, type)
%OpticalPowerMeter Optical power meter
%   Define,
%   Ps: the power of one sample
%   Ts: the duration of one sample
%   P = E[Ps*Ts]/Ts = E[Ps] = E[abs(a)^2]

if nargin<2
    type = 'dBm';
end

a = x.E;
y = mean(sum(abs(a).^2,2));

switch lower(type)
    case 'dbm'
        ydisp = 10 * log10(1000*y);
%         fprintf('%.4f%s\n', ydisp, ' dBm');
    case 'mw'
        ydisp = 1000*y;
%         fprintf('%.4f%s\n', ydisp, ' mw');
    case 'w'
        ydisp = y;
%         fprintf('%.4f%s\n', ydisp, ' w');
end