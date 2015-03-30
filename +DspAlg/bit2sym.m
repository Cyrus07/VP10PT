function s = bit2sym(b,mn)
%BIT2SYM Binary convert bit to symbol

n = log2(mn);
if size(b,2) ~= n
    error('bit format is not supported.');
end
% right-msb
b = fliplr(b);
for k = 1:n
    b(:,k) = b(:,k) * (2^(k-1));
end
s = sum(b,2) + 1;