classdef ForceTermCO2 < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        sources SourcesCO2
    end
    methods
        function setForceTerm(obj)
            obj.initForceTerm()
            % conv. emission rate from g*veh./m*sec. to
            % g*veh./m*sec.*dt^-1~=g*veh./m^3*sec.*dt^-1~=ppm*veh./sec.*dt^-1
            obj.element_em_rates=obj.element_em_rates*obj.time.dt.value;
            index=1;
            for ie=obj.sources.element_indexes
                nodes=obj.mesh.elements(1:3,ie);
                obj.force_term(nodes,:) = obj.force_term(nodes,:) + obj.sources.em_factor * obj.sources.shapes(index,:)';
                index=index+1;
            end
        end
    end
end