classdef Sensor < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        name string
        time TimeT
        x double
        y double
        ds DynamicSystem
        mesh Mesh
        %%
        state
        shapes double %{mustBeInRange(shapes,0,1)}
        elementBelonged {mustBePositive}
        elementNodeIndexes {mustBePositive}
        %%
        signalForm
    end
    
    methods
        
        function setProperties(obj, vals)
            props = {'name',...
                'time',...
                'x',...
                'y','mesh','ds'};
            obj.set(props, vals)
            %             obj.checkSensorPosition;
            obj.setSignalForm()
        end
        
        function obj = setSignalForm(obj)
            obj.initSignalForm()
            obj.getSensorShapes()
            obj.state = obj.ds.state;
            obj.signalForm = obj.shapes * obj.state(obj.elementNodeIndexes,:);
        end
        
        function checkSensorPosition(obj)
            if obj.x<0 || obj.x>obj.afems.afemm.range || obj.y>0 || obj.y<obj.afems.afemm.depth
                error('check the sensor position')
            end
        end
        
        function obj = initSignalForm(obj)
            obj.signalForm = zeros(1,length(obj.time.times));
        end
        
        function getSensorShapes(obj)
            for ie=1:obj.ds.mesh.element_size_number
                IN = inpolygon(obj.x, obj.y, obj.mesh.node_coordinates(1, [obj.mesh.elements(1:3,ie); obj.mesh.elements(1,ie)]),...
                    obj.mesh.node_coordinates(2, [obj.mesh.elements(1:3,ie); obj.mesh.elements(1,ie)]));
                ON = isPointOnPolyline([obj.x obj.y], obj.mesh.node_coordinates(:, [obj.mesh.elements(1:3,ie); obj.mesh.elements(1,ie)])', 1e-09);
                if (IN) || (ON)
                    obj.elementBelonged = ie;
                    obj.elementNodeIndexes = obj.mesh.elements(1:3,ie);
                    obj.shapes = getShapes(obj.ds.fem, obj.elementBelonged, [obj.x,...
                        obj.y] );
                end
            end
        end
        
        function viewSignalForm(obj,bool)
            if bool==true
                figure
                plot(1:length(obj.time.times), obj.signalForm(1:end),'-rx')
                tit = sprintf('%s signalform', obj.name);
                xlabel('time steps')
                title(tit)
            end
        end
    end
    
end