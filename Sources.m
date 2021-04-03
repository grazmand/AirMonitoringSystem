classdef Sources < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        name string
        roads Roads
        mesh Mesh
        fem FemModel
        coordinates string % NX2 array
        element_indexes {mustBeInteger}
        em_factor double = 0.1
        shapes double
    end
    
    methods
        function sources(obj ,vals)
            props = {'name','roads','mesh','fem'};
            obj.set(props, vals)
            obj.set_element_indexes()
            obj.set_coordinates()
            obj.set_shapes()
        end
        
        function set_element_indexes(obj)
            i_e=1;
            for ib=1:size(obj.roads.element_blocks,2)
                for ip=1:size(obj.roads.element_blocks{ib},2)
                    for ie=1:size(obj.roads.element_blocks{ib}{ip},2)
                        obj.element_indexes(i_e)=obj.roads.element_blocks{ib}{ip}(i_e);
                        i_e=i_e+1;
                    end
                end
            end
        end
        
        function set_coordinates(obj)
            obj.coordinates=obj.mesh.element_centroids(obj.element_indexes,:);
        end
        
        function set_shapes(obj)
            obj.shapes(obj.element_indexes,:)=getShapes(obj.afemm.femModel, obj.elementBelonged(k), [obj.cm.state(1,k),...
                obj.cm.state(3,k)] );
        end
    end
end