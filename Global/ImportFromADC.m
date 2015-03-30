function rx = ImportFromADC(Rs, SampPerSym)

DSA.InBuffersize = 20e6;    % Default setting
DSA.OutBuffersize = 20e6;   % Default setting
DSA.Timeout = 20;           % Default setting
DSA.IPaddress = '192.168.74.93';
DSA.ChannelNo = [1 2 3 4]; % put the channel no. you want to record here. [1,2,3,4] represent to record all channels.

DSA.SampleRate = 50e9;
DSA.ResetState = 0;
scale = 10e-3;
DSA.Vertical = ones(size(DSA.ChannelNo))*scale; % scope vertical scale.
DSA.DeSkew = [0 0 0 0];
DSA.Points = 5e6; % scope record length.
DSA.BandWidth =33*1e9;

DSA.data = scope(DSA);
rf2 = normalize(DSA.data);

% complex
if size(rf2,1)==1
    rf = rf2;
elseif size(rf2,1)==2
    rf(:,1) = rf2(1,:) + 1i * rf2(2,:);
elseif size(rf2,1)==4
    rf(:,1) = rf2(1,:) + 1i * rf2(2,:);
    rf(:,2) = rf2(3,:) + 1i * rf2(4,:);
end

bw = 0.6 * Rs;
Fs = DSA.SampleRate;
Nsamp = size(rf,1);
f = (-Nsamp/2 : Nsamp/2-1)/Nsamp*Fs;
Hf = ifftshift(myfilter('supergauss',f,bw,2));
% Hf = ifftshift(myfilter('bessel5',f,bw));
% Hf = ifftshift(myfilter('ideal',f,bw));
rf = ifft( ( Hf * ones(1,size(rf,2)) ) .* fft(rf));

% Resample
if nargin<2 SampPerSym = []; end
if ~isempty(SampPerSym)
    num = Rs * SampPerSym;
    den = DSA.SampleRate;
    [num2, den2] = numden(sym(num/den));
    for n = 1:size(rf,2)
        rx(:,n) = resample(rf(:,n), double(num2), double(den2));
    end
end

function y = normalize(x)
sz = size(x,1);
% figure(999);
% for n = 1:sz
% subplot(sz,1,n);plot(x(n,:));
% ylim([-0.05 0.05])
% end
% close;
for n = 1:size(x,1)
    % DC block
    y(n,:) = x(n,:) - mean(x(n,:));
    % power control
    powy(n) = sum(y(n,:).^2);
    y(n,:) = y(n,:)/sqrt(powy(n));
end
