function [sys_dir] = getInnerNodes(Mesh_Elements,Dirichlet_nodes)

tt = Mesh_Elements;
ind_elem = 1;
for ie = 1:size(tt,2)
    for je = 1:3
        if ismember(tt(je,ie),Dirichlet_nodes)
            
            tri_elem(ind_elem) = ie;
            ind_elem = ind_elem + 1;
            
        end
    end
end

el_dirichlet = unique(tri_elem);
sm_tri = 1;
for ie = 1:size(tt,2)
    if ismember(ie,el_dirichlet)
        for je = 1:3
            if ~ismember(tt(je,ie),Dirichlet_nodes)
                
                nod(sm_tri) = tt(je,ie);
                
                sm_tri = sm_tri + 1;
            end
        end
    end
end

nod_1 = sort(nod);
nod_1 = unique(nod_1);
for ip = 1:size(Dirichlet_nodes,1)
    for ie = 1:size(tt,2)
        if ismember(Dirichlet_nodes(ip),tt(1:3,ie))
            cross = intersect(tt(1:3,ie),nod_1);
            if ~isempty(cross)
                sys_dir(ip) = cross(1);
            else
                sys_dir(ip) = sys_dir(ip - 1);               
            end
        end
    end
end

end

