classdef ForceTerm < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        %% basics
        name string
        sources Sources
        time Time
        %% derivative
        force_term double
    end
    
    methods
        function forceTerm(obj, vals)
            props = {'name','sources','time'};
            obj.set(props, vals)
            obj.setForceTerm()
        end
        
        function initForceTerm(obj)
            obj.force_term = zeros(obj.mesh.node_size_number,obj.time.time_steps);
        end
        
        function setForceTerm(obj)
            obj.initForceTerm()
            obj.force_term(obj.sources.elementNodeIndexes,:) = obj.sources.em_factor .* obj.sources.shapes;
        end
    end
end