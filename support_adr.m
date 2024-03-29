% x=mesh.node_coordinates(1,:);
% y=mesh.node_coordinates(2,:);
% ind=find((x.^2+y.^2)==min(x.^2+y.^2));

% x=mesh.node_coordinates(1,:);
% y=mesh.node_coordinates(2,:);
% ind=find((x.^2+y.^2)==min(x.^2+y.^2));
% x(ind)
% y(ind)
x=10; y=10;
% % p=ds.state(ind,:);
% p1=s1.signalForm;
t=time.times;

% h=figure;
% hold on

p1=load(ssf_path);
p1=p1.ssf;
h=figure;
plot(t, p1,'ro')
% p3=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l5_sensor_signal_form.mat');
% p3=p3.ssf;
% p4=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l10_sensor_signal_form.mat');
% p4=p4.ssf;
% p5=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l15_sensor_signal_form.mat');
% p5=p5.ssf;
% p6=load('/home/graziano/Desktop/air quality monitoring system/data/sensor data/l20_sensor_signal_form.mat');
% p6=p6.ssf;

% plot(t,p1,'-ro')
% plot(t,p2,'-yo')
% plot(t,p3,'-go')
% plot(t,p4,'-mo')
% plot(t,p5,'-co')
% plot(t,p6,'-ko')

%%%%%%%%%%%%% analytical %%%%%%%%%%%%%%%
% pan=9*exp(-0.25*(x(ind)^2+y(ind)^2)./(2*t+9))./(2*t+9);
sigma=ds.sigma;

vx=speed(1);
vy=speed(2);

e11=exp(-0.25*((x-7-vx*t).^2)./(0.25*sigma^2+d_rate*t));
e12=exp(-0.25*((y-7-vy*t).^2)./(0.25*sigma^2+d_rate*t));
pan1=0.25*sigma^2*(1./(0.25*sigma^2+d_rate*t)).*e11.*e12;

e21=exp(-0.25*((x+11-vx*t).^2)./(0.25*sigma^2+d_rate*t));
e22=exp(-0.25*((y+11-vy*t).^2)./(0.25*sigma^2+d_rate*t));
pan2=0.25*sigma^2*(1./(0.25*sigma^2+d_rate*t)).*e21.*e22;

pan = pan1 + pan2;

hold on
plot(t,pan,'-bx')

title('analyitical vs fem solution')
xlabel('time [sec.]')

% legend('fem L=1.5m','fem L=3m','fem L=5m','fem L=10m','fem L=15m','fem L=20m','analytical')
legend('analytical')

axes=gca;
set(axes,'FontWeight','bold')
xlabel('time [sec.]','FontWeight','bold')
ylabel('pollutant concentration [ppm]','FontWeight','bold')
grid on
filename=sprintf('%s/comparison.png',image_folder);
fig_fn=sprintf('%s/comparison.fig',image_folder);
saveas(h,filename); saveas(h,fig_fn)
