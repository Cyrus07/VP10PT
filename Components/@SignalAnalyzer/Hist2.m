function local_max = Hist2(x1, edges)
%HIST2 draw color histogram of complexed signal

% Copyright: WANG Dawei [EIE PolyU]   $Date:16/3/2010$

if nargin < 2
    edges = linspace(-1.4,1.4,80);
    fine_edge = linspace(-1.4,1.4,800);
end

% x1 = x1 / mean(abs(x1)) * 2.5;
x1 = DspAlg.Normalize(x1,64) / 7;

N = length(edges);
z1 = zeros(N, N);

[~,cbin] = histc(real(x1),edges);
[~,dbin] = histc(imag(x1),edges);
cbin = cbin + 1;
dbin = dbin + 1;


for ii = 1:length(x1)
    z1(cbin(ii),dbin(ii)) = z1(cbin(ii),dbin(ii)) + 1;
end

[x,y] = meshgrid(edges);
[xx,yy] = meshgrid(fine_edge);
z2 = interp2(x,y,z1,xx,yy);

% figure; mesh(xx,yy,z2);
% view(0,90);

z3 = smooth2a(z2,25,25);

xy = FastPeakFind(z3);
xy = (xy-400)/400*1.4 - 0.015;

% for ii = 1:800
%     [~,zp_row{ii}] = findpeaks(z2(ii,:));
% end
% 
% for ii = 1:8
%     row = 1 + (ii-1)*100;
%     sum_row(ii,:) = sum(z2(row:row+99,:));
%     [~,zp_row{ii}] = findpeaks(smooth(sum_row(ii,:),30));
%     sum_col(:,ii) = sum(z2(:,row:row+99),2);
%     [~,zp_col{ii}] = findpeaks(smooth(sum_col(:,ii),30));
%     
%     mx(ii,:) = (zp_row{ii} - 400) / 401 * 1.4;
%     my(ii,:) = (zp_col{ii} - 400) / 401 * 1.4;
% end

% a = xy(:,1);
% b = xy(:,2);
% a = sort(a);
% c = reshape(a,8,[]);
% c = c.';
% a = c(:);

local_max = xy(:,1) + 1i*xy(:,2);
% scatterplot(local_max);

h = w_figure;
surface(edges,edges,z1);
shading interp
colormap jet
colorbar