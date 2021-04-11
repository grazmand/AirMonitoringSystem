classdef ForceTerm < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        %% basics
        name string
        time TimeT
        mesh Mesh
        %% derivative
        force_term double
        k_frames {mustBeInteger}
    end
    properties (Constant)
        frames double=[1 13]
    end
    methods
        function forceTerm(obj, vals)
            props = {'name','sources','time','mesh'};
            obj.set(props, vals)
            obj.set_k_frames()
            obj.setForceTerm()
        end
        function initForceTerm(obj)
            obj.force_term = zeros(obj.mesh.node_size_number,obj.time.time_steps(end));
        end
        function set_k_frames(obj)
            obj.k_frames=obj.frames*3*60*obj.time.dt.value^-1;
        end
    end
end