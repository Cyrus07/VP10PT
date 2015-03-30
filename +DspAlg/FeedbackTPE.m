function [y,tau,err] = FeedbackTPE(signal, mn, sps, szBlock, delta,...
    estMeth, intMeth, SOPMethod, decFlag, norFlag, RectifyPolyCoff)
%TIMINGRECOVERY Summary of this function goes here
%   mn: modulation order
%   mu: step size
%   estMeth: estimator method
%   intMeth: interpolation method
%
%   Example
%   
%   See also FeedforwardTPE

%   Copyright2010 WANGDAWEI 16/3/2010
if nargin<11
    RectifyPolyCoff = [];
end
if nargin<10
    norFlag = 1;
end
if nargin<9
    decFlag = 1;
end
if nargin<8
    SOPMethod = '';
end
if nargin<7
    intMeth = 'linear';
end
if nargin<6
    estMeth = 'gardner';
end

% normalize the input or not
if norFlag
    x = DspAlg.Normalize( signal, mn)/(sqrt(mn)-1);
else
    x = signal;
end

% get the size of input
mm = size(x,1);
kk = size(x,2);

% make sure that the length of x can be diveded by sps
temp = mod(mm, sps);
if temp
    x = [x;zeros(sps-temp,kk)];
end
        
% SOP tracking initial estimate
switch lower(SOPMethod)
    case 'nebojsa'
        BlkSz = min(2^10,size(x,1));
        SOP = [0 0];
        mu = 0.2/180*pi;
        for iter = 1:1000
            [~, SOP(iter+1,:), Kd(iter)] = Nebojsa(x(1:BlkSz,:),BlkSz,SOP(iter,:),mu);
        end
        J = [cos(SOP(end,1))*exp(-1i*SOP(end,2)/2) -sin(SOP(end,1))*exp(1i*SOP(end,2)/2);...
            sin(SOP(end,1))*exp(-1i*SOP(end,2)/2) +cos(SOP(end,1))*exp(1i*SOP(end,2)/2)];
        x = (J*x.').';
%         plot(SOP(:,1),SOP(:,2));
    otherwise
        
end

% DGD estimate
% BlkSz = min(2^12,size(x,1));
% DGDest = -1/2/pi*angle(ted_GodardFF(x(1:BlkSz,1)))+1/2/pi*angle(ted_GodardFF(x(1:BlkSz,2)));

% chose the estimator
switch lower(estMeth)
    case 'none'
        y       = x(1:sps:end,:);
        tau     = zeros(1,kk);
        err     = zeros(1,kk);
    case {'gardner', 'godard'}       
        [y,tau,err] = PLLDP(x,sps,szBlock,delta,intMeth,estMeth,SOPMethod,RectifyPolyCoff);
end

if decFlag
    y = y(1:sps:end,:);
end

function [y,tau,err] = PLLDP(x,sps,BlkSz,delta,method,TED,SOPMethod, p)
%
for pol = 1:size(x,2)
N = length(x(:,pol));
% X = fft(x(:,pol));
% Z = xcorr(X);

X = fft(x(:,pol))/sqrt(size(x,1));
s(pol) = X(end-end/sps+1:end,1)'*X(1:end/sps,1)/(N/sps);

end
Initial = -1/2/pi*angle(mean(s));

% Block number delay, a integer larger than 1
BlkDelay = 1;
% [sym], a multiple of floor(TEDsize/sps)
LoopDelay = BlkDelay*floor(BlkSz/sps);

% the interpolate coff. for floor(TEDsize/sps) symbols
nu      = Initial*sps*ones(BlkDelay,size(x,2));
% TPE, the first LoopDelay symbols are set to initial value.
tau  	= Initial*ones(BlkDelay,size(x,2));
% TED output, the the first LoopDelay symbols are set to zero.
err   	= 0*ones(BlkDelay,size(x,2));
SOP     = 0*ones(BlkDelay,size(x,2));
mu      = 0.1/180*pi;

% pointer to current processing sample
m       = sps*LoopDelay+1*ones(1,size(x,2));
% pointer to current processing block
k       = BlkDelay+1;

% the first LoopDelay symbols are not interpolated.
y       = x(1:LoopDelay*sps,:);
x       = [x; zeros(sps,size(x,2))];

while max(m)+BlkSz+sps-2<=size(x,1)
    
    % ================= Interpolation =================== %
    % interpolate the current block according to the former estimated TPE.
    
%     InterpInd = 0:sps-1;
%     for n = 0:BlkSz-1
%             interpolantee = x(m(pol) + n + InterpInd,pol).';
%             y(BlkSz*(k-1)+1+n,pol) = interpolate(interpolantee,nu(k-BlkDelay,pol),method);
%         end
    
    n = 0:BlkSz-1;
    InterpInd = 0:sps-1;
    for pol = 1:size(x,2)
        for id_Interp = 1:length(InterpInd)
            interpolantee(:,id_Interp) = x(m(pol) + n + InterpInd(id_Interp),pol);
        end
        y(BlkSz*(k-1)+1+n,pol) = interpolate(interpolantee,nu(k-BlkDelay,pol),method);
    end

    % ================= SOP tracking =================== %
    px = y(BlkSz*(k-1)+1:BlkSz*k,:);
    switch lower(SOPMethod)
        case 'nebojsa'
            [px, SOP(k,:), Kd(k)] = Nebojsa(px,BlkSz,SOP(k-1,:),mu);
        case 'sunhan'
        case 'lingchen'
            [px, SOP(k,:), Kd(k)] = Lingchen(Px,BlkSz,SOP(k-1,:),mu);
        otherwise
    end

    % ================= TED =================== %
    switch lower(TED)
        case 'gardner'
            for pol = 1:size(x,2)
                px(:,pol) = RectifyPolyval(px(:,pol), p);
                err(k,pol) = ted_Gardner(px(2:end,pol));
            end
        case 'godard'
            for pol = 1:size(x,2)
                px(:,pol) = RectifyPolyval(px(:,pol), p);
                err(k,pol) = ted_Godard(px(:,pol),sps);
            end
        case 'gardnermodify'
            % Modified timing error detector
%             err(k) = ted_ModifiedGardner(y(m-2:m,:));
    end
    % ================= Loop Filter =================== %
    for pol = 1:size(x,2)
        tau(k+1-BlkDelay,pol) = tau(k-BlkDelay,pol) + loopfilter(err(k-BlkDelay:k,pol), delta);
        % wrap timing phase
        if tau(k+1-BlkDelay,pol) > 1/2
            tau(k+1-BlkDelay,pol) = tau(k+1-BlkDelay,pol) -1;
        end
    end
    % ================= Control =================== %
    for pol = 1:size(x,2)
        [m(pol), nu(k+1-BlkDelay,pol), tau(k+1-BlkDelay,pol)] = control(tau(k-BlkDelay,pol), tau(k+1-BlkDelay,pol), m(pol), sps);
        m(pol) = m(pol)+BlkSz;
    end
    k = k+1;
end
% pause(0.01);
% figure(1);hold on;
% % plot(err);
% plot(tau,'r');
% % plot(nu,'k');
% figure(2);hold on;
% plot(Kd)
% figure(3);hold on;
% plot(SOP/pi*180)
% close all;


function y = interpolate(x,nu,method)
%INTERP Interpolate signal samples
%
sps = size(x,2);
if strcmpi(method,'linear') && sps == 2
    y = x(:,1) + nu*(x(:,2)-x(:,1));
elseif strcmpi(method,'cubic') && sps == 4
    b = [0 1 0 0;...
        -1/3 -1/2 1 -1/6;...
        1/2 -1 1/2 0;...
        -1/6 1/2 -1/2 1/6]; % b(i,l)
    v = x*b.';
    y = ((v(:,4)*nu+v(:,3))*nu+v(:,2))*nu+v(:,1); 
elseif strcmpi(method,'parabolic') && sps == 4
    a = 0.5;
    b = [0 1 0 0;...
        -a a-1 a+1 -a;...
        a -a -a a]; % b(i,l)
    v = x*b.';
    y = (v(:,3)*nu+v(:,2))*nu+v(:,1); 
end

function y = loopfilter(x, delta)
y = x(1)*delta;

function [m,nu,tau2] = control(tau1, tau2, m, sps)
if floor((0.5-tau2)*sps)
    
    if tau1-tau2>0.75
        m = m+1;    % skip one sample
        tau2 = tau2+(sps-1)/sps;
        nu = tau2*sps;
    elseif tau1-tau2<=0.25
        m = m-1;     % wait for one sample
        tau2 = tau2+1/sps;
        nu = tau2*sps;
    elseif tau1-tau2<=0.75 && tau1-tau2>0.5
        m = m+2;     % skip 2 sample
        tau2 = tau2+(sps-2)/sps;
        nu = tau2*sps;
    elseif tau1-tau2<=0.5 && tau1-tau2>0.25
        m = m-2;     % wait for 2 sample
        tau2 = tau2+2/sps;
        nu = tau2*sps;
    end

else
    nu = tau2*sps;
end
nu = mod(nu,sps/2);

function err = ted_Gardner(x)
px = reshape(x,1,[]);
px1= px(1:2:end-2);
px2= px(2:2:end-1);
px3= px(3:2:end);
err = real(px3-px1)*real(px2).'+imag(px3-px1)*imag(px2).';
err = err/length(px1);

function err = ted_ModifiedGardner(x)
% The modified version is refered to:
% [1] W. Gappmair, S. Cioni, G. E. Corazza, and O. Koudelka, "Symbol-Timing
% Recovery with Modified Gardner Detectors," in International Symposium on
% Wireless Communication Systems, 2005, pp. 831-834.
%
% When mu = 1, the ted reduce to the normal gardner ted.
mu = 1;
eK = real((abs(x(1,:)).^ mu.* exp(1i*angle(x(1,:)))-abs(x(3,:)).^ mu.* exp(1i*angle(x(3,:))))...
    .* conj(x(2,:)) );
err = mean(eK);

function err= ted_Godard(x,sps)
X = fft(x)/sqrt(size(x,1));
XX = X(end-end/sps+1:end)'*X(1:end/sps,1);
err = -1*imag(XX)/(size(X,1)/sps);

function s = ted_GodardFF(px)
N = length(px);
X = fft(px);
Z = xcorr(X);
s = Z(N/2);

function [y, paraout, Kd] = Nebojsa(x,bs,parain,mu)
X = fft(x(:,1))/sqrt(size(x,1));
Y = fft(x(:,2))/sqrt(size(x,1));
stepsz = [1 1;1 -1;-1 1;-1 -1]*mu;
para = [parain(1)+stepsz(:,1) parain(2)+stepsz(:,2)];
for n = 1:size(para,1)
    Z1 = X*cos(para(n,1))*exp(-1i*para(n,2)/2)-Y*sin(para(n,1))*exp(1i*para(n,2)/2);
    Z2 = Z1;
    % Kd candidates
    KdCdd(n) = real(Z1(1:bs/2).'*Z2(bs/2+1:bs)'.');
end
[Kd,ind] = max(KdCdd);
paraout = para(ind,:);

J = [cos(paraout(1))*exp(-1i*paraout(2)/2) -sin(paraout(1))*exp(1i*paraout(2)/2);...
     sin(paraout(1))*exp(-1i*paraout(2)/2) +cos(paraout(1))*exp(1i*paraout(2)/2)];
y = (J*x.').';

function [y, paraout, Kd] = Lingchen(x,bs,parain,mu)
X = fft(x(:,1))/sqrt(size(x,1));
Y = fft(x(:,2))/sqrt(size(x,1));
% stepsz = [1 1;1 -1;-1 1;-1 -1]*mu;
stepsz = [1 0;-1 0]*mu;
para = [parain(1)+stepsz(:,1) parain(2)+stepsz(:,2)];
for n = 1:size(para,1)
    Z1 = +X*cos(para(n,1))*exp(+1i*para(n,2)/2)+Y*sin(para(n,1))*exp(+1i*para(n,2)/2);
    Z2 = -X*sin(para(n,1))*exp(-1i*para(n,2)/2)+Y*cos(para(n,1))*exp(-1i*para(n,2)/2);
    % Kd candidates
    KdCdd(n) = abs(Z1(1:bs/2).'*Z1(bs/2+1:bs)'.')+abs(Z2(1:bs/2).'*Z2(bs/2+1:bs)'.');
end
[Kd,ind] = max(KdCdd);
paraout = para(ind,:);

J = [+cos(paraout(1))*exp(+1i*paraout(2)/2) +sin(paraout(1))*exp(+1i*paraout(2)/2);...
     -sin(paraout(1))*exp(-1i*paraout(2)/2) +cos(paraout(1))*exp(-1i*paraout(2)/2)];
y = (J*x.').';