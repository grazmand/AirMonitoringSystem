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
p1=s1.signalForm;
t=time.times;

h=figure;
hold on

p2=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l3_sensor_signal_form.mat');
p2=p2.ssf;
p3=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l5_sensor_signal_form.mat');
p3=p3.ssf;
p4=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l10_sensor_signal_form.mat');
p4=p4.ssf;
p5=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l15_sensor_signal_form.mat');
p5=p5.ssf;
p6=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l20_sensor_signal_form.mat');
p6=p6.ssf;

plot(t,p1,'-ro')
plot(t,p2,'-yo')
plot(t,p3,'-go')
plot(t,p4,'-mo')
plot(t,p5,'-co')
plot(t,p6,'-ko')

%%%%%%%%%%%%% analytical %%%%%%%%%%%%%%%
% pan=9*exp(-0.25*(x(ind)^2+y(ind)^2)./(2*t+9))./(2*t+9);
sigma=ds.sigma;
vx=speed(1);
vy=speed(2);
e1=exp(-0.25*((x-vx*t).^2)./(0.25*sigma^2+d_rate*t));
e2=exp(-0.25*((y-vy*t).^2)./(0.25*sigma^2+d_rate*t));
pan=0.25*sigma^2*(1./(0.25*sigma^2+d_rate*t)).*e1.*e2;

plot(t,pan,'-bx')

title('analyitical vs fem solution')
xlabel('time [sec.]')

legend('fem L=1.5m','fem L=3m','fem L=5m','fem L=10m','fem L=15m','fem L=20m','analytical')

axes=gca;
set(axes,'FontWeight','bold')
xlabel('time [sec.]','FontWeight','bold')
ylabel('pollutant concentration [ppm]','FontWeight','bold')
grid on
filename=sprintf('%s/comparison.png',image_folder);
fig_fn=sprintf('%s/comparison.fig',image_folder);
saveas(h,filename); saveas(h,fig_fn)
