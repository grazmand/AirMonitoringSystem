classdef DynamicForceTermC02<DynamicForceTerm
    properties
        sources SourcesCO2
    end
    properties (Constant)
        type string='co2'
    end
    methods
        function set_force_term(obj)
            index=1;
            if obj.k<obj.k_frames(1)
                for ie=obj.sources.element_indexes
                    nodes=obj.mesh.elements(1:3,ie);
                    obj.force_term(nodes,obj.k) = obj.force_term(nodes,obj.k) +...
                        obj.corr*element_em_rates(index,1) * obj.sources.shapes(index,:)';
                    index=index+1;
                end
            elseif obj.k>=obj.k_frames(1)
                for ie=obj.sources.element_indexes
                    nodes=obj.mesh.elements(1:3,ie);
                    obj.force_term(nodes,obj.k) = obj.force_term(nodes,obj.k) +...
                        obj.corr*element_em_rates(index,2) * obj.sources.shapes(index,:)';
                    index=index+1;
                end
            end
        end
    end
end