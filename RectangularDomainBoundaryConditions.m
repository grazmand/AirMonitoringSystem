classdef RectangularDomainBoundaryConditions < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        %% basics
        scenario Scenario
        mesh RectangularDomainMesh
        %%
        boundary_counterclockwiseNodeIndexes double
        radiation RectangularDomainBoundaryCondition
        dirichlet RectangularDomainBoundaryCondition
        neumann RectangularDomainBoundaryCondition
    end
    
    methods
        function boundary_conditions(obj, vals)
            props = {'scenario','mesh'};
            obj.set(props, vals)
            obj.set_boundary_conditions()
            obj.mesh.set_boundary_conditions({obj})
            obj.mesh.setInternalNodes()
            obj.mesh.set_boundary_element_indexes()
            obj.mesh.set_boundary_internal_node_cell_indexes()
            obj.mesh.set_boundary_internal_node_array_indexes()
        end
        
        function set_boundary_conditions(obj)
            if ismember(obj.scenario.boundary_condition, 'dirichlet')
                obj.dirichlet = RectangularDomainBoundaryCondition;
                obj.dirichlet.boundary_condition({'dirichlet',obj.mesh,obj.scenario})
            elseif ismember(obj.scenario.boundary_condition, 'neumann')
                obj.neumann = RectangularDomainBoundaryCondition;
                obj.neumann.boundary_condition({'neumann',obj.mesh,obj.scenario})
            end
            if ismember('dirichlet',obj.scenario.boundary_condition)
                obj.dirichlet.set_boundary_condition_nodes;
            elseif ismember('neumann',obj.scenario.boundary_condition)
                obj.neumann.set_boundary_condition_nodes;
            end
        end
        
        function checkBoundaryConditions(obj,bool)
            if bool==true
                figure
                hold on
                
                if ~isempty(obj.dirichlet)
                    plot(obj.dirichlet.counterclockwiseNodeCoordinates(1,:),obj.dirichlet.counterclockwiseNodeCoordinates(2,:),'-ro','DisplayName','dirichlet',...
                        'LineWidth',0.5,'MarkerSize',3);
                end
                if ~isempty(obj.neumann)
                    plot(obj.neumann.counterclockwiseNodeCoordinates(1,:),obj.neumann.counterclockwiseNodeCoordinates(2,:),'go','DisplayName','neumann');
                end
                legend('-DynamicLegend')
                axes = gca;
                set(axes,'FontWeight','bold')
                xlabel('latitude','FontWeight','bold')
                ylabel('longitude','FontWeight','bold')
                title('boundary conditions')
                grid on
            end
        end
    end
end