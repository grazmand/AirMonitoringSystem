classdef RectangularDomainFemModel < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        mesh RectangularDomainMesh
        medium Medium
        boundaryConditions RectangularDomainBoundaryConditions
        
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
            if ~isempty(obj.boundaryConditions.dirichlet)
                d_nodes=obj.boundaryConditions.dirichlet.counterclockwiseNodeIndexes;
            else
                d_nodes=[];
            end
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
end