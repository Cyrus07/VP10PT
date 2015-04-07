function Spectrum(obj, am, fs, ttl)

Nfft = 2^nextpow2(length(am));
fam = fftshift(fft(sum(am,2), Nfft)./Nfft);
f = fs *linspace(-0.5,0.5,Nfft);

figure;
plot( f, 10*log10(abs(fam).^2) );
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title(ttl)
% grid on
end