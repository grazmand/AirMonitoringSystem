classdef Scenario < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        boundary_condition string
    end
    
    methods
        function scenario(obj, vals)
            props={'boundary_condition'};
            obj.set(props,vals)
        end
    end
    
end