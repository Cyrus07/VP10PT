function CheckContinuity(a, b, ovlpr)
a = reshape(a(end*(1-ovlpr*2)+1:end),1,[]);
b = reshape(b(1:end*ovlpr*2),1,[]);
s = a*a'/length(a);
d = a-b;
n = d*d'/length(d);
if s/n<1000
%     error('NOT Continue');
end
% figure(1)
% plot(real(a),'.');hold on;plot(real(b),'o');
figure(2); hold on;
plot(real(b));
plot(real(d),'r');
% ylim([-1e-6 1e-6])