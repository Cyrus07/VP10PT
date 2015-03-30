function [y,H] = add_cd(x,Dz,fc,fs)

N = length(x);

Beta2L = -1* Dz * 299792458 / 2.0 / pi / fc^2;

if Beta2L == 0
    y = x; H = []; return;
end

% transfer function of GVD
freq  = -fs/2 : fs/N : fs/2 * (N-2)/N;
argum = -1 * (2*pi*freq).^2 * Beta2L * 0.5;

H = exp(1j*argum);

H = ifftshift(H.');
H = H * ones(1,size(x,2));

% compensate
y = ifft( fft(x) .* H );