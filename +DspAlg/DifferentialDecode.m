function b = DifferentialDecode(x,mn)


map_diff_enc_16qam = [...
    2 1 1; 2 0 1; 1 1 0; 1 1 1;
    2 1 0; 2 0 0; 1 0 0; 1 0 1;
    3 0 1; 3 0 0; 0 0 0; 0 1 0;
    3 1 1; 3 1 0; 0 0 1; 0 1 1 ];
map_diff_enc_64qam = [...
    2 1 0 1 0; 2 1 1 1 0; 2 0 1 1 0; 2 0 0 1 0; 1 1 0 0 0; 1 1 0 0 1; 1 1 0 1 1; 1 1 0 1 0;
    2 1 0 1 1; 2 1 1 1 1; 2 0 1 1 1; 2 0 0 1 1; 1 1 1 0 0; 1 1 1 0 1; 1 1 1 1 1; 1 1 1 1 0;
    2 1 0 0 1; 2 1 1 0 1; 2 0 1 0 1; 2 0 0 0 1; 1 0 1 0 0; 1 0 1 0 1; 1 0 1 1 1; 1 0 1 1 0;
    2 1 0 0 0; 2 1 1 0 0; 2 0 1 0 0; 2 0 0 0 0; 1 0 0 0 0; 1 0 0 0 1; 1 0 0 1 1; 1 0 0 1 0;
    3 0 0 1 0; 3 0 0 1 1; 3 0 0 0 1; 3 0 0 0 0; 0 0 0 0 0; 0 0 1 0 0; 0 1 1 0 0; 0 1 0 0 0;
    3 0 1 1 0; 3 0 1 1 1; 3 0 1 0 1; 3 0 1 0 0; 0 0 0 0 1; 0 0 1 0 1; 0 1 1 0 1; 0 1 0 0 1;
    3 1 1 1 0; 3 1 1 1 1; 3 1 1 0 1; 3 1 1 0 0; 0 0 0 1 1; 0 0 1 1 1; 0 1 1 1 1; 0 1 0 1 1;
    3 1 0 1 0; 3 1 0 1 1; 3 1 0 0 1; 3 1 0 0 0; 0 0 0 1 0; 0 0 1 1 0; 0 1 1 1 0; 0 1 0 1 0;];


if mn == 2
    x_delay = [0; x(1:end-1)];
    b = xor(x, x_delay);
    return
end

if mn == 4
    Initial = [0,0];
    xd = [Initial; x(1:end-1,:)];
    I = x(:,1);
    Q = x(:,2);
    ID = xd(:,1);
    QD = xd(:,2);
    % % classic mode
    % u = xor(I,~ID).*xor(I, QD) + xor(Q,~ID).*xor(Q,~QD);
    % v = xor(I,~ID).*xor(I,~QD) + xor(Q, ID).*xor(Q,~QD);
    % VPI mode
    u = xor(~I,~ID).*xor(~I,~QD) + xor(~Q, ID).*xor(~Q,~QD);
    v = xor(~I, ID).*xor(~I,~QD) + xor(~Q, ID).*xor(~Q, QD);
    b = [u v];
    return
end

if mn == 16
    MAPdiff = map_diff_enc_16qam;
end
if mn == 64
    MAPdiff = map_diff_enc_64qam;
end

MAPhead = [0 0; 0 1; 1 1; 1 0];
xm = MAPdiff(DspAlg.bit2sym(x,mn),:);
out0 = xm(:,1);
out1 = MAPhead( mod(diff(out0),4) + 1, :);
b = [out1, xm(2:end,2:end)];
