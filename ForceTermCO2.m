classdef ForceTermCO2 < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        sources SourcesCO2
    end
    methods
        function setForceTerm(obj)
            obj.initForceTerm()
            % conv. emission rate from g*veh./m*sec. to
            % g*veh./m*sec.*dt^-1
            obj.element_em_rates=obj.element_em_rates*obj.time.dt.value;
            frame=1;
            i_frame=1;
            for k=obj.time.time_steps
                if ismember(k,obj.k_frames)
                    i_frame=i_frame+1;
                    frame=obj.frames(i_frame);
                end
                index=1;
                for ie=obj.sources.element_indexes
                    nodes=obj.mesh.elements(1:3,ie);
                    obj.force_term(nodes,k) = obj.force_term(nodes,k) + obj.sources.element_em_rates(index,frame) * obj.sources.shapes(index,k)';
                    index=index+1;
                end
            end
        end
    end
end