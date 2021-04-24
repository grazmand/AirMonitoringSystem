%% Class Mesh
% The mesh data for a 2-D mesh has these components:
%
% p (points, the mesh nodes) is a 2-by-Np matrix of nodes,
% where Np is the number of nodes in the mesh. Each column p(:,k)
% consists of the x-coordinate of point k in p(1,k) and the y-coordinate of point k in p(2,k).
%
% e (edges) is a 7-by-Ne matrix of edges, where Ne is the number of edges in the mesh.
% The mesh edges in e and the edges of the geometry have a one-to-one correspondence. The e matrix represents the discrete edges of the geometry in the same manner as the t matrix represents the discrete faces. Each column in the e matrix represents one edge.
%
% e(1,k) is the index of the first point in mesh edge k.
%
% e(2,k) is the index of the second point in mesh edge k.
%
% e(3,k) is the parameter value at the first point of edge k.
% The parameter value is related to the arc length along the geometric edge.
%
% e(4,k) is the parameter value at the second point of edge k.
%
% e(5,k) is the ID of the geometric edge containing the mesh edge.
% You can see edge IDs by using the command pdegplot(geom,'EdgeLabels','on').
%
% e(6,k) is the subdomain number on the left side of the edge.
% The direction along the edge is given by increasing parameter values. The subdomain 0 is the exterior of the geometry.
%
% e(7,k) is the subdomain number on the right side of the edge.
%
% t (triangles) is a 4-by-Nt matrix of triangles or a 7-by-Nt matrix of triangles, depending on
% whether you call generateMesh with the GeometricOrder name-value pair set to
% 'quadratic' or 'linear', respectively. initmesh creates only 'linear' elements,
% which have size 4-by-Nt. Nt is the number of triangles in the mesh.
% Each column of t contains the indices of the points in p that form the triangle.
% The exception is the last entry in the column, which is the subdomain number.
% Triangle points are ordered as shown.

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
        boundary_internal_node_cell_indexes cell
        boundary_internal_node_array_indexes {mustBeInteger}
        %% internal nodes
        allNodesExceptDirichletNodes_indexes {mustBeInteger}
        allNodesExceptDirichletNodes_coordinates double
        allNodesExceptDirichletNodes_size {mustBeInteger}
        %% element centroids
        element_centroids
    end
    
    methods
        
        %% mesh methods
        function  mesh(obj, vals)
            props = {'name', 'element_length', 'domain'};
            obj.set(props, vals)
            [nd,ed,el] = initmesh(obj.domain.decomposed_geometry,...
                'Hmax',...
                obj.element_length,'Hgrad',1.999);
            % convert mdeg in meters
            nd=nd*110;
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
        
        % element centroid
        function set_element_centroids(obj)
            obj.element_centroids = zeros(obj.element_size_number,2);
            for ie=1:obj.element_size_number
                [obj.element_centroids(ie,1),obj.element_centroids(ie,2)] = FemTools.computeCentroid(obj.node_coordinates(1, obj.elements(1,ie)),obj.node_coordinates(1, obj.elements(2,ie)),obj.node_coordinates(1, obj.elements(3,ie)),...
                    obj.node_coordinates(2, obj.elements(1,ie)), obj.node_coordinates(2, obj.elements(2,ie)), obj.node_coordinates(2, obj.elements(3,ie)));
            end
        end
        
        % boundaries
        function set_boundary_counterclockwiseNodeIndexes(obj,bci)
            % obj.boundary_counterclockwiseNodeIndexes=obj.edges(1,:);
            obj.set({'boundary_counterclockwiseNodeIndexes'},bci)
        end
        
        function setCounterclockwiseBoundaryNodeCoordinates(obj)
            if ~isempty(obj.boundary_counterclockwiseNodeIndexes)
                obj.set('boundary_counterclockwiseNodeCoordinates', obj.node_coordinates(:,obj.boundary_counterclockwiseNodeIndexes));
            end
        end
        
        function set_boundaries(obj,bci)
            % boundaries
            obj.set_boundary_counterclockwiseNodeIndexes(bci)
            obj.setCounterclockwiseBoundaryNodeCoordinates()
        end
        
        %% bc method
        function set_boundary_conditions(obj, vals)
            props = {'bc'};
            obj.set(props, vals)
        end
        
        %% internal nodes methods
        function setInternalNodes(obj)
            if ~isempty(obj.bc) && ~isempty(obj.bc.dirichlet)
                obj.set('allNodesExceptDirichletNodes_indexes', setdiff(1:obj.node_size_number, obj.bc.dirichlet.counterclockwiseNodeIndexes));
                obj.set('allNodesExceptDirichletNodes_size', length(obj.allNodesExceptDirichletNodes_indexes));
                obj.set('allNodesExceptDirichletNodes_coordinates', obj.node_coordinates(:,obj.allNodesExceptDirichletNodes_indexes));
            elseif ~isempty(obj.bc) && isempty(obj.bc.dirichlet)
                obj.set('allNodesExceptDirichletNodes_indexes',1:obj.node_size_number);
                obj.set('allNodesExceptDirichletNodes_size', length(obj.allNodesExceptDirichletNodes_indexes));
                obj.set('allNodesExceptDirichletNodes_coordinates', obj.node_coordinates(:,obj.allNodesExceptDirichletNodes_indexes));
            elseif isempty(obj.bc)
                error('boundary conditions missing');
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
                xlabel('latitude [m]','FontWeight','bold')
                ylabel('longitude [m]','FontWeight','bold')
                legend('elements','roads and boundaries')
                grid on
            end
        end
        
        %% boundary elements
        function set_boundary_element_indexes(obj)
            index=1;
            iter=obj.bc.boundary_counterclockwiseNodeIndexes;
            for in=1:length(iter)
                for ie=1:obj.element_size_number
                    if ismember(iter(in),obj.elements(1:3,ie))
                        if ~ismember(ie,obj.boundary_element_indexes)
                            obj.boundary_element_indexes(index)=ie;
                            index=index+1;
                        end
                    end
                end
            end
        end
        
        function set_boundary_internal_node_cell_indexes(obj)
            index1=1;
            for ie=obj.boundary_element_indexes
                index2=1;
                for v=1:3
                    if ~ismember(obj.elements(v,ie),obj.bc.boundary_counterclockwiseNodeIndexes)
                        obj.boundary_internal_node_cell_indexes{index1}{index2}=obj.elements(v,ie);
                        index2=index2+1;
                    end
                end
                index1=index1+1;
            end
            % check
            if ~ismember(size(obj.boundary_internal_node_cell_indexes,2),length(obj.boundary_element_indexes))
                error('array size do not match')
            end
        end
        
        function set_boundary_internal_node_array_indexes(obj)
            index=1;
            length1=size(obj.boundary_internal_node_cell_indexes,2);
            for i=1:length1
                length2=size(obj.boundary_internal_node_cell_indexes{i},2);
                for in=1:length2
                    if ~ismember(obj.boundary_internal_node_cell_indexes{i}{in},obj.boundary_internal_node_array_indexes)
                        obj.boundary_internal_node_array_indexes(index)=obj.boundary_internal_node_cell_indexes{i}{in};
                        index=index+1;
                    end
                end
            end
        end
    end
end