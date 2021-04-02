classdef Roads < Structures
    properties (SetAccess = private, GetAccess = public)
        list cell % list containing RGB info of each element of roads
    end
    methods
        function set_rgb_list(obj,val)
            prop={'list'};
            obj.set(prop,val)
        end
    end
end