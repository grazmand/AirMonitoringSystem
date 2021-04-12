classdef ForceTermCO2 < ForceTerm
    properties (SetAccess = private, GetAccess = public)
        sources SourcesCO2
        force_term double
    end
    properties (Constant)
        type string='co2'
    end
    methods
        function initForceTerm(obj)
            obj.force_term = zeros(obj.mesh.node_size_number,obj.time.time_steps(end));
        end
        function setForceTerm(obj,vals)
            props={'sources'};
            obj.set(props,vals)
            obj.initForceTerm()
            % conv. emission rate from g*veh./m*sec. to
            % g*veh./m*sec.*dt^-1
            element_em_rates=obj.sources.element_em_rates*obj.time.dt.value;
            time1=obj.time.time_steps(1):obj.k_frames(1);
            time2=obj.k_frames(1)+1:obj.time.time_steps(end);
            frame=obj.i_frames(1);
            if obj.k_frames(1)<length(obj.time.time_steps)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                index=1;
                for ie=obj.sources.element_indexes
                    nodes=obj.mesh.elements(1:3,ie);
                    obj.force_term(nodes,time1) = obj.force_term(nodes,time1) + element_em_rates(index,1) * obj.sources.shapes(index,:)';
                    obj.force_term(nodes,time2) = obj.force_term(nodes,time2) + element_em_rates(index,frame) * obj.sources.shapes(index,:)';
                    index=index+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                index=1;
                for ie=obj.sources.element_indexes
                    nodes=obj.mesh.elements(1:3,ie);
                    obj.force_term(nodes,:) = obj.force_term(nodes,:) + element_em_rates(index,frame) * obj.sources.shapes(index,:)';
                    index=index+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
    end
end
