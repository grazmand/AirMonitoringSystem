function [sensors,s_number,h_sens,time_env,time_step,time_sensor,Mesh,num] = sensor_data(mainFolder,Mesh_Nodes,Mesh_Elements,Mesh_Edges,Mesh,sort_state_sys_border_node)

%Sensor data

fid = fopen(strcat(mainFolder,'\dati percorso bici\novoli_data3.csv'));
out= textscan(fid,'%s%f%f%f%f%f%f','delimiter',',', 'headerlines', 1 );
num = xlsread(strcat(mainFolder,'\dati percorso bici\AIRQinoLOG_28_09_2017.xls'));

figure
pdeplot(Mesh_Nodes,Mesh_Edges,Mesh_Elements)
s_x = zeros(1,499);
s_y = zeros(1,499);

for i = 1:499
    
    s_x(i) = (out{3}(i)-11.227) * 1000;
    s_y(i) = (out{2}(i)-43.790) * 1000;
    
end

hold on
plot(s_x,s_y,'g*')

Mesh.xy(1,:) = Mesh_Nodes(1,:);
Mesh.xy(2,:) = Mesh_Nodes(2,:);
Mesh.ele(1,:) = 3 * ones(size(Mesh_Elements,2),1)';
Mesh.ele(2,:) = Mesh_Elements(1,:);
Mesh.ele(3,:) = Mesh_Elements(2,:);
Mesh.ele(4,:) = Mesh_Elements(3,:);

for i=1:size(Mesh_Elements,2)
    [~,~,Shape] = EleN_B( Mesh, i );
    Mesh.shape{i} = Shape;
end

s_number = 499;

for i = 1:499
    
    s_x(i) = s_x(i);
    s_y(i) = s_y(i);
    sensors.xy(i,1) = s_x(i);
    sensors.xy(i,2) = s_y(i);
    
end

Minimum = min(num(:,1));
Maximum = max(num(:,1));
levels = (Minimum-5):Maximum;
Naux = 200;
Xg = min(Mesh.xy(1,:)):(max(Mesh.xy(1,:))-min(Mesh.xy(1,:)))/Naux:max(Mesh.xy(1,:));
Yg = min(Mesh.xy(2,:)):(max(Mesh.xy(2,:))-min(Mesh.xy(2,:)))/Naux:max(Mesh.xy(2,:));
[XI,YI] = meshgrid(Xg,Yg);
ZI = (Minimum-5)*ones(length(XI),length(YI));

norm_1 = zeros(size(XI,2)*size(XI,2),499);

for ie = 1:499
    for i = 1:size(XI,2)*size(XI,2)
        norm_1(i,ie) = norm([s_x(ie) s_y(ie)] - [XI(i) YI(i)]);
    end
    
    int = min(norm_1(:,ie));
    for i = 1:size(XI,2)*size(XI,2)
        if norm_1(i,ie) == int
            ZI(i) = num(ie,1);
        end
    end
end

figure
hold on

h_sens = contour3(XI,YI,ZI,levels,'LineWidth',5);

az = 180;
el = 60;
view(az,el);

zlim( [Minimum-5 Maximum] )
colorbar;
caxis( [Minimum-5 Maximum] )
colormap(jet)

H_sens = pdemesh(Mesh_Nodes,Mesh_Edges,Mesh_Elements);

H_sens(2).ZData = (Minimum - 5) * ones(1,size(H_sens(2).XData,2));

H_sens(2).LineWidth = 3;

time_env = [];
time_env{1} =  1:450 ;
time{1} =  62:62 + ( 134 - 1);
time_env{2} =  451:690 ;
time{2} =  451:451 + ( 234 - 135);
time_env{3} =  691:1080 ;
time{3} = 691:691 + ( 323 - 235);
time_env{4} = 1081:2130 ;
time{4} = 1081:1081 + ( 499 - 324);
time_step  = 1:30:2131 ;
time_sensor = [time{1},time{2},time{3},time{4}];
time_sensor = unique(time_sensor);


%% Shifting coordinate


for is = 1:size( sensors.xy,1 )
    
    disp( is )
    
    if is == 484
        
        disp('484')
        
    end
    
    for ie = 1:size( Mesh.border_elements,2 )
        
        xv = [Mesh_Nodes(1,(Mesh_Elements(1,Mesh.border_elements(ie)))) , Mesh_Nodes(1,(Mesh_Elements(2,Mesh.border_elements(ie)))) ,...
            Mesh_Nodes(1,(Mesh_Elements(3,Mesh.border_elements(ie))))];
        
        yv = [Mesh_Nodes(2,(Mesh_Elements(1,Mesh.border_elements(ie)))) , Mesh_Nodes(2,(Mesh_Elements(2,Mesh.border_elements(ie)))) ,...
            Mesh_Nodes(2,(Mesh_Elements(3,Mesh.border_elements(ie))))];
        
        if inpolygon( sensors.xy(is,1),sensors.xy(is,2),xv,yv )
            
            sensors.xy(is,:) = Mesh_Nodes( :,sort_state_sys_border_node(3,ie) )';
            
        end       
    end
end

end

