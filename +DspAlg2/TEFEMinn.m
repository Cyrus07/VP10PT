function [y, TimingEstimate, FOE] = TEFEMinn(x, seq, l, m, p, sps, Threshold)
% refer to A Robust Timing amd Frequency Synchronization for OFDM Systems
% Hlaing Minn, Vijay K. Bhargave, Khaled ben Letaief

%% %%%%%%%%%%%%%%%%%%   Timing Estimate
y = sum(x,2);
M = m*sps;
d = 1;
tmp = y(d:d+l*M-1,1);
deltaE = conj(tmp).*tmp;
E(d) = sum(deltaE);
tmp = reshape(tmp, M, l);
deltaP = conj(tmp(:,1:end-1)).*tmp(:,2:end) * (p(1:end-1).*p(2:end)).';
P(d) = sum(deltaP,1);
Lambda2(d) = (l/(l-1)*abs(P(d))/E(d))^2;

while Lambda2(d)<Threshold
    if d > length(y)/2
        plot(Lambda2);
        error('No Signal is Triggered...');
    end
    d = d+1;
    tmp = y(d:d+l*M-1,1);
    deltaE(d+l*M-1,1) = tmp(end)'*tmp(end);
    E(d) = E(d-1) + (deltaE(d+l*M-1,1)-deltaE(d-1,1));
    tmp = reshape(tmp, M, l);
    deltaP(d+M-1) = conj(tmp(end,1:end-1)).*tmp(end,2:end) * (p(1:end-1).*p(2:end)).';
    P(d) = P(d-1) + (deltaP(d+M-1)-deltaP(d-1));
    Lambda2(d) = (l/(l-1)*abs(P(d))/E(d))^2;
end
ind_FrameAcqui = d+1;
for d = ind_FrameAcqui:min(ind_FrameAcqui+M*l*2-1,length(y)-l*M*2+1)
    tmp = y(d:d+l*M-1,1);
    deltaE(d+l*M-1,1) = tmp(end)'*tmp(end);
    E(d) = E(d-1) + (deltaE(d+l*M-1,1)-deltaE(d-1,1));
    tmp = reshape(tmp, M, l);
    deltaP(d+M-1) = conj(tmp(end,1:end-1)).*tmp(end,2:end) * (p(1:end-1).*p(2:end)).';
    P(d) = P(d-1) + (deltaP(d+M-1)-deltaP(d-1));
    Lambda2(d) = (l/(l-1)*abs(P(d))/E(d))^2;
end
% figure;plot(Lambda2);
TimingEstimate = find(Lambda2 == max(Lambda2),1);

%%  %%%%%%%%%%%%%%%%%%   FrequencyOffsetEstimate
if ~isreal(x(1))
% fine FOE
% M. Morelli and U. Mengali, ¡°An improved frequency offset estimator
% for OFDM applications,¡± in 1999 IEEE Communications Theory
% Mini-Conference (Cat. No.99EX352), 1999, pp. 106¨C109.  
% The estimate range of fractional FO is Rs/2/M, independent of l and sps.
% 
H = floor(l/2);
N = M*l;
tmp = y(TimingEstimate : TimingEstimate+M*l-1 ,1);
yf = reshape(reshape(tmp, M, l)*diag(p), l*M, 1);

u = 3 * ((l - [1:H]) .* (l - [1:H] + 1) - H*(l-H))/H/(4*H*H - 6*l*H + 3*l*l -1);
for d = 1:H+1
    Ry(d) = 1/(N - (d-1)*M) * (yf(1:(N-(d-1)*M),1)' * yf((d-1)*M+1:N,1));
end
phi = wrapToPi(mod(angle(Ry(2:H+1)) - angle(Ry(1:H)), 2*pi)) ;
FOE_Fine = sum(u.*phi)/2/pi/M;

% % integer FOE
% % Correlation (between Tx training symbol and Rx fractional FO compensated
% % training symbol) based method.
Seq1 = PNSequence(seq, m);
Seq2 = PNSequence(seq, m*2);
Seq2 = Seq2(1:2:end);
xp1 = fft(Seq1);
xp2 = fft(Seq2);
TxDiffModuInfo = xp2./xp1;

tmp = y(TimingEstimate+M*(l-1) : TimingEstimate+M*(l+1)-1 ,1);
tmp2 = tmp.*exp(-1i*2*pi*FOE_Fine*(1:size(tmp,1)).');

yp1 = fft(tmp2(1:sps:end/2,1));
yp2 = fft(tmp2(end/2+1:sps:end,1));

% for g = 1:m
%     numerator1 = (circshift(yp1,1-g).*TxDiffModuInfo)'*circshift(yp2,1-g);
%     denominator1 = yp2'*yp2;
%     B(g) = numerator1'*numerator1/2/denominator1.^2;
% end

RxDiff = yp2.*conj(yp1);
TxDiff = conj([TxDiffModuInfo(1);flipud(TxDiffModuInfo(2:end))]);
B = ifft(fft(RxDiff).*fft(TxDiff));
[~, ind_f] = max(B);
ind_f = ind_f - 1;
if ind_f > m/2
    ind_f = ind_f - m;
end
FOE_Int = ind_f/m/sps;

FOE = FOE_Fine + FOE_Int;
else
FOE = 0;
end
%%
%   Freq Compensation
y = x.*exp(-1i*2*pi*FOE*(1:size(x,1)).'*ones(1,size(x,2)));
% figure;pwelch(y)

end