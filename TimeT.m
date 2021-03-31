classdef TimeT < matlab.mixin.SetGet
    % class : TimeT
    %
    % description : contains objects for setting timing simulation properties
    %
    properties (SetAccess = private, GetAccess = public)
        dt TimeDiscretizationStep % simulation discrete time step : u.m. in *dt.unit_measure
        start double {mustBeNonnegative} = 0 % simulation start time : u.m. in *dt.unit_measure
        T double {mustBePositive} % simulation duration : u.m. in *dt.unit_measure
        
        ending double {mustBePositive} % simulation end time : u.m. in *dt.unit_measure
        times double {mustBeNonnegative} % simulation time vector : u.m. in *dt.unit_measure
        time_steps {mustBePositive, mustBeInteger} % simulation total steps
        unit_measure string = 'seconds'
    end
    
    methods
        function time(obj ,vals)
            props = {'T','dt'};
            obj.set(props, vals)
            obj.unit_measure=obj.dt.unit_measure;
        end
        
        function set_time(obj)
            obj.ending = obj.start + obj.T - obj.dt.value;
            obj.times = obj.start:obj.dt.value:obj.ending;
            obj.time_steps = round(obj.times/obj.dt.value+1);
            if ~ismember(length(obj.time_steps),length(obj.times))
                error('timing error')
            end
        end
    end
end