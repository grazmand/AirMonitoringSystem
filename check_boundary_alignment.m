%% check boundary alignment

Mesh_Boundaries_X = Mesh_Boundaries_Coordinates(1,:)*110;
Mesh_Boundaries_Y = Mesh_Boundaries_Coordinates(2,:)*110;
Domain_Geometry_Description = [2;size(Mesh_Boundaries_Coordinates,2);...
    Mesh_Boundaries_X';Mesh_Boundaries_Y'];
Domain_Geometry_Description_Decomposition = decsg(Domain_Geometry_Description);
x=Domain_Geometry_Description_Decomposition(2,:);
y=Domain_Geometry_Description_Decomposition(4,:);

POINTARRAY = [mesh.node_coordinates(1,:)',mesh.node_coordinates(2,:)'];
vertices = [x',y'];
edges = [vertices vertices([2:end 1], :)];
B = isPointOnEdge(POINTARRAY, edges);
[rows,cols,vals] = find(B==1);
boundary_counterclockwiseNodeIndexes = rows;

% check

if true
    figure
    plot(mesh.node_coordinates(1,rows),...
        mesh.node_coordinates(2,rows),'ro','DisplayName','mesh boundary nodes')
    hold on
    plot(x,y,'-bx','DisplayName', 'domain boundary nodes')
    title('check bounds')
    axes = gca;
    set(axes,'FontWeight','bold')
    xlabel('latitude [m]','FontWeight','bold')
    ylabel('longitude [m]','FontWeight','bold')
    legend()
    grid on
end

clearvars Mesh_Boundaries_X Mesh_Boundaries_Y Domain_Geometry_Description Domain_Geometry_Description_Decomposition...
x y rows cols vals vertices edges B POINTARRAY