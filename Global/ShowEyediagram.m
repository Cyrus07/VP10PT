function ShowEyediagram( Ix, Qx, Rs, Fs )
%SHOWEYEDIAGRAM Summary of this function goes here
%   Detailed explanation goes here

if length(Ix) <= 1000
    N = length(Ix);
else
    N = 1000;
end

sps = Fs/Rs;

upfactor = round(120/sps);

% 2nd order filter, more flat than default 10 order
ixd = resample(Ix(1:N),upfactor,1,2);
qxd = resample(Qx(1:N),upfactor,1,2);
% 2nd order filter, more flat than default 10 order

idata = ixd + 1j*qxd;
h = commscope.eyediagram('SamplingFrequency', Fs, ...
    'SamplesPerSymbol', sps * upfactor, ...
    'MinimumAmplitude', 0, ...
    'MaximumAmplitude', 1, ...
    'PlotType', '2D Color', ...
    'ColorScale', 'log', ...
    'RefreshPlot', 'on');

a = (abs(idata)./max(abs(idata))).^2;
update(h, a)

M = 5;
totalM = M*sps*upfactor;
figure
x = (0:totalM-1)/(sps*upfactor);
plot(x,ixd(1:totalM))
hold on
x = (0:upfactor:upfactor*(M*sps-1))/(sps*upfactor);
plot(x,Ix(1:M*sps),'o')
grid on