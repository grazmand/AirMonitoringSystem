classdef ForceTerm < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        %% basics
        name string
        sources Sources
        time TimeT 
        mesh Mesh
        %% derivative
        force_term double
    end
    
    methods
        function forceTerm(obj, vals)
            props = {'name','sources','time','mesh'};
            obj.set(props, vals)
            obj.setForceTerm()
        end
        
        function initForceTerm(obj)
            obj.force_term = zeros(obj.mesh.node_size_number,obj.time.time_steps(end));
        end
        
        function setForceTerm(obj)
            obj.initForceTerm()
            index=1;
            for ie=obj.sources.element_indexes
                nodes=obj.mesh.elements(1:3,ie);
                obj.force_term(nodes,:) = obj.force_term(nodes,:) + obj.sources.em_factor * obj.sources.shapes(index,:)';
                index=index+1;
            end
        end
    end
end