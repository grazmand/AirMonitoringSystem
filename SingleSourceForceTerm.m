classdef SingleSourceForceTerm < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        %% basics
        name string
        source ImpulsiveSource
        %% derivative
        force_term double
    end
    
    methods
        function source_force_term(obj, vals)
            props = {'name','source'};
            obj.set(props, vals)
            obj.set_force_term()
        end
        
        function init_force_term(obj)
            n_nodes=obj.source.fem.mesh.node_size_number;
            t=obj.source.time.time_steps;
            obj.force_term=zeros(n_nodes,length(t));
        end
        
        function set_force_term(obj)
            obj.init_force_term()
            if ismember('static',obj.source.type)
                obj.force_term(obj.source.elementNodeIndexes,:) = obj.source.source_wave_form .* obj.source.shapes';
            elseif ismember('moving',obj.source.type)
                for k=obj.source.time.timeSteps
                    obj.dtForceTerm(obj.source.elementNodeIndexes(:,k),k) = - obj.source.discreteTimeSourceTerm(k) * obj.source.shapes(:,k)' * (obj.source.afemm.density)^-1;
                end
            end
        end
    end
end