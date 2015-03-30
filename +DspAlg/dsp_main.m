
Ix = [];
Qx = [];
Iy = [];
Qy = [];

SPS_IN = 2;
POL = 2;
SYM_RATE = 28e9;
SAMPLE_RATE = SPS_IN*SYM_RATE;

%======================================================%
Ix = Ix - mean(Ix);
Qx = Qx - mean(Qx);
Iy = Iy - mean(Iy);
Qy = Qy - mean(Qy);
Ix = Ix / sqrt(mean(Ix.^2));
Qx = Qx / sqrt(mean(Qx.^2));
Iy = Iy / sqrt(mean(Iy.^2));
Qy = Qy / sqrt(mean(Qy.^2));
Ix(isnan(Ix)) = 0;
Ix(isnan(Ix)) = 0;
Ix(isnan(Ix)) = 0;
Ix(isnan(Ix)) = 0;
%======================================================%

%======================================================%
LPF_BW = 0.75*SYM_RATE
[b a] = besself(5,2*pi*LPF_BW/0.6166758);
[bz az] = impinvar(b,a,SAMPLE_RATE);
Ix = filter(bz,az,Ix);
Qx = filter(bz,az,Qx);
Iy = filter(bz,az,Iy);
Qy = filter(bz,az,Qy);
%======================================================%

%======================================================%
REAL_DATA = [Ix,Qx,Iy,Qy];
SPS = 2;
[up down] = rat(SYM_RATE*SPS/SAMPLE_RATE);
if up == down
    RSP_TMP = REAL_DATA;
elseif up == 1
    RSP_TMP = REAL_DATA(1:down:end,:);
else
    RSP_TMP = resample(REAL_DATA,up,down);
end
X_DATA = complex(RSP_TMP(:,1),RSP_TMP(:,2));
Y_DATA = complex(RSP_TMP(:,3),RSP_TMP(:,4));
DSP_IN = [X_DATA,Y_DATA];
%======================================================%

%======================================================%
r1 = real(DSP_IN);
r2 = imag(DSP_IN);
sin2theta = mean(r1.*r2)./mean(r1.^2);
sin2theta = mean(sin2theta);
r4 = (r2 - r1 * sin2theta) / sqrt(1-sin2theta^2);
DSP_IN = complex(r1,r4);
%======================================================%

%======================================================%
x = DSP_IN;
y = [];
method = 'ideal';
paramGVD = 16;
FiberLength = 10;
D2L = paramGVD * FiberLength * 1e-3;
Fs = SYM_RATE * SPS;
Fc = 193.1e12;
% Fc = 299792458/1550e-9;
N = size(DSP_IN,1);
Beta2L = -D2L * 299792458 / 2.0 / pi / Fc^2;
ntaps = 512;
overlap = 0.5;

if strcmpi(method,'overlap')
    if ntaps > N
        ntaps = N;
    end
    overlap = round(ntaps * overlap);
    precursor = 0.5 * overlap;
    freq = linspace(-Fs/2,Fs/2,ntaps);
    H = exp(1j * (2*pi*freq).^2 * Beta2L * 0.5);
    H = fftshift(H(:)) * ones(1,POL);
    for ii = 1 : (ntaps-overlap) : (N-ntaps+1)
        idx = ii : (ii+ntaps-1);
        z = ifft( fft(x(idx,:)) .* H );
        if ii == 1
            z = z(2:(end-precursor),:);
        elseif ii == N-ntaps+1
            z = z((precursor+1):end,:);
        else
            z = z((precursor+1):(end-precursor),:);
        end
        y = [y;z];
    end
elseif strcmpi(method,'ideal')
    freq = (-Fs/2 : Fs/N : Fs/2 * (N-2)/N);
    H = exp(1j * (2*pi*freq).^2 * Beta2L * 0.5);
    H = fftshift(H(:)) * ones(1,POL);
    y = ifft( fft(x) .* H );
end
%======================================================%

%======================================================%
x = y;

bs = 128;
IX = real(x(:,1));
QX = imag(x(:,1));
IY = real(x(:,2));
QY = imag(x(:,2));

SymbolPeriod = 1/SYM_RATE;

Time2sps = (0: 1: length(IX)-1) * SymbolPeriod/2;
Time4sps = (0:1:2*length(IX)-1) * SymbolPeriod/4;

% InterpTechniqueDSF = 'interp1';
InterpTechniqueDSF = 'interpft';

% interpolation to get 4 samples per symbol using interp1
if strcmp(InterpTechniqueDSF, 'interp1')
    % method = 'nearest';
    % method = 'linear';
    % method = 'spline';
    % method = 'pchip';
    method = 'cubic';
    IX_4sps = interp1(Time2sps, IX, Time4sps, method);
    QX_4sps = interp1(Time2sps, QX, Time4sps, method);
    IY_4sps = interp1(Time2sps, IY, Time4sps, method);
    QY_4sps = interp1(Time2sps, QY, Time4sps, method);
end

% interpolation to get 4 samples symbol bit using interpft
if strcmp(InterpTechniqueDSF, 'interpft')
    IX_4sps = interpft(IX, 2*length(IX));
    QX_4sps = interpft(QX, 2*length(QX));
    IY_4sps = interpft(IY, 2*length(IY));
    QY_4sps = interpft(QY, 2*length(QY));
end

NumBlk_str = fix(length(IX_4sps) / bs);

Xseq = abs(IX_4sps + 1i*QX_4sps).^2;
Yseq = abs(IY_4sps + 1i*QY_4sps).^2;

sumX = zeros(1, NumBlk_str);
sumY = zeros(1, NumBlk_str);

for k = 1 : NumBlk_str
    sum1 = 0;
    sum2 = 0;
    for m = 0 : bs-1
        sum1 = sum1 + Xseq((k-1)*bs + m+1) * exp(-1i*2*pi*m/4);
        sum2 = sum2 + Yseq((k-1)*bs + m+1) * exp(-1i*2*pi*m/4);
    end
    sumX(k) = sum1;
    sumY(k) = sum2;
end

% smooth signal
NavgDSF = 256;
filt_sumX = filter(ones(1,NavgDSF)/NavgDSF, 1, sumX);
filt_sumY = filter(ones(1,NavgDSF)/NavgDSF, 1, sumY);

tauX_seq = -1/2/pi * unwrap(angle(filt_sumX));
tauY_seq = -1/2/pi * unwrap(angle(filt_sumY));

% determine single values of delays
rX = sum(exp(1i*2*pi*tauX_seq));
rY = sum(exp(1i*2*pi*tauY_seq));

tauX_s = SymbolPeriod/2/pi * atan2(imag(rX), real(rX));
tauY_s = SymbolPeriod/2/pi * atan2(imag(rY), real(rY));

tauX_m = SymbolPeriod * mean(tauX_seq);
tauY_m = SymbolPeriod * mean(tauY_seq);

tauX = tauX_s;
tauY = tauY_s;

% interpolate sampling based on estimated delays
TimeX_after = Time4sps + tauX;
TimeY_after = Time4sps + tauY;

method = 'cubic';
IX_4spsRT = interp1(Time4sps, IX_4sps, TimeX_after, method);
QX_4spsRT = interp1(Time4sps, QX_4sps, TimeX_after, method);
IY_4spsRT = interp1(Time4sps, IY_4sps, TimeY_after, method);
QY_4spsRT = interp1(Time4sps, QY_4sps, TimeY_after, method);


I_X = downsample(IX_4spsRT, 2, 0);
Q_X = downsample(QX_4spsRT, 2, 0);
I_Y = downsample(IY_4spsRT, 2, 0);
Q_Y = downsample(QY_4spsRT, 2, 0);

% after timing recovery
signal_x_tim = I_X + 1i * Q_X;
signal_y_tim = I_Y + 1i * Q_Y;
y = [signal_x_tim(:),signal_y_tim(:)];
%======================================================%

%======================================================%
x = y;
mu = 1e-5;
ntaps = 13;
errid = 1;
iter = 30;
stage = 2;
x = DspAlg.Normalize(x, mn);

if mn == 16
    x = x / 3;
end
if mn == 64
    x = x / 7;
end

% make sure the tap number is odd
ntaps = ntaps + ~mod(ntaps,2);

% taps initialization
halfnt = floor(ntaps/2);
h1 = zeros(ntaps,2);
h2 = zeros(ntaps,2);
h1(halfnt+1,:) = [1 0];
h2(halfnt+1,:) = [0 1];

method = 0;
c = DspAlg.constellation(mn);
extendx = [ x(end-halfnt+1:end,:); x ; x(1:halfnt,:) ];

if errid == 0
    for ii = 1:iter
        [xx mse deth] = LMS_FILTER(extendx,h1,h2,ntaps,mu,c,SPS);
    end
elseif errid==1 || errid==7
    r = mean(abs(c).^4) / mean(abs(c).^2);
    for ii = 1:iter
        [xx mse deth] = CMA_FILTER(extendx,h1,h2,ntaps,mu,r,SPS,errid,stage,method);
    end
elseif errid==2
    r = mean(real(c).^4) / mean(real(c).^2);
    for ii = 1:iter
        [xx mse deth] = CMA_FILTER(extendx,h1,h2,ntaps,mu,r,SPS,errid,stage,method);
    end
elseif errid==3
    r = [sqrt(1+1);sqrt(1+9);sqrt(9+9)]/3;
    for ii = 1:iter
        [xx mse deth] = CMA_FILTER(extendx,h1,h2,ntaps,mu,r,SPS,errid,stage,method);
    end
end

% format the output
y = xx(1:SPS:end,:);
%======================================================%

%======================================================%
x = y;

M = 32;
bs = 128;
F1 = 300e6
F2 = 20e6
test_phas = (0:M-1)/M*pi/2;

corse_step = 10e6;
fine_step = 1e6;

x = DspAlg.Normalize(x,mn);
y = zeros(size(x));

tic
for pol = 1:size(x,2)
    xp = reshape(x(:,pol),bs,[]);
    
    corse_freq = -F1:corse_step:F1;
    corse_freq_phas = corse_freq*2*pi/symrate;
    for b = 1:size(xp,2)
        data_mat = repmat(xp(:,b),1,M);
        phas_mat = exp(1j*repmat(test_phas,bs,1));
        idx_vec = (1:bs);% + (b-1)*bs;
        for k = 1:length(corse_freq)
            phi_vec = corse_freq_phas(k) * idx_vec;
            freq_mat = exp(1j * repmat(phi_vec(:),1,M));
            xp_tmp = data_mat.* phas_mat.* freq_mat;
            xd = slicer(xp_tmp,mn);
            dist_phi = mean(abs(xp_tmp-xd).^2);
            [dist_corse(k) idx_phi(k)] = min(dist_phi);
        end
        [~,idx_freq] = min(dist_corse);
        rot_phas_c(b) = test_phas(idx_phi(idx_freq));
        rot_freq_c(b) = corse_freq(idx_freq);
    end
    
    corse_freq_est = mean(rot_freq_c);

    fine_freq = corse_freq_est + (-F2:fine_step:F2);
    fine_freq_phas = fine_freq*2*pi/symrate;
    for b = 1:size(xp,2)
        data_mat = repmat(xp(:,b),1,M);
        phas_mat = exp(1j*repmat(test_phas,bs,1));
        idx_vec = (1:bs) + (b-1)*bs;
        for k = 1:length(fine_freq)
            phi_vec = fine_freq_phas(k) * idx_vec;
            freq_mat = exp(1j * repmat(phi_vec(:),1,M));
            xp_tmp = data_mat.* phas_mat.* freq_mat;
            xd = slicer(xp_tmp,mn);
            dist_phi = mean(abs(xp_tmp-xd).^2);
            [dist_fine(k) idx_phi(k)] = min(dist_phi);
        end
        [~,idx_freq] = min(dist_fine);
        rot_phas(b) = test_phas(idx_phi(idx_freq));
        rot_freq(b) = fine_freq(idx_freq);
        tmp(:,b) = rot_freq(b) * idx_vec.'*2*pi/symrate;
    end
    pn = ones(bs,1) * unwrap(rot_phas*4)/4;
    df = ones(bs,1) * rot_freq;
    y(:,pol) = xp(:).* exp(1j*pn(:)).* exp(1j*unwrap(4*tmp(:))/4);
end
toc