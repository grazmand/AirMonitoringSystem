function [shapeN] = Get_shapeN( Mesh, element, point )

%% point = [x y]

Nvertices = Mesh.ele(1,1);
shapeN = zeros(1,Nvertices);

for vertex = 1:Nvertices
    
    shapeN(vertex) = Mesh.shape{element}(:,vertex)' * [1;point'];
    
end

end