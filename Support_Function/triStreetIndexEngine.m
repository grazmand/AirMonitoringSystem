function [TriStreetIndex,TriStreetIndexRed,TriStreetIndexOrange,TriStreetIndexYellow,TriStreetIndexGreen] =...
    triStreetIndexEngine(poly,Mesh_Nodes,Mesh_Elements,List,time,data_folder)

%% support indices
IndexStreet = 1;
IndexStreetYellow = 1;
IndexStreetGreen = 1;
IndexStreetRed = 1;
IndexStreetOrange = 1;

%% initialization of the street indices
TriStreetIndex = [];
TriStreetIndexYellow = [];
TriStreetIndexRed = [];
TriStreetIndexGreen = [];
TriStreetIndexOrange = [];

pp = Mesh_Nodes;
tt = Mesh_Elements;

for npoly = 1:size(poly,2)
    for nstreetinpoly = 1:size(poly{npoly},2)
        for ie = 1:size(Mesh_Elements,2)
            
            [InPoly,OnPoly] = inpolygon([pp(1,tt(1,ie)) pp(1,tt(2,ie)) pp(1,tt(3,ie))],...
                [pp(2,tt(1,ie)) pp(2,tt(2,ie)) pp(2,tt(3,ie))],poly{npoly}(3:2+poly{npoly}(2,nstreetinpoly),nstreetinpoly),...
                poly{npoly}(3+poly{npoly}(2,nstreetinpoly):size(poly{npoly},1),nstreetinpoly));
            
            if (OnPoly(1) == 1 || InPoly(1) == 1) &&...
                    (OnPoly(2) == 1 || InPoly(2) == 1)&&...
                    (OnPoly(3) == 1 || InPoly(3) == 1)
                
                TriStreetIndex(IndexStreet) = ie;
                IndexStreet = IndexStreet + 1;
                
                if List{time}{npoly}(nstreetinpoly,:) == [255 255 0] %#ok
                    TriStreetIndexYellow(IndexStreetYellow) = ie;
                    IndexStreetYellow = IndexStreetYellow + 1;
                    
                elseif List{time}{npoly}(nstreetinpoly,:) == [255 170 0] %#ok
                    TriStreetIndexOrange(IndexStreetOrange) = ie;
                    IndexStreetOrange = IndexStreetOrange + 1;
                    
                elseif List{time}{npoly}(nstreetinpoly,:) == [200 0 0] %#ok
                    TriStreetIndexRed(IndexStreetRed) = ie;
                    IndexStreetRed = IndexStreetRed + 1;
                    
                elseif (List{time}{npoly}(nstreetinpoly,:) == [215 0 0]) | (List{time}{npoly}(nstreetinpoly,:) == [23 177 23]) %#ok
                    TriStreetIndexGreen(IndexStreetGreen) = ie;
                    IndexStreetGreen = IndexStreetGreen+1;
                end
            end
            
        end
    end
end

save(fullfile(data_folder,'tri.mat'),'TriStreetIndex','TriStreetIndexRed','TriStreetIndexOrange','TriStreetIndexYellow','TriStreetIndexGreen');

end

