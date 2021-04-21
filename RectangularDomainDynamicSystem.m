classdef RectangularDomainDynamicSystem  < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        fem RectangularDomainFemModel
        mesh RectangularDomainMesh
        time TimeT
        dirichletValue double = 0 % u.m. in ppm - g/m^3;
        stateInitialCondition double = 0 % u.m. in ppm - g/m^3;
        dirichlet_type string % 'static', 'variable'
        initial_state_type string % 'constant', 'gaussian'
        
        initial_state double
        state double {mustBeNonNan} 
    end
    
    methods
        
        function dynamicSystem(obj, vals)
            props = {'time','fem','mesh','stateInitialCondition',...
                'initial_state_type','dirichlet_type'};
            obj.set(props, vals)
        end
        
        function setInitialState(obj)
            if ismember('constant',obj.initial_state_type)
                n_nodes = obj.mesh.node_size_number;
                anedn_indexes = obj.mesh.allNodesExceptDirichletNodes_indexes;
                if ~isempty(obj.mesh.bc.dirichlet)
                    dirichlet_indexes=obj.mesh.bc.dirichlet.counterclockwiseNodeIndexes;
                else
                    dirichlet_indexes=[];
                end
                obj.initial_state = zeros(n_nodes, 1);
                obj.initial_state(anedn_indexes) = obj.stateInitialCondition;
                obj.initial_state(dirichlet_indexes) = obj.dirichletValue;
            elseif ismember('gaussian',obj.initial_state_type)
                n_nodes = obj.mesh.node_size_number;
                anedn_indexes = obj.mesh.allNodesExceptDirichletNodes_indexes;
                if ~isempty(obj.mesh.bc.dirichlet)
                    dirichlet_indexes=obj.mesh.bc.dirichlet.counterclockwiseNodeIndexes;
                else
                    dirichlet_indexes=[];
                end
                obj.initial_state = zeros(n_nodes, 1);
                for in=1:length(anedn_indexes)
                    x=obj.mesh.allNodesExceptDirichletNodes_coordinates(1,in);
                    y=obj.mesh.allNodesExceptDirichletNodes_coordinates(2,in);
                    sigma=6;
                    obj.initial_state(in) = exp(-((x^2/sigma^2)+(y^2/sigma^2)));
                end
                obj.initial_state(dirichlet_indexes) = obj.dirichletValue;
            end
        end
        
        function setState(obj)
            disp('dynamic system computation')
            obj.setInitialState()
            n_nodes = obj.mesh.node_size_number;
            anedn_indexes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            if ~isempty(obj.mesh.bc.dirichlet)
                dirichlet_indexes=obj.mesh.bc.dirichlet.counterclockwiseNodeIndexes;
            else
                dirichlet_indexes=[];
            end
            t_steps = obj.time.time_steps;
            x0 = obj.initial_state(anedn_indexes);
            x_0_d = obj.initial_state(dirichlet_indexes);
            x_1_d = x_0_d;
            
            delta = obj.time.dt.value;
            
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
                [x1]=RectangularDomainDynamicSystem.dynamicSystemSimulator(x0,...
                    obj.fem.massMatrix_allNodesExceptDirichletNodes,...
                    obj.fem.stifnessMatrix_allNodesExceptDirichletNodes,...
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
                delta)
            
            % forward euler
            DM_aned = M_aned/delta;
            DS_aned = S_aned;
            
            x_1 = x_0 - DM_aned\(DS_aned * x_0);
        end
    end
end