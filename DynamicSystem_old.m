classdef DynamicSystem  < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        fem FemModel
        mesh Mesh
        ft ForceTerm
        dirichletValue double = 400 % u.m. in ppm - g/m^3;
        stateInitialCondition double = 400 % u.m. in ppm - g/m^3;
        dirichlet_type string % 'static', 'variable'
        
        initial_state double
        state double {mustBeNonNan} % {mustbenonNegative} to add
    end
    
    methods
        
        function dynamicSystem(obj, vals)
            props = {'fem','mesh','ft','stateInitialCondition','dirichlet_type'};
            obj.set(props, vals)
        end
        
        function setInitialState(obj)
            n_nodes = obj.mesh.node_size_number;
            anedn_indexes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            dirichlet_indexes = obj.mesh.bc.dirichlet.counterclockwiseNodeIndexes;
            obj.initial_state = zeros(n_nodes, 1);
            obj.initial_state(anedn_indexes) = obj.stateInitialCondition;
            obj.initial_state(dirichlet_indexes) = obj.dirichletValue;
        end
        
        function setState(obj)
            disp('dynamic system computation')
            obj.setInitialState()
            n_nodes = obj.mesh.node_size_number;
            anedn_indexes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            dirichlet_indexes = obj.mesh.bc.dirichlet.counterclockwiseNodeIndexes;
            t_steps = obj.ft.time.time_steps;
            x0 = obj.initial_state(anedn_indexes);
            x_0_d = obj.initial_state(dirichlet_indexes);
            x_1_d = x_0_d;
            
            delta = obj.ft.time.dt.value;
            
            obj.state = zeros(n_nodes, length(t_steps));
            if ismember(obj.dirichlet_type,'static')
                obj.state(dirichlet_indexes,:) = repmat(x_0_d,1,length(t_steps));
            end
            indexProgress = 1;
            
            for k=t_steps(1:end-1)
                if k>=round(length(t_steps)/10)*indexProgress
                    fprintf(' %d/%d ',indexProgress,min(length(t_steps),10));
                    indexProgress = indexProgress + 1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                obj.state(anedn_indexes,k)=x0;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [x1]=DynamicSystem.dynamicSystemSimulator(x0,...
                    obj.fem.massMatrix_allNodesExceptDirichletNodes,...
                    obj.fem.stifnessMatrix_allNodesExceptDirichletNodes,...
                    obj.fem.massMatrix_dirichlet,...
                    obj.fem.stifnessMatrix_dirichlet,...
                    x_1_d,...
                    x_0_d,...
                    obj.ft.force_term(anedn_indexes,k),...
                    delta);
                
                x0 = x1;
                obj.state(anedn_indexes,k+1) = x1;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                if ismember(obj.dirichlet_type,'variable')
                    x_0_d=x_1_d;
                    obj.set_state_for_boundary_nodes(k)
                    x_1_d=obj.state(dirichlet_indexes,k+1);
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            end
            fprintf(' \n')
        end
        
        function set_state_for_boundary_nodes(obj,k)
            i_internal_nodes=obj.mesh.boundary_internal_node_array_indexes;
            i_boundary_nodes=obj.mesh.bc.boundary_counterclockwiseNodeIndexes;
            i_boundary_elements=obj.mesh.boundary_element_indexes;
            elements=obj.mesh.elements;
            for ie=1:i_boundary_elements
                i_b_nodes=[];
                i_i_nodes=[];
                indexb=1;
                indexi=1;
                for v=1:3
                    if ismember(elements(v,ie),i_boundary_nodes)
                        i_b_nodes(indexb)=elements(v,ie);
                        indexb=indexb+1;
                    elseif ismember(elements(v,ie),i_internal_nodes)
                        i_i_nodes(indexi)=elements(v,ie);
                        indexi=indexi+1;
                    end
                end
                for i=1:length(i_b_nodes)
                    obj.state(i_b_nodes(i),k+1)=obj.state(i_i_nodes(1),k+1);
                end
            end
        end
    end
    
    methods(Static)
        function[x_1]=dynamicSystemSimulator(x_0,...
                M_aned,...
                S_aned,...
                M_d,...
                S_d,...
                x_1_d,...
                x_0_d,...
                f,...
                delta)
            
            % forward euler
            DM_aned = M_aned/delta;
            DS_aned = S_aned;
            DM_d = M_d/delta;
            DS_d = S_d;
            
            x_1 = DM_aned\(DM_aned * x_0 - DS_aned * x_0 + f - DM_d * x_1_d + DM_d * x_0_d -DS_d * x_0_d);
        end
    end
end