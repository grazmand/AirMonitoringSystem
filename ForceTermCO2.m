classdef ForceTermCO2 < ForceTerm
    properties (SetAccess = private, GetAccess = public)
        sources SourcesCO2
    end
    properties (Constant)
        type string='co2'
    end
    methods
        function setForceTerm(obj,vals)
            props={'sources'};
            obj.set(props,vals)
            time1=obj.time.time_steps(1):obj.k_frames(1);
            time2=obj.k_frames(1)+1:obj.time.time_steps(end);
            if obj.k_frames(1)<length(obj.time.time_steps)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                index=1;
                for ie=obj.sources.element_indexes
                    nodes=obj.mesh.elements(1:3,ie);
                    obj.force_term(nodes,time1) = obj.force_term(nodes,time1) + obj.corr*element_em_rates(index,1) * obj.sources.shapes(index,:)';
                    obj.force_term(nodes,time2) = obj.force_term(nodes,time2) + obj.corr*element_em_rates(index,2) * obj.sources.shapes(index,:)';
                    index=index+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                index=1;
                for ie=obj.sources.element_indexes
                    nodes=obj.mesh.elements(1:3,ie);
                    obj.force_term(nodes,:) = obj.force_term(nodes,:) + obj.corr*element_em_rates(index,1) * obj.sources.shapes(index,:)';
                    index=index+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
    end
end
