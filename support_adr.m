x=mesh.node_coordinates(1,:)
y=mesh.node_coordinates(2,:)
ind=find((x.^2+y.^2)==min(x.^2+y.^2))

x=mesh.node_coordinates(1,:)
y=mesh.node_coordinates(2,:)
find((x.^2+y.^2)==min(x.^2+y.^2))
x(ind)
y(ind)
p=ds.state(ind,:)
t=dt.value:dt.value:dt.value*600

figure
plot(t,p,'-ro')

pan=9*exp(-0.25*(x(ind)^2+y(ind)^2)./(2*t+9))./(2*t+9)

hold on
plot(t,pan,'-bx')