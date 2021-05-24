classdef RectangularDomainDynamicSystem  < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        fem RectangularDomainFemModel
        mesh RectangularDomainMesh
        ft double %force term
        time TimeT
        dirichletValue double=0 % u.m. in ppm - g/m^3;
        stateInitialCondition double=0 % u.m. in ppm - g/m^3;
        dirichlet_type string % 'static', 'variable'
        initial_state_type string % 'constant', 'gaussian'
        sigma double
        
        initial_state double
        state double {mustBeNonNan}
    end
    
    methods
        
        function dynamicSystem(obj, vals)
            props = {'time','fem','mesh','ft','stateInitialCondition',...
                'initial_state_type','sigma','dirichlet_type'};
            obj.set(props, vals)
        end
        
        function setInitialState(obj)
            % param
            n_nodes = obj.mesh.node_size_number;
            anedn_indexes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            if ismember('constant',obj.initial_state_type)
                if ~isempty(obj.mesh.bc.dirichlet)
                    dirichlet_indexes=obj.mesh.bc.dirichlet.counterclockwiseNodeIndexes;
                else
                    dirichlet_indexes=[];
                end
                obj.initial_state = zeros(n_nodes, 1);
                obj.initial_state(anedn_indexes) = obj.stateInitialCondition;
                obj.initial_state(dirichlet_indexes) = obj.dirichletValue;
            elseif ismember('gaussian',obj.initial_state_type)
                if ~isempty(obj.mesh.bc.dirichlet)
                    dirichlet_indexes=obj.mesh.bc.dirichlet.counterclockwiseNodeIndexes;
                else
                    dirichlet_indexes=[];
                end
                obj.initial_state = zeros(n_nodes, 1);
                for in=1:length(anedn_indexes)
                    x=obj.mesh.allNodesExceptDirichletNodes_coordinates(1,in);
                    y=obj.mesh.allNodesExceptDirichletNodes_coordinates(2,in);
                    % r=sqrt(x^2+y^2);
                    obj.initial_state(anedn_indexes(in))=exp(-((x^2/obj.sigma^2)+(y^2/obj.sigma^2)));
                end
                obj.initial_state(dirichlet_indexes) = obj.dirichletValue;
            end
        end
        
        function setState(obj)
            disp('dynamic system computation')
            
            % paramas
            delta = obj.time.dt.value;
            t_steps = obj.time.time_steps;
            n_nodes = obj.mesh.node_size_number;
            anedn_indexes = obj.mesh.allNodesExceptDirichletNodes_indexes;
            if ~isempty(obj.mesh.bc.dirichlet)
                dirichlet_indexes=obj.mesh.bc.dirichlet.counterclockwiseNodeIndexes;
            else
                dirichlet_indexes=[];
            end
            indexProgress = 1;
            
            % state initialization
            obj.setInitialState()
            obj.state = zeros(n_nodes, length(t_steps));
            x0 = obj.initial_state(anedn_indexes);
            
            % dir conditions
            x_0_d = obj.initial_state(dirichlet_indexes);
            x_1_d = x_0_d;
            %             if ismember(obj.dirichlet_type,'static')
            %                 obj.state(dirichlet_indexes,:) = repmat(x_0_d,1,length(t_steps));
            %             end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % fem model
            M_aned=obj.fem.massMatrix_allNodesExceptDirichletNodes;
            S_aned=obj.fem.stifnessMatrix_allNodesExceptDirichletNodes;
            M_d=obj.fem.massMatrix_dirichlet;
            S_d=obj.fem.stifnessMatrix_dirichlet;
            f=obj.ft;
            
            %             D=0.5*(M_aned\S_aned);
            %             D=((eye(size(D))+delta*D)\...
            %                 (eye(size(D))-delta*D));
            
            % forward euler
            DM_aned = M_aned/delta;
            DS_aned = S_aned;
            DM_d = M_d/delta;
            DS_d = S_d;
            
            clear M_aned S_aned M_d S_d
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % computation
            for k=t_steps(1:end)
                if k>=round(length(t_steps)/10)*indexProgress
                    fprintf(' %d/%d ',indexProgress,min(length(t_steps),10));
                    indexProgress = indexProgress + 1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %                 obj.state(anedn_indexes,k)=x0;
                %                 obj.state(obj.mesh.boundary_counterclockwiseNodeIndexes,k)=...
                %                     zeros(size(obj.mesh.boundary_counterclockwiseNodeIndexes));
                if ~isempty(obj.mesh.bc.dirichlet)
                    [x1]=RectangularDomainDynamicSystem.dynamicSystemSimulator(x0,DM_aned,DS_aned,DM_d,DS_d,x_1_d,x_0_d,...
                        f(anedn_indexes,k));
                else
                    [x1]=RectangularDomainDynamicSystem.dynamicSystemSimulator(x0,DM_aned,DS_aned);
                end
                x0 = x1;
                obj.state(anedn_indexes,k) = x1;
                obj.state(dirichlet_indexes,k)=x_1_d;
                %                                                 obj.state(obj.mesh.boundary_counterclockwiseNodeIndexes,k)=...
                %                                                     zeros(size(obj.mesh.boundary_counterclockwiseNodeIndexes));
                
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
                DM_aned,DS_aned,DM_d,DS_d,x_1_d,x_0_d,f)
            % overloaded function
            if nargin==7
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             D=-delta*DM_aned\DS_aned;
                %             x_1 = D*x_0;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                x_1 = DM_aned\(DM_aned * x_0 - DS_aned * x_0 - DM_d * x_1_d + DM_d * x_0_d -DS_d * x_0_d);
            elseif nargin==8
                x_1 = DM_aned\(DM_aned * x_0 - DS_aned * x_0 + f - DM_d * x_1_d + DM_d * x_0_d -DS_d * x_0_d);
            elseif nargin==3
                x_1 = DM_aned\(DM_aned * x_0 - DS_aned * x_0);
            end
        end
    end
end