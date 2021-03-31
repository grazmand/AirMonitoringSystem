classdef TimeDiscretizationStep  < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        unit_measure string = 'seconds'
        value double {mustBePositive} = 0.01
    end
    
    methods
        function time_discretization_step(obj ,vals)
            props = {'value'};
            obj.set(props, vals)
        end
    end
    
end