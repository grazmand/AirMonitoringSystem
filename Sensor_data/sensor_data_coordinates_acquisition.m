%% Sensor data coordinates and pollutant concentrations acquisition

fid = fopen(strcat(mainFolder,'\dati percorso bici\novoli_data3.csv'));
out= textscan(fid,'%s%f%f%f%f%f%f','delimiter',',', 'headerlines', 1 );
num = xlsread(strcat(mainFolder,'\dati percorso bici\AIRQinoLOG_28_09_2017.xls'));

s_number = 499;
s_x = zeros(1,s_number);
s_y = zeros(1,s_number);

%% Coordinate acquisition

for i = 1:s_number
    
    s_x(i) = (out{3}(i)-11.227) * 1000;
    s_y(i) = (out{2}(i)-43.790) * 1000;
    sensors.xy(i,1) = s_x(i);
    sensors.xy(i,2) = s_y(i);
    
end

figure
pdeplot(Mesh_Nodes,Mesh_Edges,Mesh_Elements)
hold on
plot(s_x,s_y,'g*')
%plot(sensors.xy(:,1),sensors.xy(:,2),'g*')

%% Concentration acquisition

Minimum = min(num(:,1));
Maximum = max(num(:,1));
levels = (Minimum-5):Maximum;
Naux = 200;
Xg = min(Mesh.xy(1,:)):(max(Mesh.xy(1,:))-min(Mesh.xy(1,:)))/Naux:max(Mesh.xy(1,:));
Yg = min(Mesh.xy(2,:)):(max(Mesh.xy(2,:))-min(Mesh.xy(2,:)))/Naux:max(Mesh.xy(2,:));
[XI,YI] = meshgrid(Xg,Yg);
ZI = (Minimum-5)*ones(length(XI),length(YI));

norm_1 = zeros(size(XI,2)*size(XI,2),s_number);

for ie = 1:s_number
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

%% Border_elements

index_ele = 1;
for ie = 1:size( Mesh.ele,2 )
    arr = ismember(Mesh.ele(2:4,ie),Mesh.border_nodes);
    if sum( arr ) > 0
        Mesh.border_elements( index_ele ) = ie;
        for j = 1:3
            if arr(j) == 0
                state_sys_border_nodes( j,index_ele ) = Mesh.ele(j+1,ie);
            else
                state_sys_border_nodes( j,index_ele ) = 0;
            end
        end
        index_ele = index_ele + 1;
    end
end

sort_state_sys_border_node = sort( state_sys_border_nodes );

%% Shifting coordinate // le coordinate si fanno coincidere con quelle del nodo più vicino al punto di misura dell'elemento che lo contiene

for is = 1:size( sensors.xy,1 )
    
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

%% Clear WorkSpace

clear ZI

