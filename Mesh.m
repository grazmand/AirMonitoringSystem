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
        boundary_element_indexes {mustBeInteger}
        boundary_neighbor_element_indexes {mustBeInteger}
        boundary_internal_node_indexes {mustBeInteger}
        %% internal nodes
        allNodesExceptDirichletNodes_indexes {mustBeInteger}
        allNodesExceptDirichletNodes_coordinates double
        allNodesExceptDirichletNodes_size {mustBeInteger}
        %% element centroids
        element_centroids
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
        
        %% bc method
        function set_boundary_conditions(obj, vals)
            props = {'bc','boundary_counterclockwiseNodeIndexes'};
            obj.set(props, vals)
            obj.setBoundaries()
        end
        
        %% internal nodes methods
        function setInternalNodes(obj)
            if ~isempty(obj.bc)
                obj.set('allNodesExceptDirichletNodes_indexes', setdiff(1:obj.node_size_number, obj.bc.dirichlet.counterclockwiseNodeIndexes));
                obj.set('allNodesExceptDirichletNodes_size', length(obj.allNodesExceptDirichletNodes_indexes));
                obj.set('allNodesExceptDirichletNodes_coordinates', obj.node_coordinates(:,obj.allNodesExceptDirichletNodes_indexes));
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
            obj.set_node_size_number()
            obj.set_element_size_number()
            obj.set_element_centroids()
            
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
        
        %% element centroid
        function set_element_centroids(obj)
            obj.element_centroids = zeros(obj.element_size_number,2);
            for ie=1:obj.element_size_number
                [obj.element_centroids(ie,1),obj.element_centroids(ie,2)] = FemTools.computeCentroid(obj.node_coordinates(1, obj.elements(1,ie)),obj.node_coordinates(1, obj.elements(2,ie)),obj.node_coordinates(1, obj.elements(3,ie)),...
                    obj.node_coordinates(2, obj.elements(1,ie)), obj.node_coordinates(2, obj.elements(2,ie)), obj.node_coordinates(2, obj.elements(3,ie)));
            end
        end
        
        %% boundary elements
        function set_boundary_element_indexes(obj)
            index=1;
            for in=obj.bc.boundary_counterclockwiseNodeIndexes
                for ie=1:obj.element_size_number
                    if ismember(in,obj.elements(:,ie))
                        if ~ismember(ie,obj.boundary_element_indexes)
                            obj.boundary_element_indexes(index)=ie;
                            index=index+1;
                        end
                    end
                end
            end
        end
        
        function set_boundary_neighbor_element_indexes(obj)
            T=obj.elements;
            TL=obj.boundary_element_indexes;
            NTL=pdeent(T,TL);
            obj.boundary_neighbor_element_indexes=NTL;
        end
        
        function set_boundary_internal_node_indexes(obj)
            index=1;
            for ie=obj.boundary_element_indexes
            end
        end
    end
end