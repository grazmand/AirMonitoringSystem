classdef ForceTerm < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        %% basics
        name string
        time TimeT
        mesh Mesh
        %% derivative
        k_frames {mustBeInteger}
    end
    properties (Constant)
        i_frames double=[13] % frame indexes corresponding to when the traffic changes
    end
    methods
        function forceTerm(obj, vals)
            props = {'name','time','mesh'};
            obj.set(props, vals)
            obj.set_k_frames()
        end
        function set_k_frames(obj)
            obj.k_frames=round(obj.i_frames*3*60*obj.time.dt.value^-1);
        end
    end
end