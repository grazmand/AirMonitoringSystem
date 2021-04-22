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
        areas double
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
            
            vel=obj.medium.advection_vector;
            
            aned_nodes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            if ~isempty(obj.boundaryConditions.dirichlet)
                d_nodes=obj.boundaryConditions.dirichlet.counterclockwiseNodeIndexes;
            else
                d_nodes=[];
            end
            
            obj.initialize_shape_coefficients()
            
            M = obj.massMatrix;
            S = obj.stifnessMatrix;
            
            for ie = 1:obj.mesh.element_size_number
                
                [Me,Se,SVe,obj.shape_coefficients(:,:,ie),obj.areas(ie)] = FemModel.set_coeff_shapes_and_local_matrices(ie,obj.mesh,vel);
                [M,S] = FemModel.build_global_fem_matrices(obj.medium.diffusion,M,S,...
                    ie,Me,Se,SVe,obj.mesh);
                
            end
            
            M_allNodesExceptDirichletNodes = M(aned_nodes, aned_nodes);
            M_dirichlet = M(aned_nodes, d_nodes);
            obj.massMatrix = M;
            clear M
            
            S_allNodesExceptDirichletNodes = S(aned_nodes, aned_nodes);
            S_dirichlet = S(aned_nodes, d_nodes);
            obj.stifnessMatrix = S;
            clear S
            
            obj.massMatrix_allNodesExceptDirichletNodes = M_allNodesExceptDirichletNodes;
            obj.stifnessMatrix_allNodesExceptDirichletNodes = S_allNodesExceptDirichletNodes;
            
            obj.massMatrix_dirichlet = M_dirichlet;
            obj.stifnessMatrix_dirichlet = S_dirichlet;
            
        end
        
        function initialize_fem_matrices(obj)
            n_nodes=obj.mesh.node_size_number;
            aned_nodes=obj.mesh.allNodesExceptDirichletNodes_indexes;
            n_aned_nodes=length(aned_nodes);
            d_nodes=obj.boundaryConditions.dirichlet.counterclockwiseNodeIndexes;
            n_d_nodes=length(d_nodes);
            
            obj.massMatrix = sparse(zeros(n_nodes, n_nodes));
            obj.stifnessMatrix = sparse(zeros(n_nodes, n_nodes));
            
            obj.massMatrix_allNodesExceptDirichletNodes = sparse(zeros(n_aned_nodes, n_aned_nodes));
            obj.stifnessMatrix_allNodesExceptDirichletNodes = sparse(zeros(n_aned_nodes, n_aned_nodes));
            
            obj.massMatrix_dirichlet = sparse(zeros(n_aned_nodes, n_d_nodes));
            obj.stifnessMatrix_dirichlet = sparse(zeros(n_aned_nodes, n_d_nodes));
        end
        
        function initialize_shape_coefficients(obj)
            obj.shape_coefficients = zeros(3,3,obj.mesh.element_size_number);
        end
    end
    
    methods (Static)
        function [massLocalMatrix,stifnessLocalMatrix,SVe,elementShapeCoefficients,elementArea] =...
                set_coeff_shapes_and_local_matrices(elementIndex,mesh,vel)
            elementNodeIndexes = mesh.elements(1:3,elementIndex);
            elementNodeCoordinates = mesh.node_coordinates(:,elementNodeIndexes)';
            %%%% elementNodeCoordinates è una matrice
            %%%% 3x2 in cui sono registrate le info sulle coordinate dei nodi delll'elemento ie.
            %%%% Nella prima colonna ci sono le coordinate delle ascisse. Nella seconda
            %%%% le ordinate.
            [stifnessLocalMatrix,massLocalMatrix,SVe,elementShapeCoefficients,elementArea] = FemModel.build_local_fem_matrices(elementNodeCoordinates,vel);
        end
        
        function [M,S] = build_global_fem_matrices(alpha,M,S,...
                ie,Me,Se,SVe,mesh)
            %%%% ------------ build mass matrix
            M (mesh.elements(1:3,ie), mesh.elements(1:3,ie)) =...
                M (mesh.elements(1:3,ie), mesh.elements(1:3,ie)) + Me;
            
            %%%% ------------ build stifness matrix
            S (mesh.elements(1:3,ie), mesh.elements(1:3,ie)) =...
                S (mesh.elements(1:3,ie), mesh.elements(1:3,ie)) + alpha * Se + SVe;
        end
        
        function [Se,Te,SVe,Shape,A] = build_local_fem_matrices(XY,vel)
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
            
            GN = [Dy(1) Dy(2) Dy(3); Dx(1) Dx(2) Dx(3)]; % 2x3 matrix
            SVe = [vel; vel; vel]*GN*(1/6);
            
            % New: Shape functions
            
            a(1)=XY(2,1)*XY(3,2)-XY(3,1)*XY(2,2);
            a(2)=XY(3,1)*XY(1,2)-XY(1,1)*XY(3,2);
            a(3)=XY(1,1)*XY(2,2)-XY(2,1)*XY(1,2);
            
            Shape = [a;Dy;Dx]/(2*A);
            
            %
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
            %         | a1 a2 a3 |
            % Shape = | b1 b2 b3 |
            %         |_c1 c2 c3_|
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