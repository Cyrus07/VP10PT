function y = DelayInterferometer( x,sps )
%DELAYINTERFEROMETER Summary of this function goes here
%   Detailed explanation goes here
dx = circshift(x, -sps);
dy = x.*conj(dx);
% ry = real(dy);
ry = reshape(dy,sps,[],size(dy,2));
if sps > 1
    y = squeeze( sum(ry) );
else
    y = squeeze( ry );
end
% figure; plot(y(:,1),'.'); grid on
end