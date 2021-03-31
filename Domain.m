%Class Domain

classdef Domain < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        name string
        coordinates double % must be NX2 matrix, where N : number of points,
        % the 2 columns contain the x and y coordinates of the points
        n_points
        decomposed_geometry double
    end
    
    methods
        function domain(obj, vals)
            props = {'name','coordinates','decomposed_geometry'};
            obj.set(props, vals);
            obj.n_points = size(obj.coordinates,1);
            obj.check_coordiantes_size;
        end
        
        function check_coordiantes_size(obj)
            if size(obj.coordinates,1)~=obj.n_points || size(obj.coordinates,2)~=2
                error('check coordinates object size')
            end
        end
        
        function plot_domain(obj, bool)
            if bool
                figure
                plot(obj.coordinates(:,1),...
                    obj.coordinates(:,2), 'ro','MarkerSize',3,'DisplayName','coordinates')
                axes = gca;
                set(axes,'FontWeight','bold')
                xlabel('latitude','FontWeight','bold')
                ylabel('longitude','FontWeight','bold')
                title('domain')
                grid on
                legend()
            end
        end
    end
end