classdef FemModel < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        mesh Mesh
        medium Medium
        boundaryConditions BoundaryConditions
        
        massMatrix
        stifnessMatrix
        
        massMatrix_allNodesExceptDirichletNodes
        stifnessMatrix_allNodesExceptDirichletNodes
        
        massMatrix_dirichlet
        stifnessMatrix_dirichlet
        
        shape_coefficients % is a [3 X 3 X elementSizeNumber] tensor
    end
    
    properties (Constant)
        elementNodeNumber {mustBePositive} = 3
    end
    
    methods
        
        function fem_model(obj, vals)
            props = {'mesh','medium','boundaryConditions'};
            obj.set(props, vals);
            obj.set_fem_matrices()
        end
        
        function obj = set_fem_matrices(obj)
            obj.initialize_fem_matrices()
            obj.set_global_matrices()
        end
        
        function set_global_matrices(obj)
            
            aned_nodes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            d_nodes = obj.boundaryConditions.dirichlet.counterclockwiseNodeIndexes;
            
            obj.initialize_shape_coefficients()
            
            M = obj.massMatrix;
            S = obj.stifnessMatrix;
            
            for ie = 1:obj.mesh.elementSizeNumber
                
                [Me, Se, obj.shapeCoefficients(:,:,ie)] = set_coeff_shapes_and_local_matrices(ie, obj.mesh);
                [M,S] = build_global_fem_matrices(obj.medium.alpha,M,S,...
                    ie,Me,Se,ie);
                
            end
            
            M_allNodesExceptDirichletNodes = M(aned_nodes, aned_nodes);
            S_allNodesExceptDirichletNodes = S(aned_nodes, aned_nodes);
            
            M_dirichlet = M(aned_nodes, d_nodes);
            S_dirichlet = S(aned_nodes, d_nodes);
            
            obj.massMatrix_allNodesExceptDirichletNodes = sparse(M_allNodesExceptDirichletNodes);
            obj.stifnessMatrix_allNodesExceptDirichletNodes = sparse(S_allNodesExceptDirichletNodes);
            
            obj.massMatrix_dirichlet = sparse(M_dirichlet);
            obj.stifnessMatrix_dirichlet = sparse(S_dirichlet);
            
            obj.massMatrix = sparse(M);
            obj.stifnessMatrix = sparse(S);
        end
        
        function initialize_fem_matrices(obj)
            n_nodes = obj.mesh.nodeSizeNumber;
            aned_nodes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            d_nodes = obj.boundaryConditions.dirichlet.counterclockwiseNodeIndexes;
            
            obj.massMatrix = zeros(n_nodes, n_nodes);
            obj.stifnessMatrix = zeros(n_nodes, n_nodes);
            
            obj.massMatrix_allNodesExceptDirichletNodes = zeros(aned_nodes, aned_nodes);
            obj.stifnessMatrix_allNodesExceptDirichletNodes = zeros(aned_nodes, aned_nodes);
            
            obj.massMatrix_dirichlet = zeros(aned_nodes, d_nodes);
            obj.stifnessMatrix_dirichlet = zeros(aned_nodes, d_nodese);
        end
        
        function initialize_shape_coefficients(obj)
            obj.shapeCoefficients = zeros(3,3,obj.mesh.element_size_number);
        end
    end
    
    methods (Static)
        function [massLocalMatrix, stifnessLocalMatrix, elementShapeCoefficients] = set_coeff_shapes_and_local_matrices(elementIndex, mesh)
            elementNodeIndexes = mesh.elements(1:3,elementIndex);
            elementNodeCoordinates = mesh.node_coordinates(:,elementNodeIndexes)';
            %%%% elementNodeCoordinates è una matrice
            %%%% 3x2 in cui sono registrate le info sulle coordinate dei nodi delll'elemento ie.
            %%%% Nella prima colonna ci sono le coordinate delle ascisse. Nella seconda
            %%%% le ordinate.
            [stifnessLocalMatrix, massLocalMatrix, elementShapeCoefficients] = FemModel.build_local_fem_matrices(elementNodeCoordinates);
        end
        
        function [M,S] = build_global_fem_matrices(alpha,Me,Se,M,S,mesh,ie)
            %%%% ------------ build mass matrix
            M (mesh.elements(1:3,ie), mesh.elements(1:3,ie)) =...
                M (mesh.elements(1:3,ie), mesh.elements(1:3,ie)) + Me;
            
            %%%% ------------ build stifness matrix
            S (mesh.elements(1:3,ie), mesh.elements(1:3,ie)) =...
                S (mesh.elements(1:3,ie), mesh.elements(1:3,ie)) + alpha * Se;
        end
        
        function [Se,Te,Shape] = build_local_fem_matrices(XY)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Element is a first order tri
            %
            %   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            A = ((XY(2,1)-XY(1,1))*(XY(3,2)-XY(1,2)) - ...
                (XY(3,1)-XY(1,1))*(XY(2,2)-XY(1,2)))/2;
            
            Dx(1) =  XY(3,1) - XY(2,1);
            Dx(2) =  XY(1,1) - XY(3,1);
            Dx(3) =  XY(2,1) - XY(1,1);
            Dy(1) =  XY(2,2) - XY(3,2);
            Dy(2) =  XY(3,2) - XY(1,2);
            Dy(3) =  XY(1,2) - XY(2,2);
            
            % New: Shape functions
            
            a(1)=XY(2,1)*XY(3,2)-XY(3,1)*XY(2,2);
            a(2)=XY(3,1)*XY(1,2)-XY(1,1)*XY(3,2);
            a(3)=XY(1,1)*XY(2,2)-XY(2,1)*XY(1,2);
            
            Shape = [a;Dy;Dx]/(2*A);
            % 3x3_size shape function coefficients matrix
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            %
            % example :
            %
            % phi_1(x,y) = a1 + b1 * x + c1 * y
            % phi_2(x,y) = a2 + b2 * x + c2 * y
            % phi_3(x,y) = a3 + b3 * x + c3 * y
            %          _        _
            %         | a1 b1 c1 |
            % Shape = | a2 b2 c2 |
            %         |_a3 b3 c3_|
            %
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Se = zeros(3,3); % local stifness matrix
            Te = zeros(3,3); % local mass matrix
            
            for i = 1 : 3
                for j = 1 : i
                    Se(i,j) = (Dy(i)*Dy(j)+Dx(i)*Dx(j)) / (4*A);
                    Se(j,i) = Se(i,j);
                    Te(i,j) = A / 12;
                    Te(j,i) = Te(i,j);
                end
                Te(i,i) = 2 * Te(i,i);
            end
        end
    end
end