function [sort_state_sys_border_node,Mesh] = Bord_ele(Mesh)

%% Border_elements
index_ele = 1;
state_sys_border_nodes = zeros(3,size( Mesh.ele,2 ));
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

end