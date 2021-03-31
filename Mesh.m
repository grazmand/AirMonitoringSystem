%% Class Mesh

classdef Mesh < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        %% geometry properties
        name string
        elementLength {mustBePositive}
        node_coordinates double
        edges double
        elements double
        node_size_number {mustBePositive}
        element_size_number {mustBePositive}    
        %% bc properties
        bc BoundaryConditions
        %% internal nodes
        allNodesExceptDirichletNodes_indexes
        allNodesExceptDirichletNodes_coordinates
        allNodesExceptDirichletNodes_size
        %% boundary properties
        s1_counterclockwiseNodeIndexes % bottom
        s1_counterclockwiseNodeCoordinates
        %%%%%
        s2_counterclockwiseNodeIndexes % rigth side
        s2_counterclockwiseNodeCoordinates
        %%%%%
        s3_counterclockwiseNodeIndexes % surface
        s3_counterclockwiseNodeCoordinates
        %%%%%
        s4_counterclockwiseNodeIndexes % left side
        s4_counterclockwiseNodeCoordinates
        %%%%%
        boundary_counterclockwiseNodeIndexes
        boundary_counterclockwiseNodeCoordinates
        %% element centroids
        elementCentroids
    end
    
    methods
       
        %% boundary methods
        function setDomainSideCounterclockwiseBoundaryNodeIndexes(obj)
            if ~isempty(obj.edges)
            obj.set('s1_counterclockwiseNodeIndexes', obj.edges(1,find(obj.edges(5,:)==1)));
            obj.set('s2_counterclockwiseNodeIndexes', obj.edges(1,find(obj.edges(5,:)==2)));
            obj.set('s3_counterclockwiseNodeIndexes', obj.edges(1,find(obj.edges(5,:)==3)));
            obj.set('s4_counterclockwiseNodeIndexes', obj.edges(1,find(obj.edges(5,:)==4)));
            
            obj.s1_counterclockwiseNodeIndexes(end+1) = obj.s2_counterclockwiseNodeIndexes(1);
            obj.set('s2_counterclockwiseNodeIndexes', obj.s2_counterclockwiseNodeIndexes(2:end));
            obj.s3_counterclockwiseNodeIndexes(end+1) = obj.s4_counterclockwiseNodeIndexes(1);
            obj.set('s4_counterclockwiseNodeIndexes', obj.s4_counterclockwiseNodeIndexes(2:end));
            end
        end
       
        function setCounterclockwiseBoundaryNodeIndexes(obj)
            if ~isempty(obj.s1_counterclockwiseNodeIndexes)&&~isempty(obj.s2_counterclockwiseNodeIndexes)&&~isempty(obj.s3_counterclockwiseNodeIndexes)&&~isempty(obj.s4_counterclockwiseNodeIndexes)
            obj.set('boundary_counterclockwiseNodeIndexes', [obj.s1_counterclockwiseNodeIndexes,...
                obj.s2_counterclockwiseNodeIndexes,...
                obj.s3_counterclockwiseNodeIndexes,...
                obj.s4_counterclockwiseNodeIndexes]);
            end          
        end
        
        function setDomainSideCounterclockwiseBoundaryNodeCoordinates(obj)
            if ~isempty(obj.s1_counterclockwiseNodeIndexes)&&~isempty(obj.s2_counterclockwiseNodeIndexes)&&~isempty(obj.s3_counterclockwiseNodeIndexes)&&~isempty(obj.s4_counterclockwiseNodeIndexes)
            obj.set('s1_counterclockwiseNodeCoordinates', obj.nodeCoordinates(:,obj.s1_counterclockwiseNodeIndexes));
            obj.set('s2_counterclockwiseNodeCoordinates', obj.nodeCoordinates(:,obj.s2_counterclockwiseNodeIndexes));
            obj.set('s3_counterclockwiseNodeCoordinates', obj.nodeCoordinates(:,obj.s3_counterclockwiseNodeIndexes));
            obj.set('s4_counterclockwiseNodeCoordinates', obj.nodeCoordinates(:,obj.s4_counterclockwiseNodeIndexes));
            end
        end
        
        function setCounterclockwiseBoundaryNodeCoordinates(obj)
            if ~isempty(obj.boundary_counterclockwiseNodeIndexes)
                obj.set('boundary_counterclockwiseNodeCoordinates', obj.nodeCoordinates(:,obj.boundary_counterclockwiseNodeIndexes));
            end
        end
        
        function setBoundaries(obj)
            
            obj.setDomainSideCounterclockwiseBoundaryNodeIndexes;
            obj.setCounterclockwiseBoundaryNodeIndexes;
            obj.setDomainSideCounterclockwiseBoundaryNodeCoordinates;
            obj.setCounterclockwiseBoundaryNodeCoordinates;
            
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
        function setBoundaryConditionProperties(obj, vals)
            props = {'bc'};
            obj.set(props, vals)
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
        
        %% geometry methods
        function  setProperties(obj, vals)
            props = {'name', 'elementLength', 'domain'};
            obj.set(props, vals)
            [nd,ed,el] = initmesh(obj.domain.decomposedGeometry,...
                'Hmax',...
                obj.elementLength);
            obj.set('nodeCoordinates',nd);
            obj.set('edges',ed);
            obj.set('elements',el);
            obj.setNodeSizeNumber;
            obj.setElementSizeNumber;
            obj.elementCentroidsComputation
            
            % plot mesh properties
            fprintf('----------------------------------------- \n');
            fprintf('%s res. = %d m \n',obj.name,obj.elementLength);
            fprintf('%s size (elements) = %d \n',obj.name,obj.elementSizeNumber);
            fprintf('%s size (nodes) = %d \n',obj.name,obj.nodeSizeNumber);
            fprintf('----------------------------------------- \n');
            
        end
        
        function setNodeSizeNumber(obj)
            obj.set('nodeSizeNumber',size(obj.nodeCoordinates,2));
        end
        
        function setElementSizeNumber(obj)
            obj.set('elementSizeNumber',size(obj.elements,2));
            if obj.elementSizeNumber>=25000
                error('mesh dimension exceed the maximum size available')
            end
        end
        
        %% element centroid
        function elementCentroidsComputation(obj)
            obj.elementCentroids = zeros(obj.elementSizeNumber,2);
            for ie=1:obj.elementSizeNumber
                [obj.elementCentroids(ie,1),obj.elementCentroids(ie,2)] = Mesh.computeCentroid(obj.nodeCoordinates(1, obj.elements(1,ie)),obj.nodeCoordinates(1, obj.elements(2,ie)),obj.nodeCoordinates(1, obj.elements(3,ie)),...
                    obj.nodeCoordinates(2, obj.elements(1,ie)), obj.nodeCoordinates(2, obj.elements(2,ie)), obj.nodeCoordinates(2, obj.elements(3,ie)));
            end
        end
        
        %% plot methods
        function plotMesh(obj, bool)
            if bool
                figure
                pdeplot(obj.nodeCoordinates,obj.edges,obj.elements);%,'ElementLabels','on'); % add ",'NodeLabels','on');" if you want the node labels to be shown ('computational expensive in terms of gpu')
                hold on
                plot(obj.elementCentroids(:,1), obj.elementCentroids(:,2),'rx')
                title(sprintf('mesh %s -- res.=%dm, eln=%d, nn=%d',obj.name,obj.elementLength, obj.elementSizeNumber, obj.nodeSizeNumber))
            end
        end
        
    end
    
    methods (Static)
        function [xc,yc] = computeCentroid(x1,x2,x3,...
                y1,y2,y3)
            
            xc = (x1+x2+x3)/3;
            yc = (y1+y2+y3)/3;
            
        end
    end
    
end