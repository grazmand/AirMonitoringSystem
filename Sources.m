classdef Sources < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        roads Roads
        coordinates string % NX2 array
        element_indexes {mustBeInteger}
        em_factor double = 0.1
    end
    
    methods
        function source(obj ,vals)
            props = {'roads'};
            obj.set(props, vals)
        end
        
        function set_element_indexes(obj)
            ie=1;
            for ib=1:size(obj.roads.blocks,2)
                for ip=1:size(obj.roads.blocks{ib},2)
                    element_indexes(ie)=obj.roads.
                end
            end
        end
    end
end