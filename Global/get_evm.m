function out = get_evm(data_in,m)
%

if m == 2
    num = 4;
elseif m==4
    num = 16;
elseif m==6 
    num=64;
end

data_partationed = cell(num,1);
PS = zeros(num,1);
PN = zeros(num,1);

if m == 2
data_partationed = DspAlgExp.partationing_qpsk(data_in,0);
elseif m==4
data_partationed = partationing_16qam(data_in,-2,0,2);
else
data_partationed = DspAlgExp.partationing_64QAM(data_in,7);    
end

for jj = 1 : num
    tmp = data_partationed{jj};
    PS(jj) = abs(mean(tmp))^2;
    PN(jj) = mean(abs(tmp - mean(tmp)).^2);
end
% ps = mean(PS);
ps = abs(7+7i).^2;
pn = mean(PN);
evm = pn/ps;
% out = 10*log10(1/evm);
out=sqrt(evm);
