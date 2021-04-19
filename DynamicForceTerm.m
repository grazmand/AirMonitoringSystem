classdef DynamicForceTerm<ForceTerm
    properties (SetAccess=private,GetAccess=public)
        k {mustBeInteger}
    end
    methods
        function set_k(obj,val)
            prop={'k'};
            obj.set(prop,val)
        end
    end
end