classdef FemTools < matlab.mixin.SetGet
    methods (Static)
        function [nodes, elements] = find_elements_in_polygon(mesh, polygon)
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % INPUTS
            % mesh : object of class Mesh
            % polygon : object of type geometry description column vector
            % 10x1
            %
            %
            % OUTPUTS
            %
            %
            %
            i_nodes = 1;
            nodes=zeros(1,1);
            i_elements = 1;
            elements=zeros(1,1);
            XV = polygon(3:6);
            YV = polygon(7:10);
            POLY = [XV YV];
            for ie=1:mesh.element_size_number
                for v=1:3
                    %% compute nodes
                    if ~ismember(mesh.elements(v,ie),nodes)
                        X = mesh.node_coordinates(1,mesh.elements(v,ie));
                        Y = mesh.node_coordinates(2,mesh.elements(v,ie));
                        IN = inpolygon(X,Y,XV,YV);
                        ON = isPointOnPolyline([X Y],POLY);
                        if (IN) || (ON)
                            nodes(i_nodes)=mesh.elements(v,ie);
                            i_nodes=i_nodes+1;
                        end
                    end
                end
                %% compute elements
                if ~ismember(ie,elements)
                    X = mesh.element_centroids(ie,1);
                    Y = mesh.element_centroids(ie,2);
                    IN = inpolygon(X,Y,XV,YV);
                    ON = isPointOnPolyline([X Y],POLY);
                    if (IN) || (ON)
                        elements(i_elements)=ie;
                        i_elements=i_elements+1;
                    end
                end
            end
        end
        function [xc,yc] = computeCentroid(x1,x2,x3,...
                y1,y2,y3)
            xc = (x1+x2+x3)/3;
            yc = (y1+y2+y3)/3;
        end
    end
end