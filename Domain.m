%Class Domain

classdef Domain < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        coordinates double % must be NX2 matrix, where N : number of points,
        % the 2 columns contain the x and y coordinates of the points
        n_points
    end
    
    methods
        function domain(obj, vals)
            props = {'n_points','coordinates'};
            obj.set(props, vals);
            obj.n_points = size(obj.coordinates,1);
        end
        
        function check_coordiantes_size(obj)
            if size(obj.coordinates,1)~=obj.n_points || size(obj.coordinates,2)~=2
                error('check coordinates object size')
            end
        end
    end
end