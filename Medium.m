%Class Medium

classdef Medium < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        diffusion {mustBeNonnegative}
        advection_vector double % must be 2x1 array, where the first element represents the
        % x_axys wind speed and the second the y_axis wind speed
    end
    
    methods
        function medium(obj, vals)
            props = {'diffusion','advection_vector'};
            obj.set(props, vals)
        end
    end
    
end