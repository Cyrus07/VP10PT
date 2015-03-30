function y = RectifyPolyval(x,p)
if isempty(p)
    p = [];
end

if isempty(p)
    y = x;
else
%     I = real(x);
%     Q = imag(x);
    y = polyval([p 0], abs(x));
end

end