%SuperClass Domain

classdef RectangularDomain < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        x_min double
        x_max double
        y_min double
        y_max double
        coordinates double
        load_geometry=false;
        geometry double
        decomposed_geometry double
    end
    
    methods
        function rec_domain(obj, vals)
            props = {'x_min', 'x_max',...
                'y_min','y_max'};
            obj.set(props, vals)
            obj.set_geometry()
            obj.set_coordinates()
            obj.set_decomposed_geometry()
        end
        
        function set_geometry(obj)
            if obj.load_geometry
                error('insert geometry path')
            else
                % For a rectangle, the first row contains 3, and the second row contains 4.
                % The next four rows contain the x-coordinates of the starting points of the edges,
                % and the four rows after that contain the y-coordinates of the starting points of the edges.
                g = [3,4,...
                    obj.x_min,obj.x_max,...
                    obj.x_max,obj.x_min,...
                    obj.y_min,obj.y_min,...
                    obj.y_max,obj.y_max]';
                
                obj.set('geometry', g);
            end
        end
        
        function set_coordinates(obj)
            x=[obj.x_min;obj.x_max;obj.x_max;obj.x_min];
            y=[obj.y_min;obj.y_min;obj.y_max;obj.y_max];
            obj.set('coordinates',[x y])
        end
        
        function set_decomposed_geometry(obj)
            dg = decsg(obj.geometry);
            obj.set('decomposed_geometry',dg);
        end
        
        function plot_domain(obj, bool)
            if bool
                figure
                plot(obj.coordinates(:,1),...
                    obj.coordinates(:,2), 'ro','MarkerSize',3,'DisplayName','coordinates')
                axes = gca;
                set(axes,'FontWeight','bold')
                xlabel('x_{axis} [m]','FontWeight','bold')
                ylabel('y_{axis} [m]','FontWeight','bold')
                title('domain')
                grid on
                legend()
            end
        end
    end
end