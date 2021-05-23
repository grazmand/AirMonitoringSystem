% x=mesh.node_coordinates(1,:);
% y=mesh.node_coordinates(2,:);
% ind=find((x.^2+y.^2)==min(x.^2+y.^2));

% x=mesh.node_coordinates(1,:);
% y=mesh.node_coordinates(2,:);
% ind=find((x.^2+y.^2)==min(x.^2+y.^2));
% x(ind)
% y(ind)
x=10; y=10;
% p=ds.state(ind,:);
p=s1.signalForm;
t=time.times;

h=figure;
plot(t,p,'-ro')


%%%%%%%%%%%%% analytical %%%%%%%%%%%%%%%
% pan=9*exp(-0.25*(x(ind)^2+y(ind)^2)./(2*t+9))./(2*t+9);
sigma=ds.sigma;
vx=speed(1);
vy=speed(2);
e1=exp(-0.25*((x-vx*t).^2)./(0.25*sigma^2+d_rate*t));
e2=exp(-0.25*((y-vy*t).^2)./(0.25*sigma^2+d_rate*t));
pan=0.25*sigma^2*(1./(0.25*sigma^2+d_rate*t)).*e1.*e2;

hold on
plot(t,pan,'-bx')

title('analyitical vs fem solution')
xlabel('time [sec.]')

legend('fem','analytical')

axes=gca;
set(axes,'FontWeight','bold')
xlabel('time [sec.]','FontWeight','bold')
ylabel('pollutant concentration [ppm]','FontWeight','bold')
grid on
filename=sprintf('%s/comparison.png',image_folder);
fig_fn=sprintf('%s/comparison.fig',image_folder);
saveas(h,filename); saveas(h,fig_fn)
