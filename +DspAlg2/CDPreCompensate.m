function y = CDPreCompensate(x, CD, CenterFrequency, SampleRate)

N = length(x);
df = SampleRate/N;
w = 2*pi*(-N/2:N/2-1).*df;
w = fftshift(w);
Wavelength = Default.LightSpeed / CenterFrequency;
theta = 1/4/pi/Default.LightSpeed * Wavelength^2 * CD .* (w.^2);
H = exp(1i*(theta+pi/4));

y = ifft(fft(x).*H);
% figure(10); hold on; grid on;
% plot(real(H(1:end/2)));
% plot(imag(H(1:end/2)),'r');
% close;