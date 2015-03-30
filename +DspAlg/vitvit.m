function y = vitvit( x, P, M, k, applyunwrap)
if P == M
    x = x .^ P;
else
    x = abs(x).^P .* exp( 1j*angle( x.^ M ) );
end
for pol = 1:size(x,2)
    x(:,pol) = smooth(x(:,pol),k);
end
if applyunwrap
    y = unwrap( angle(x) ) / M;
else
    y = angle(x) / M;
end