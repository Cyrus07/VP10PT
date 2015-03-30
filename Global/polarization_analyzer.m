function h_PoincareSphere = polarization_analyzer( ...
    h_PoincareSphere,visible,e_in,varargin)
% Polarization analyzer
if size(e_in,1)>size(e_in,2)
    e_in = e_in.';
end
s = j2s(e_in);
% s = j2ae(e_in);
if isempty(h_PoincareSphere)
    h_PoincareSphere = poincare_sphere;
end
figure(h_PoincareSphere)
% plot3(s(1,:),s(2,:),s(3,:),varargin{:})
scatter3(s(1,:),s(2,:),s(3,:),varargin{:})
set(h_PoincareSphere,'visible',visible)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s_out = j2s(e_in)
% Transfer Jones vector to normalized Stokes vector

sigma = {[1,0;0,-1],[0,1;1,0],[0,-1i;1i,0]};
data_length = length(e_in(1,:));
s_out = zeros(3,data_length);

for loop_1 = 1:3
    e_tmp = sigma{loop_1} * e_in;
    for loop_2 = 1:data_length
        s_out(loop_1,loop_2) = e_in(:,loop_2)' * e_tmp(:,loop_2);
    end
end

s0 = sqrt(max(s_out(1,:).^2 + s_out(2,:).^2 + s_out(3,:).^2));
s_out = [s_out(1,:)./s0;s_out(2,:)./s0;s_out(3,:)./s0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s_out = j2ae(e_in)

tmp = abs(e_in(1,:)).^2 / abs(e_in(2,:)).^2;
k = 1 ./ (tmp+1);
d = angle(e_in(1,:))-angle(e_in(2,:));
tan2ita = 2*sqrt(k.*(1-k)).*cos(d)/(1-2.*k);
sin2eps = 2*sqrt(k.*(1-k)).*sin(d);
azi2 = atan(tan2ita);
ell2 = asin(sin2eps);
s_out = [cos(ell2).*cos(azi2);cos(ell2).*sin(azi2);sin(ell2)];