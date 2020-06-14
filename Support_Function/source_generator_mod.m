function [u_f, PointInStreetRed, PointInStreetOrange, PointInStreetGreen, PointInStreetYellow] =...
    source_generator_mod(u_f, Mesh, step_time, nele, TriStreetIndexRed, TriStreetIndexOrange, TriStreetIndexYellow, TriStreetIndexGreen,...
    T_zero, par_T_zero_red_street, par_T_zero_orange_street, par_T_zero_yellow_street, par_T_zero_green_street, Mesh_Elements, emf_CO2)

A = triarea(Mesh.xy',Mesh.ele(2:4,:)');

for ip = 1:size(step_time,2)
    
    IndexPoinInStreetOrange = 1;
    IndexPoinInStreetGreen = 1;
    IndexPoinInStreetRed = 1;
    IndexPoinInStreetYellow = 1;
    
    for ie = 1:nele
        
        if ismember(ie,TriStreetIndexRed{ip}) == 1
            
            f_red = emf_CO2(Mesh_Elements(1,ie),ip);
            
            u_f_e = ( f_red * A(ie) ) * [1 1 1]'/3;
            u_f (Mesh.ele(2:4,ie),ip) =  u_f_e;
            T_zero(Mesh_Elements(1,ie)) = par_T_zero_red_street;
            T_zero(Mesh_Elements(2,ie)) = par_T_zero_red_street;
            T_zero(Mesh_Elements(3,ie)) = par_T_zero_red_street;
            
            PointInStreetRed{ip}(IndexPoinInStreetRed) = Mesh.ele(2,ie);
            PointInStreetRed{ip}(IndexPoinInStreetRed+1) = Mesh.ele(3,ie);
            PointInStreetRed{ip}(IndexPoinInStreetRed+2) = Mesh.ele(4,ie);
            IndexPoinInStreetRed = IndexPoinInStreetRed + 3;
            
        elseif ismember(ie,TriStreetIndexOrange{ip}) == 1
            
            f_orange = emf_CO2(Mesh_Elements(1,ie),ip);
            
            u_f_e = ( f_orange * A(ie) ) * [1 1 1]'/3;
            u_f (Mesh.ele(2:4,ie),ip) =  u_f_e;
            T_zero(Mesh_Elements(1,ie)) = par_T_zero_orange_street;
            T_zero(Mesh_Elements(2,ie)) = par_T_zero_orange_street;
            T_zero(Mesh_Elements(3,ie)) = par_T_zero_orange_street;
            
            PointInStreetOrange{ip}(IndexPoinInStreetOrange) = Mesh.ele(2,ie);
            PointInStreetOrange{ip}(IndexPoinInStreetOrange+1) = Mesh.ele(3,ie);
            PointInStreetOrange{ip}(IndexPoinInStreetOrange+2) = Mesh.ele(4,ie);
            IndexPoinInStreetOrange = IndexPoinInStreetOrange + 3;
            
        elseif ismember(ie,TriStreetIndexYellow{ip}) == 1
            
            f_yellow = emf_CO2(Mesh_Elements(1,ie),ip);
            
            u_f_e = ( f_yellow * A(ie) ) * [1 1 1]'/3;
            u_f (Mesh.ele(2:4,ie),ip) =  u_f_e;
            T_zero(Mesh_Elements(1,ie)) = par_T_zero_yellow_street;
            T_zero(Mesh_Elements(2,ie)) = par_T_zero_yellow_street;
            T_zero(Mesh_Elements(3,ie)) = par_T_zero_yellow_street;
            
            PointInStreetYellow{ip}(IndexPoinInStreetYellow) = Mesh.ele(2,ie);
            PointInStreetYellow{ip}(IndexPoinInStreetYellow + 1) = Mesh.ele(3,ie);
            PointInStreetYellow{ip}(IndexPoinInStreetYellow + 2) = Mesh.ele(4,ie);
            IndexPoinInStreetYellow = IndexPoinInStreetYellow + 3;
            
            
        elseif ismember(ie,TriStreetIndexGreen{ip}) == 1
            
            f_green = emf_CO2(Mesh_Elements(1,ie),ip);
            
            u_f_e = ( f_green  * A(ie) ) * [1 1 1]'/3;
            u_f (Mesh.ele(2:4,ie),ip) =  u_f_e;
            T_zero(Mesh_Elements(1,ie)) = par_T_zero_green_street;
            T_zero(Mesh_Elements(2,ie)) = par_T_zero_green_street;
            T_zero(Mesh_Elements(3,ie)) = par_T_zero_green_street;
            
            PointInStreetGreen{ip}(IndexPoinInStreetGreen) = Mesh.ele(2,ie);
            PointInStreetGreen{ip}(IndexPoinInStreetGreen + 1) = Mesh.ele(3,ie);
            PointInStreetGreen{ip}(IndexPoinInStreetGreen + 2) = Mesh.ele(4,ie);
            IndexPoinInStreetGreen = IndexPoinInStreetGreen + 3;
            
        end
    end
end

end

