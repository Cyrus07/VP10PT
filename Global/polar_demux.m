function [yout,mse,deth,h1,h2] = polar_demux( xin,mn,sps,mu,ntaps,stage,errid,iter)
%POLAR_DEMUX Polarization demultiplexing and channel equalization
%   
%   Copyright2011 WANGDAWEI $16/3/2011$ 

x = DspAlg.Normalize(xin,mn) / (sqrt(mn)-1);

% make sure the tap number is odd
ntaps = ntaps + ~mod(ntaps,2);

% taps initialization
halfnt = floor(ntaps/2);
h1 = zeros(ntaps,2);
h2 = zeros(ntaps,2);
h1(halfnt+1,:) = [1 0];
h2(halfnt+1,:) = [0 1];

method = 0;
cstl = DspAlg.constellation(mn);
extendx = [ x(end-halfnt+1:end,:); x ; x(1:halfnt,:) ];

if errid == 0
    for ii = 1:iter
        [xx mse deth] = LMS_FILTER(extendx,h1,h2,ntaps,mu,cstl,sps);
    end
else
    cm = get_radius(cstl,errid,mn);
    for ii = 1:iter
        [xx mse deth] = CMA_FILTER(extendx,h1,h2,ntaps,mu,cm,sps,errid,stage,method);
    end
end

% format the output
yout = xx(  1:sps:end,:);
mse  = mse( 1:sps:end  );
deth = deth(1:sps:end  );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = get_radius(c,id,mn)
if id==1 || id==7
    r = mean(abs(c).^4) / mean(abs(c).^2); return;
end
if id==2
    r = mean(real(c).^4) / mean(real(c).^2); return;
end
if id==3
    r = [sqrt(1+1);sqrt(1+9);sqrt(9+9)]/3; return;
end
if mn==16
    r = [1+1;1+9;9+9]/9; return;
end
if mn==64
%     r = [1+1;1+9;1+25;9+9;9+25;9+49;25+25;25+49;49+49]/49;
    r = [1+1;1+9;1+25;9+25;9+49;25+49;49+49]/49; return;
end

function test_h(h1,h2)
scatterplot(h1(:,1));
scatterplot(h1(:,2));
scatterplot(h2(:,1));
scatterplot(h2(:,2));
for ii=1:ntaps
    ev(:,ii) = eig([h1(ii,:);h2(ii,:)]);
end
scatterplot(ev(1,:));
scatterplot(ev(2,:));
figure; plot(angle(ev(1,:)));
figure; plot(angle(ev(2,:)));