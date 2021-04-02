%Class Medium

classdef Medium < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        diffusion {mustBePositive} = 1e-5
    end
    
    methods
        function medium(obj, vals)
            props = {'diffusion'};
            obj.set(props, vals)
        end
    end
    
end