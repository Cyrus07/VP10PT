function h_PoincareSphere = poincareSphere(obj)
% Plot a Poincar sphere

leftbottom = 50;
width = 800;
height = 600;
h_PoincareSphere = figure('visible','on');
set(gcf,'position', ...
    [leftbottom,leftbottom,leftbottom+width,leftbottom+height])
sphere
axis('equal','off')
colormap(gray)
shading interp
alpha(0.6)
view([135,25])
hold on
plot3([0,2],[0,0],[0,0],'k-','linewidth',2)
plot3([0,0],[0,2],[0,0],'k-','linewidth',2)
plot3([0,0],[0,0],[0,1.5],'k-','linewidth',2)
theta_tmp = linspace(0,2*pi,60);
x_tmp = cos(theta_tmp);
y_tmp = sin(theta_tmp);
z_tmp = zeros(1,length(theta_tmp));
plot3(x_tmp,y_tmp,z_tmp,'k-','linewidth',1)
x_tmp = cos(theta_tmp);
y_tmp = zeros(1,length(theta_tmp));
z_tmp = sin(theta_tmp);
plot3(x_tmp,y_tmp,z_tmp,'k-','linewidth',1)
x_tmp = zeros(1,length(theta_tmp));
y_tmp = cos(theta_tmp);
z_tmp = sin(theta_tmp);
plot3(x_tmp,y_tmp,z_tmp,'k-','linewidth',1)
clear *tmp
text(2.1,0,0,'S_1','FontWeight','b','FontSize',14)
text(0,2.1,0,'S_2','FontWeight','b','FontSize',14)
text(0,0,1.6,'S_3','FontWeight','b','FontSize',14)
