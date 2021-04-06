classdef Sources < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        name string
        roads Roads
        mesh Mesh
        fem FemModel
        coordinates string % NX2 array
        element_indexes {mustBeInteger}
        element_poly_length {mustBePositive}
        shapes double {mustBeInRange(shapes,0,1)}% (n_element_indexes)x(3)
    end
    
    methods
        function sources(obj ,vals)
            props = {'name','roads','mesh','fem','em_factor'};
            obj.set(props, vals)
            obj.set_element_indexes()
            obj.set_coordinates()
            obj.set_shapes()
        end
        
        function set_element_indexes(obj)
            i_e=1;
            for ib=1:size(obj.roads.elements_blocks,2)
                for ip=1:size(obj.roads.elements_blocks{ib},2)
                    for ie=1:size(obj.roads.elements_blocks{ib}{ip},2)
                        obj.element_indexes(i_e)=obj.roads.elements_blocks{ib}{ip}(ie);
                        obj.element_poly_length(i_e)=obj.roads.long_max{ib}{ip}(ie);
                        obj.element_poly_los(i_e)=obj.roads.list{ib}{ip}(ie);
                        % check
                        if true && obj.element_indexes(i_e)==0
                            error('element indexes must be positive')
                        end
                        i_e=i_e+1;
                    end
                end
            end
        end
        
        function set_coordinates(obj)
            obj.coordinates=obj.mesh.element_centroids(obj.element_indexes,:);
        end
        
        function set_shapes(obj)
            for ie=1:length(obj.element_indexes)
                obj.shapes(ie,:)=getShapes(obj.fem,obj.element_indexes(ie),[str2double(obj.coordinates(ie,1)),...
                    str2double(obj.coordinates(ie,2))] );
            end
        end
        
        function plot_sources(obj,bool)
            if bool
                figure
                plot(str2double(obj.coordinates(:,1)),str2double(obj.coordinates(:,2)),'ro')
                title('source coords')
            end
        end
    end
end