classdef BoundaryConditions < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        %% basics
        scenario Scenario
        mesh Mesh
        %%
        radiation BoundaryCondition
        dirichlet BoundaryCondition
        neumann BoundaryCondition
    end
    
    methods
        function boundary_conditions(obj, vals)
            props = {'scenario','mesh'};
            obj.set(props, vals);
            obj.mesh.set_boundary_conditions({obj})
            obj.set_boundary_conditions;
        end
        
        function obj = set_boundary_conditions(obj)
            if ismember(obj.scenario.boundary_condition, 'radiation')
                obj.radiation = BoundaryCondition;
                obj.radiation.boundary_condition({'radiation',obj.mesh,obj.scenario})
            elseif ismember(obj.scenario.boundary_condition, 'dirichlet')
                obj.dirichlet = BoundaryCondition;
                obj.dirichlet.boundary_condition({'dirichlet',obj.mesh,obj.scenario})
            elseif ismember(obj.scenario.boundary_condition, 'neumann')
                obj.neumann = BoundaryCondition;
                obj.neumann.boundary_condition({'neumann',obj.mesh,obj.scenario})
            end
            
            if ismember('radiation',obj.scenario.boundary_condition)
                obj.radiation.set_boundary_condition_nodes;
            elseif ismember('dirichlet',obj.scenario.boundary_condition)
                obj.dirichlet.set_boundary_condition_nodes;
            elseif ismember('neumann',obj.scenario.boundary_condition)
                obj.neumann.set_boundary_condition_nodes;
            end
        end
        
        function checkBoundaryConditions(obj,bool)
            if bool==true
                figure
                hold on
                if ~isempty(obj.radiation)
                    plot(obj.radiation.counterclockwiseNodeCoordinates(1,:),obj.radiation.counterclockwiseNodeCoordinates(2,:),'bo','DisplayName','radiation');
                end
                if ~isempty(obj.dirichlet)
                    plot(obj.dirichlet.counterclockwiseNodeCoordinates(1,:),obj.dirichlet.counterclockwiseNodeCoordinates(2,:),'ro','DisplayName','dirichlet');
                end
                if ~isempty(obj.neumann)
                    plot(obj.neumann.counterclockwiseNodeCoordinates(1,:),obj.neumann.counterclockwiseNodeCoordinates(2,:),'go','DisplayName','neumann');
                end
                legend('-DynamicLegend')
            end
        end
    end
end