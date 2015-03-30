function y = ReqOSNR(osnr, ber, th)

berub = max(ber);
berlb = min(ber);
if (th>berub)||(th<berlb)
    y = NaN;
    return;
end

tmp = (ber(1:end-1)-th).*(ber(2:end)-th);
[vtmp, indtmp] = min(tmp);
if vtmp == 0
    if ber(indtmp) == 0
        y = osnr(indtmp);
    else
        y = osnr(indtmp+1);
    end
else
    [y, ~] = CrossPoint([osnr(indtmp), ber(indtmp)], [osnr(indtmp+1), ber(indtmp+1)],...
        [osnr(indtmp), th], [osnr(indtmp+1), th]);
end
end