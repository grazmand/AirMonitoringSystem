classdef ForceTerm < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        %% basics
        name string
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
    end
end