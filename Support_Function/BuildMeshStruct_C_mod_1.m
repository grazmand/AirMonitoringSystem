function [Mesh]=BuildMeshStruct_C_mod_1(Mesh,fp,pp,tt)

%% EDITED 07-09-2014 Octave-->MATLAB

% With respect to BuildMeshStruct_B, no more nord sud..., but nlab gives the label associated to each border of the polygon (if 6 faces => 6 labels).
% With respect to BuildMeshStruct, added "vertices" and "bounds" (useful in distributed algorithms) in the output Mesh

%     ymax = max(fp(:,2));
%     ymin = min(fp(:,2));
%     xmax = max(fp(:,1));
%     xmin = min(fp(:,1));
%
%     [p, t] = simpmesh(prec, [xmin ymin; xmax ymax], fp, sp);

%     for i = 1:size(p,1)
%     text(p(i,1),p(i,2),num2str(i,'%d'), 'BackgroundColor',[1 1 1])
%     end;
%     title(['Mesh (system simulator). Number of nodes = ', num2str(size(p,1) )])
p=pp';
t=tt';
Mesh.xy = Mesh.xy;
Mesh.vertices = fp;
Mesh.bounds = polygonBounds(Mesh.vertices);
nele  = size(t',2);
Mesh.ele = Mesh.ele;
Mesh.elab = ones(1,nele); % tutto rame
bool = zeros(size(p,1),(size(fp,1)-1));
Mesh.nlab = zeros(1,size(p,1));
Mesh.edges = reshape(fp', 1, []);
Mesh.boundPoints = cell(1,(size(fp,1)-1));
Mesh.border_nodes = [];

for border = 1:(size(fp,1)-1)
    bool(:,border) = isPointOnEdge(p,Mesh.edges(border*2-1:border*2+2),1e-09);
    Mesh.nlab(1,bool(:,border)==1) = border;
    Mesh.boundPoints{1,border} = find(bool(:,border)==1);
    Mesh.border_nodes = union(Mesh.border_nodes,Mesh.boundPoints{1,border});
end

end