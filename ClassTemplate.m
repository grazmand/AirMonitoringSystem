classdef ClassTemplate < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
    end
    
    methods
        function setProperties(obj ,vals)
            props = {'','','',''};
            obj.set(props, vals)
        end
    end
    
end