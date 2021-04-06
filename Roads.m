classdef Roads < Structures
    properties (SetAccess = private, GetAccess = public)
        list cell % list containing RGB info of each element of roads
        long_max cell
    end
    methods
        function set_rgb_list(obj,val)
            prop={'list'};
            obj.set(prop,val)
        end
        function set_long_max(obj,val)
            prop={'long_max'};
            obj.set(prop,val)
        end
    end
end