function [y, TE, FOE] = TEFESCA(x, seq, sps, NumFFT, NumGI, th)
% refer to Robust Frequency amd Timing Synchronization for OFDM
% Timothy M.Schmidl and Donald C.Cox

y = sum(x,2);
Seq1 = PNSequence(seq, NumFFT/2 ,1);
Seq2 = PNSequence(seq, NumFFT);
TxDiffModuInfo = Seq2(1:2:end)./Seq1;
L = NumFFT*sps/2;
GI = NumGI*sps;

% PFAperSymbol = 1e-10;
% PFAperSample = PFAperSymbol/L;
% th = -reallog(PFAperSample)/L;   % (33) in paper

%% %%%%%%%%%%%%%%%%%%   Timing Estimate
P(1) = y(1:L,1)' * y(1+L:2*L,1);
R(1) = y(1+L:2*L,1)' * y(1+L:2*L,1);
M(1) = P(1)*conj(P(1))/R(1)^2;
d = 1;
while M(d)<th
    if d > length(y)/3
        plot(M);
        error('No Signal is Triggered...');
    end
    P(d+1) = P(d) + conj(y(d+L))*y(d+2*L) - conj(y(d))*y(d+L);
    R(d+1) = R(d) + conj(y(d+2*L))*y(d+2*L) - conj(y(d+L))*y(d+L);
    M(d+1) = P(d+1)*conj(P(d+1))/R(d+1)^2;
    d = d+1;
end
    
for i = d:d+10*L
    P(i+1) = P(i) + conj(y(i+L))*y(i+2*L) - conj(y(i))*y(i+L);
    R(i+1) = R(i) + conj(y(i+2*L))*y(i+2*L) - conj(y(i+L))*y(i+L);
    M(i+1) = P(i+1)*conj(P(i+1))/R(i+1)^2;
end
figure;plot(M);
close;
TE = round(mean(find(M >= max(M)*0.95)));
%%  %%%%%%%%%%%%%%%%%%   FrequencyOffsetEstimate
PhiHat = angle(P(TE));
FOE_Fine = PhiHat/pi/2/L;

% Synchronization
x = x.*exp(-1i*2*pi*FOE_Fine*(1:size(x,1)).'*ones(1,size(x,2)));
y = sum(x(TE+1:end,:),2);

x1k = fft(y(1:sps:L*2,1));
x2k = fft(y(L*2+GI+1:sps:2*L*2+GI,1));
L = L/sps;
for g = 1:L
    numerator1 = (circshift(x1k(1:2:end,1),1-g).*TxDiffModuInfo)'*circshift(x2k(1:2:end,1),1-g);
    denominator1 = x2k'*x2k;
    B(g) = numerator1'*numerator1/2/denominator1.^2;
end
FOE_Int = (find(max(B)==B,1)-1)*2;
if FOE_Int > L
    FOE_Int = FOE_Int - 2*L;
end
FOE_Int = FOE_Int/L/2/sps;

FOE = FOE_Fine + FOE_Int;
%% Synchronization
y = x.*exp(-1i*2*pi*FOE_Int*(1:size(x,1)).'*ones(1,size(x,2)));
% pwelch(y)
y = y(1:end,:);
end