function [u_f, PointInStreetRed, PointInStreetOrange, PointInStreetGreen, PointInStreetYellow, PointInBuild, PointInFondo] =...
    source_generator(u_f, Mesh, street, step_time, nele, TriStreetIndexRed, TriStreetIndexOrange, TriStreetIndexYellow, TriStreetIndexGreen,...
    TriBuildIndex, T_zero, par_T_zero_red_street, par_T_zero_orange_street, par_T_zero_yellow_street, par_T_zero_green_street, par_T_zero_building)

A = triarea(Mesh.xy',Mesh.ele(2:4,:)');

tic

for ip = 1:size(street.data,2)
    
    IndexPoinInStreetOrange = 1;
    IndexPoinInStreetGreen = 1;
    IndexPoinInStreetRed = 1;
    IndexPoinInStreetYellow = 1;
    IndexPointInFondo = 1;
    IndexPointInBuild = 1;
    
    if ismember( ip,step_time )
        
        for ie = 1:nele
            
            PointInStreetRed = zeros(1,nele);
            PointInStreetOrange = zeros(1,nele);
            PointInStreetYellow = zeros(1,nele);
            PointInStreetGreen = zeros(1,nele);
            PointInBuild = zeros(1,nele);
            PointInFondo = zeros(1,nele);
            
            if ismember(ie,TriStreetIndexRed) == 1
                
                f_red = emf_CO2(Mesh_Elements(1,ie),ip);
                
                u_f_e = ( f_red * A(ie) ) * [1 1 1]'/3;
                u_f (Mesh.ele(2:4,ie),ip) =  u_f_e;
                T_zero(Mesh_Elements(1,ie)) = par_T_zero_red_street;
                T_zero(Mesh_Elements(2,ie)) = par_T_zero_red_street;
                T_zero(Mesh_Elements(3,ie)) = par_T_zero_red_street;
                
                PointInStreetRed(IndexPoinInStreetRed) = Mesh.ele(2,ie);
                PointInStreetRed(IndexPoinInStreetRed+1) = Mesh.ele(3,ie);
                PointInStreetRed(IndexPoinInStreetRed+2) = Mesh.ele(4,ie);
                IndexPoinInStreetRed = IndexPoinInStreetRed + 3;
                
            elseif ismember(ie,TriStreetIndexOrange) == 1
                
                f_orange = emf_CO2(Mesh_Elements(1,ie),ip);
                
                u_f_e = ( f_orange * A(ie) ) * [1 1 1]'/3;
                u_f (Mesh.ele(2:4,ie),ip) =  u_f_e;
                T_zero(Mesh_Elements(1,ie)) = par_T_zero_orange_street;
                T_zero(Mesh_Elements(2,ie)) = par_T_zero_orange_street;
                T_zero(Mesh_Elements(3,ie)) = par_T_zero_orange_street;
                
                PointInStreetOrange(IndexPoinInStreetOrange) = Mesh.ele(2,ie);
                PointInStreetOrange(IndexPoinInStreetOrange+1) = Mesh.ele(3,ie);
                PointInStreetOrange(IndexPoinInStreetOrange+2) = Mesh.ele(4,ie);
                IndexPoinInStreetOrange = IndexPoinInStreetOrange + 3;
                
            elseif ismember(ie,TriStreetIndexYellow) == 1
                
                f_yellow = emf_CO2(Mesh_Elements(1,ie),ip);
                
                u_f_e = ( f_yellow * A(ie) ) * [1 1 1]'/3;
                u_f (Mesh.ele(2:4,ie),ip) =  u_f_e;
                T_zero(Mesh_Elements(1,ie)) = par_T_zero_yellow_street;
                T_zero(Mesh_Elements(2,ie)) = par_T_zero_yellow_street;
                T_zero(Mesh_Elements(3,ie)) = par_T_zero_yellow_street;
                
                
                PointInStreetYellow(IndexPoinInStreetYellow) = Mesh.ele(2,ie);
                PointInStreetYellow(IndexPoinInStreetYellow + 1) = Mesh.ele(3,ie);
                PointInStreetYellow(IndexPoinInStreetYellow + 2) = Mesh.ele(4,ie);
                IndexPoinInStreetYellow = IndexPoinInStreetYellow + 3;
                
                
            elseif ismember(ie,TriStreetIndexGreen) == 1
                
                f_green = emf_CO2(Mesh_Elements(1,ie),ip);
                
                u_f_e = ( f_green  * A(ie) ) * [1 1 1]'/3;
                u_f (Mesh.ele(2:4,ie),ip) =  u_f_e;
                T_zero(Mesh_Elements(1,ie)) = par_T_zero_green_street;
                T_zero(Mesh_Elements(2,ie)) = par_T_zero_green_street;
                T_zero(Mesh_Elements(3,ie)) = par_T_zero_green_street;
                
                
                PointInStreetGreen(IndexPoinInStreetGreen) = Mesh.ele(2,ie);
                PointInStreetGreen(IndexPoinInStreetGreen + 1) = Mesh.ele(3,ie);
                PointInStreetGreen(IndexPoinInStreetGreen + 2) = Mesh.ele(4,ie);
                IndexPoinInStreetGreen = IndexPoinInStreetGreen + 3;
                
            elseif ismember(ie,TriBuildIndex) == 1 && ismember(ie,TriFondoIndex) == 0
                
                T_zero(Mesh_Elements(1,ie)) = par_T_zero_building;
                T_zero(Mesh_Elements(2,ie)) = par_T_zero_building;
                T_zero(Mesh_Elements(3,ie)) = par_T_zero_building;
                PointInBuild(IndexPointInBuild) = Mesh.ele(2,ie);
                PointInBuild(IndexPointInBuild + 1) = Mesh.ele(3,ie);
                PointInBuild(IndexPointInBuild + 2) = Mesh.ele(4,ie);
                IndexPointInBuild = IndexPointInBuild + 3;
                
            else
                
                PointInFondo(IndexPointInFondo) = Mesh.ele(2,ie);
                PointInFondo(IndexPointInFondo + 1) = Mesh.ele(3,ie);
                PointInFondo(IndexPointInFondo + 2) = Mesh.ele(4,ie);
                IndexPointInFondo = IndexPointInFondo +3;
                
            end
        end
        
    else
        
        u_f(:,ip) = u_f(:,ip-1);
        
    end
end

toc

end

