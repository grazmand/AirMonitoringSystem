%% Class Mesh

classdef Mesh < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        %% geometry properties
        name string
        element_length {mustBePositive}
        domain Domain
        node_coordinates double
        edges double
        elements double
        node_size_number {mustBePositive}
        element_size_number {mustBePositive}
        %% bc properties
        boundary_counterclockwiseNodeIndexes {mustBeInteger}
        boundary_counterclockwiseNodeCoordinates double
        bc BoundaryConditions
        %% internal nodes
        allNodesExceptDirichletNodes_indexes {mustBeInteger}
        allNodesExceptDirichletNodes_coordinates double
        allNodesExceptDirichletNodes_size {mustBeInteger}
    end
    
    methods
        %% boundary methods       
        function setCounterclockwiseBoundaryNodeCoordinates(obj)
            if ~isempty(obj.boundary_counterclockwiseNodeIndexes)
                obj.set('boundary_counterclockwiseNodeCoordinates', obj.node_coordinates(:,obj.boundary_counterclockwiseNodeIndexes));
            end
        end
        
        function setBoundaries(obj)
            obj.setCounterclockwiseBoundaryNodeCoordinates();
        end
        
        function checkBoundaries(obj,bool)
            if bool
                figure
                hold on
                plot(obj.s1_counterclockwiseNodeCoordinates(1,:),...
                    obj.s1_counterclockwiseNodeCoordinates(2,:),'bo',...
                    'MarkerSize',10)
                plot(obj.s2_counterclockwiseNodeCoordinates(1,:),...
                    obj.s2_counterclockwiseNodeCoordinates(2,:),'go')
                plot(obj.s3_counterclockwiseNodeCoordinates(1,:),...
                    obj.s3_counterclockwiseNodeCoordinates(2,:),'ro',...
                    'MarkerSize',10)
                plot(obj.s4_counterclockwiseNodeCoordinates(1,:),...
                    obj.s4_counterclockwiseNodeCoordinates(2,:),'yo')
                legend('s1','s2','s3','s4')
                title('Boundaries')
            end
        end
        
        %% bc methods
        function set_boundary_conditions(obj, vals)
            props = {'bc','boundary_counterclockwiseNodeIndexes'};
            obj.set(props, vals)
            obj.setBoundaries()
        end
        
        %% internal nodes methods
        function setInternalNodes(obj)
            if ~isempty(obj.bc)
                obj.set('allNodesExceptDirichletNodes_indexes', setdiff(1:obj.nodeSizeNumber, obj.bc.dirichlet.counterclockwiseNodeIndexes));
                obj.set('allNodesExceptDirichletNodes_size', length(obj.allNodesExceptDirichletNodes_indexes));
                obj.set('allNodesExceptDirichletNodes_coordinates', obj.nodeCoordinates(:,obj.allNodesExceptDirichletNodes_indexes));
            elseif isempty(obj.bc)
                error('boundary conditions missing');
            end
        end
        
        %% mesh methods
        function  mesh(obj, vals)
            props = {'name', 'element_length', 'domain'};
            obj.set(props, vals)
            [nd,ed,el] = initmesh(obj.domain.decomposed_geometry,...
                'Hmax',...
                obj.element_length,'Hgrad',1.999);
            obj.set('node_coordinates',nd)
            obj.set('edges',ed)
            obj.set('elements',el)
            obj.set_node_size_number
            obj.set_element_size_number
            
            % plot mesh properties
            fprintf('----------------------------------------- \n');
            fprintf('%s res. = %d m \n',obj.name,obj.element_length);
            fprintf('%s size (elements) = %d \n',obj.name,obj.element_size_number);
            fprintf('%s size (nodes) = %d \n',obj.name,obj.node_size_number);
            fprintf('----------------------------------------- \n');
        end
        
        function set_node_size_number(obj)
            obj.set('node_size_number',size(obj.node_coordinates,2));
        end
        
        function set_element_size_number(obj)
            obj.set('element_size_number',size(obj.elements,2));
            if obj.element_size_number>=60000
                error('mesh dimension exceed the maximum size available')
            end
        end
        
        %% plot mesh
        function plot_mesh(obj, bool)
            if bool
                figure
                pdeplot(obj.node_coordinates,obj.edges,obj.elements); %,'ElementLabels','on'); % add ",'NodeLabels','on');" if you want the node labels to be shown ('computational expensive in terms of gpu')
                title(sprintf('mesh "%s" -- res.=%0.1d, eln=%d, nn=%d'...
                    ,obj.name,obj.element_length, obj.element_size_number, obj.node_size_number))
                axes = gca;
                set(axes,'FontWeight','bold')
                xlabel('latitude','FontWeight','bold')
                ylabel('longitude','FontWeight','bold')
                legend()
                grid on
            end
        end
    end
end