function y = arbitrary_wave(x,sps,bw)

x = x(1:end);

x = repmat(x,sps,1);

x = x(1:end);

[b a] = besself(5,2*pi*bw/0.6166758);
[bz az] = impinvar(b,a,sps);

y = filter(bz,az,x);

[cval lags] = xcorr(x,y);
[~,index] = max(cval);
y = [y(1-lags(index):end),y(1:-lags(index))];