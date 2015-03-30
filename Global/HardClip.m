function y = HardClip(x, cr, cl)

if nargin<3
    delta = sqrt(mean(x.*conj(x)));
    if isempty(cr)
        y = x; return;
    end
    clippingLevel = delta*cr;
elseif nargin <4
    clippingLevel = cl;
    if isempty(cl)
        y = x; return;
    end
end

if isreal(x)
    y = min(max(x,-1*clippingLevel),clippingLevel);
else
    amp = abs(x);
    phi = angle(x);
    amp2 = min(clippingLevel,amp);
    y = amp2 .* exp(1i*phi);
end