function [x, y] = CrossPoint(A,B,C,D)
% C     B
% A     D
xlimit(1) = min([A(1),B(1),C(1),D(1)]);
xlimit(2) = max([A(1),B(1),C(1),D(1)]);
ylimit(1) = min([A(2),B(2),C(2),D(2)]);
ylimit(2) = max([A(2),B(2),C(2),D(2)]);

[Ix(1), Iy(1)] = cp(A,B,C,D);
[Ix(2), Iy(2)] = cp(A,C,B,D);
[Ix(3), Iy(3)] = cp(A,D,B,C);
if (Ix(1)>xlimit(1))&&(Ix(1)<xlimit(2))...
        &&(Iy(1)>ylimit(1))&&(Iy(1)<ylimit(2))
    x = Ix(1); y = Iy(1);
elseif (Ix(2)>xlimit(1))&&(Ix(2)<xlimit(2))...
        &&(Iy(2)>ylimit(1))&&(Iy(2)<ylimit(2))
    x = Ix(2); y = Iy(2);
elseif(Ix(3)>xlimit(1))&&(Ix(3)<xlimit(2))...
        &&(Iy(3)>ylimit(1))&&(Iy(3)<ylimit(2))
    x = Ix(3); y = Iy(3);
else
    x = NaN; y = NaN;
end

function [x,y] = cp(a, b, c,d)

k1 = (b(2)-a(2))/(b(1)-a(1));
k2 = (d(2)-c(2))/(d(1)-c(1));

if isinf(k1)
    x = b(1);
    if isinf(k2)
        y = inf;
    else
        y = (x-c(1))*k2+c(2);
    end
else
    if isinf(k2)
        x = c(1);
        y = (x-a(1))*k1+a(2);
    else
        x = ((c(2)-a(2))-(k2*c(1)-k1*a(1)))/(k1-k2);
        y = (x-a(1))*k1+a(2);
    end
end
    