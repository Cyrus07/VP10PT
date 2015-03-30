function cd = TimedomainCDE(x,seq,sps)

Len = length(seq);
y = sum(x,2);

ind = (0:Len-1)*sps;
for d = 1 : length(y)-Len*sps
    Lambda(d) = abs(seq'*y(d+ind));
end

figure;plot(Lambda);

end