function [meanjtvar, TMAX] = JitterVariance(x, L0, sps, type, RectifyPolyCoff, PolAvg, SCurevePlot, JitterHist)
if nargin<8
    JitterHist = 0;
end
if nargin<7
    SCurevePlot = 0;
end
if nargin<6
    PolAvg = 0;
end
if nargin<5
    RectifyPolyCoff = [];
end
if nargin<4
    type = 'FB1';
end

% ted_Nebojsafb
if strcmp(type, 'FB4')    
    xx = (x+circshift(x,-sps/2)).*conj(circshift(x,-sps/2)+circshift(x,-sps));
    type = 'FB1';
else
    xx = x;
end

numBlock = floor((size(xx,1)-sps)/sps/L0);
xx = RectifyPolyval(xx, RectifyPolyCoff);


szBlock2 = L0*2;
szBlock4 = L0*4;

for id_pol = 1:size(xx,2)
    for id_tp = 1:sps
        xDnSamp2 = xx(id_tp:sps/2:end,id_pol);
        xBlock2 = reshape(xDnSamp2(1:szBlock2*numBlock),szBlock2, []);
        xDnSamp4 = xx(id_tp:sps/4:end,id_pol);
        xBlock4 = reshape(xDnSamp4(1:szBlock4*numBlock),szBlock4, []);
        for id_block = 1:size(xBlock2,2)
            data2 = xBlock2(:,id_block);
            data4 = xBlock4(:,id_block);
            switch type
                %%%%%%%%%%%%%%%%%%%%%%%%%% Feedback 2sps
                case 'FB1'
                    tp(id_tp,id_block,id_pol) = ted_gar(data2);
                case 'FB2'
                    tp(id_tp,id_block,id_pol) = ted_godfb(data2);
                case 'FB3'
                    tp(id_tp,id_block,id_pol) = ted_KTWfb(data2);
                case 'FB5'
                    tp(id_tp,id_block,id_pol) = ted_godfb_half(data2);
                %%%%%%%%%%%%%%%%%%%%%%%%%% Feedfoweard 2sps
                case 'FF2-1'
                    tp(id_tp,id_block,id_pol) = ted_godff(data2);
                case 'FF2-2'
                    px = interpft(data2, 2*length(data2));
                    tp(id_tp,id_block,id_pol) = ted_SLN(px);
                case 'FF2-3'
                    tp(id_tp,id_block,id_pol) = ted_lee(data2,1);
                case 'FF2-4'
                    tp(id_tp,id_block,id_pol,:) = ted_LOGN(data2,2);
                %%%%%%%%%%%%%%%%%%%%%%%%%% Feedfoweard 4sps
                case 'FF4-1'
                    tp(id_tp,id_block,id_pol,:) = ted_AVN(data4);
                case 'FF4-2'
                    tp(id_tp,id_block,id_pol,:) = ted_SLN(data4);
                case 'FF4-3'
                    tp(id_tp,id_block,id_pol,:) = ted_FLN(data4);
                case 'FF4-4'
                    tp(id_tp,id_block,id_pol,:) = ted_LOGN(data4,4);
            end
        end
    end
end
cut = 1;
tp = reshape(tp(:,1+cut:end-cut,:),[],size(xx,2));
%%
if PolAvg
    tppol = mean(tp,2);
else
    tppol = tp;
end
for id_pol = 1:size(tppol,2)
    tp2 = reshape(tppol(:,id_pol),[],1);
    [~, ind] = max(tp2(1:sps,1));
    tp3 = reshape(tp2(ind+sps:end+ind-sps-1), sps, []);
    for id_block = 1:size(tp3,2)
        scurve = tp3(:,id_block);
        for id_tp = 1:sps-1
            if scurve(id_tp)>0 && scurve(id_tp)*scurve(id_tp+1)<0
                tzc(id_block,id_pol) = (id_tp + scurve(id_tp)/(scurve(id_tp)-scurve(id_tp+1)))/sps;
            end
        end
    end
    tmp = tzc(:,id_pol).';
    x_index = 1:length(tmp);
    p = polyfit(x_index,tmp,1);
    r = tmp - polyval(p,x_index);
    jtvar(id_pol) = var(r);
    TEDCMAX(id_pol) = max(mean(tp3,2));
end

meanjtvar = mean(jtvar);
TMAX = mean(TEDCMAX);
%% S Curve
if SCurevePlot
    timingphase = ((-1/2*sps:sps/2-1)+1/2)/sps;
    timingphase = fliplr(timingphase);
    %     FormatedFigure([10,10]);
    [para ,ind] = max(max(tp(1:sps,:),[],2));
    para = 0.5;
    scurve = circshift(tp,1-ind)/para/2;
    figure;
    for id_pol = 1:size(scurve,2)
        sc = reshape(scurve(:,id_pol), sps, []);
        if strfind(type,'FF')
%             for id_tpn = 1:sps/2
%                 sc(id_tpn,:) = sc(id_tpn,:) + (sc(id_tpn,:)<-0.3);
%             end
%             for id_tpn = sps/2+1:sps
%                 sc(id_tpn,:) = sc(id_tpn,:) - (sc(id_tpn,:)>0.3);
%             end
        end
        subplot(1,size(scurve,2),id_pol);
        plot(timingphase,sc);
        xlim([-0.5 0.5]);
        xlabel('timing phase (UI)');
    end
end
%% Jitter Histogram
if JitterHist
    figure;
    for id_pol = 1:size(tzc,2)
        subplot(size(x,2),2,2*id_pol-1)
        hist(tzc(:,id_pol)-mean(tzc(:,id_pol)));
        axis([-0.5 0.5 0 length(tzc(:,id_pol))/3]);
        subplot(size(x,2),2,2*id_pol)
        plot(tzc(:,id_pol).'-mean(tzc(:,id_pol)));
        ylim([-0.1 0.1]);
    end
end
% close all


function y = ted_gar(px)
%GARDNER Gardner timing error detector
%
% The modified version is refered to:
%
% [1] W. Gappmair, S. Cioni, G. E. Corazza, and O. Koudelka, ¡°Symbol-Timing
% Recovery with Modified Gardner Detectors,¡± in International Symposium on
% Wireless Communication Systems, 2005, pp. 831¨C834.
%
px = reshape(px,1,[]);
px1= px(1:2:end-2);
px2= px(2:2:end-1);
px3= px(3:2:end);
y = real(px1-px3)*real(px2).'+imag(px1-px3)*imag(px2).';
y = y/length(px1);

% mu = -0.5;
% y  = mean( (real(px3).* (abs(px3).^ (mu-1))-real(px1).* (abs(px1).^ (mu-1))).*real(px2) + ...
%            (imag(px3).* (abs(px3).^ (mu-1))-imag(px1).* (abs(px1).^ (mu-1))).*imag(px2) );

% px3 = abs(px3).^ mu.* exp(1i*angle(px3));
% px1 = abs(px1).^ mu.* exp(1i*angle(px1));
% y = mean( real((px3-px1).* conj(px2)) );


function y = ted_godff(xx)

yy = fft(xx);
y = -angle(yy(end/2+1:end,1)'*yy(1:end/2,1))/2/pi;
% xc = xcorr(yy);

function y = ted_godfb(x)

X = fft(x)/sqrt(size(x,1));
y = -2*imag(X(end/2+1:end,1)'*X(1:end/2,1))/(size(X,1)/2);
% xc = xcorr(yy);
% fv = linspace(-1,1,length(xc)).';
% plot(fv,20*log10(xc.*xc'.'))
% hold on;
% plot(fv,unwrap(angle(xc))/10,'r');

function y = ted_godfb_half(x)

X = fft(x)/sqrt(size(x,1));
% y = -2*imag(X(end*3/4+1:end,1)'*X(1:end/4,1))/(size(X,1)/4);
y = abs(X(end*3/4+1:end,1)'*X(1:end/4,1));

function y = ted_KTWfb(x)
X = reshape(fft(x)/sqrt(size(x,1)),1,[]);
L = length(x);
k = -L/8:L/8;
i = 0:L/4-1;
for id_k = 1:length(k)
    tmp(id_k)=(X(i+1)*X(mod(L*3/4+k(id_k)+i,L)+1)')*(X(L*3/4+i+1)*X(mod(i+k(id_k),L)+1)')'/length(i);
end
y = imag(mean(tmp));


function y = ted_lee(x,g)
% Yan Wang, "An Alternative Blind Feddforward Symbol Timing Estimator Using
% Two Samples per Symbol," IEEE TRANSACTIONS ON COMMUNICATIONS, VOL. 51,
% NO. 9, SEPTEMBER 2003

if nargin<2
    g = 1.414;
end

L = length(x);

n = 1:L;

% ex1 = exp(-1j.*(ii-1).*pi);
ex1 = (-1).^(n-1);

sum_1 = sum( abs(x).^2 .* ex1.' );

% ex2 = exp(-1j.*(ii-1.5).*pi);
ex2 = 1j * (-1).^(n-1);

xh = x(2:end);
xx = x(1:end-1);
ex2 = ex2(1:end-1);

sum_2 = sum( real(conj(xx).*xh) .* ex2.' );

sum_3 = g*sum_1 + sum_2;

y = angle(sum_3) / 2 / pi;


function y = ted_SLN(px)
%SLN Square-Law Nonlinearity

N = length(px);

k = 1:N;
ex = exp(-1j.*(k-1).*pi./2);

s = sum( abs(px).^2 .* ex.' );

y = -angle(s) / 2 / pi;

function y = ted_AVN(px)
%SLN Abs-Law Nonlinearity

N = length(px);

k = 1:N;
ex = exp(-1j.*(k-1).*pi./2);

s = sum( abs(px) .* ex.' );

y = -angle(s) / 2 / pi;

function y = ted_FLN(px)
%SLN Fourth-Law Nonlinearity

N = length(px);

k = 1:N;
ex = exp(-1j.*(k-1).*pi./2);

s = sum( abs(px).^4 .* ex.' );

y = -angle(s) / 2 / pi;

function y = ted_LOGN(px,N)
%

L = length(px);

k = 1:L;
ex = exp(-1j.*(k-1).*2*pi/N);

s = sum( log(1+20*abs(px).^2) .* ex.' );

y = -angle(s) / 2 / pi;
