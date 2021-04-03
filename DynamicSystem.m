classdef DynamicSystem  < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        fem FemModel
        mesh Mesh
        ft ForceTerm
        dirichletValue double = 0
        stateInitialCondition double = 0
        
        initial_state double
        state double
    end
    
    methods
        
        function dynamicSystem(obj, vals)
            props = {'fem','mesh','ft','stateInitialCondition'};
            obj.set(props, vals)
        end
        
        function setInitialState(obj)
            n_nodes = obj.mesh.node_size_number;
            anedn_indexes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            dirichlet_indexes = obj.boundaryConditions.dirichlet.counterclockwiseNodeIndexes;
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
            t_steps = obj.ft.time.timeSteps;
            x0 = obj.initial_state(anedn_indexes);
            x_d = obj.initial_state(dirichlet_indexes);
            
            delta = obj.ft.time.dt.value;
            
            obj.state = zeros(n_nodes, length(t_steps));
            obj.state(dirichlet_indexes,:) = repmat(x_d,1,length(t_steps));
            
            indexProgress = 1;
            
            for k=t_steps(1:end-1)
                if k>=round(length(t_steps)/10)*indexProgress
                    fprintf(' %d/%d ',indexProgress,min(length(t_steps),10));
                    indexProgress = indexProgress + 1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                obj.state(anedn_indexes,k)=x0;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [x1]=dynamicSystemSimulator(x_0,...
                    M_aned,...
                    S_aned,...
                    M_d,...
                    S_d,...
                    x_d,...
                    x_d,...
                    obj.ft.force_term(k),...
                    delta);
                
                x0 = x1;
                obj.state(anedn_indexes,k+1) = x1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            end
            fprintf(' \n')
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