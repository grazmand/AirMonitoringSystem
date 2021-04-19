classdef ForceTerm < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        %% basics
        name string
        time TimeT
        mesh Mesh
        corr double
        %% derivative
        k_frames {mustBeInteger}
        force_term double
        timed_element_em_rates double
    end
    properties (Constant)
        i_frames {mustBeInteger}=13 % frame indexes corresponding to the traffic changes
    end
    methods
        function forceTerm(obj, vals)
            props = {'name','time','mesh','corr'};
            obj.set(props, vals)
            obj.set_k_frames()
            obj.set_timed_element_em_rates()
            obj.initForceTerm()
        end
        function set_k_frames(obj)
            obj.k_frames=round(obj.i_frames*3*60*obj.time.dt.value^-1);
        end
        function initForceTerm(obj)
            obj.force_term = zeros(obj.mesh.node_size_number,obj.time.time_steps(end));
        end
        function set_timed_element_em_rates(obj)
            % conv. emission rate from g*veh./m^3*sec. to
            % g*veh./m^3*sec.*dt^-1
            obj.timed_element_em_rates=obj.sources.element_em_rates*obj.time.dt.value;
        end
    end
end