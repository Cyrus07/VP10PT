function [y Phi] = PhaseEstimatorTimeDomain(x, fs, bw, flen)
%[1] S. Randel, S. Adhikari, and S. L. Jansen, ¡°Analysis of RF-Pilot-Based
%Phase Noise Compensation for Coherent Optical OFDM Systems,¡± IEEE
%Photonics Technology Letters, vol. 22, no. 17, pp. 1288¨C1290, Sep. 2010.
%[2] Wikipedia Gaussian filter

%% frequency domain filter
fc = bw;
df = fs/length(x);
f = df*(-1/2*length(x):1/2*length(x)-1);
f = fftshift(f);
Hf = myfilter('ideal',f,fc);
Carr_hat = ifft(fft(x).*Hf);
%% time domain filter
% sqrt(2*log(sqrt(2))) = 0.8326, power 3-dB bandwidth, otherwise sqrt(2*log(2)) =  1.1774  
% delta = 0.8326/2/pi/bw; 
% % Gauss-shaped time-domain filter taps
% FilterLength = flen;
% dt = 1/fs;
% t = dt * (-FilterLength : FilterLength).';
% H = exp(-1*(t/delta).^2/2);


%% apply phase reverse separetively
% tmp = sum(x,2);
% tmp = conv(H, tmp);
% tmp = tmp(FilterLength+1 : end-FilterLength, 1);
% Carr_hat = tmp./abs(tmp);
% Carr_hat = Carr_hat * ones(1,Default.PolarDiversity);
% for n = 1: Default.PolarDiversity
%     tmp = x(:,n);
%     tmp = conv(H, tmp);
%     tmp = tmp(FilterLength+1 : end-FilterLength, 1);
%     Carr_hat(:,n) = tmp./abs(tmp);
% end
y = conj(Carr_hat).* x;
% %% apply phase reverse in combination
% Carrier_hat = mean(Carrier_hat,1);
% EleField = ones(NumDiversity,1)*conj(Carrier_hat).* EleField;
%%
% Phi = angle(y);
Phi = unwrap(angle(Carr_hat),[],1);
y = y - ones(size(y,1),1) * mean(y,1);
end