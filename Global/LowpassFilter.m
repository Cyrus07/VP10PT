function varargout = LowpassFilter( Fs, Bw, varargin )
%LOWPASSFILTER The fifth order digital bessel low-pass filter (LPF)
%
%   Example
%
%   See also

%   copyright2012 wangdawei 2012/7/4

[b a] = besself(5, 2*pi*Bw/0.6166758);
[bz az] = impinvar(b, a, Fs);
for k = 1:length(varargin)
    varargout{k} = filter( bz, az, varargin{k} );
end