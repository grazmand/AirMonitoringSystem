classdef SourcesCO2 < Sources
    properties (SetAccess = private, GetAccess = public)
        ef EmFactorCo2
        element_em_factors double
        element_em_rates double
    end
    
    properties (Constant)
        type string='co2'
    end
    
    methods
        function sources_co2(obj)
            obj.ef=EmFactorCo2;
            obj.ef.em_factor()
            obj.ef.set_ef_los_co2()
            obj.set_element_em_factors()
            obj.set_element_em_rates()
        end
        function set_element_em_factors(obj)
            % em factors in g/Km
            for f=1:size(obj.element_poly_los,2)
                for ie=1:size(obj.element_poly_los,1)
                    if ismember(obj.element_poly_los(ie,f),'green_A')
                        obj.element_em_factors(ie,f)=obj.ef.ef_los_a;
                    elseif ismember(obj.element_poly_los(ie,f),'yellow_B')
                        obj.element_em_factors(ie,f)=obj.ef.ef_los_b;
                    elseif ismember(obj.element_poly_los(ie,f),'orange_C')
                        obj.element_em_factors(ie,f)=obj.ef.ef_los_c;
                    elseif ismember(obj.element_poly_los(ie,f),'red_D')
                        obj.element_em_factors(ie,f)=obj.ef.ef_los_d;
                    end
                end
            end
        end
        function set_element_em_rates(obj)
            % em rates in (g*veh.)/(Km*h)
            for f=1:size(obj.element_em_factors,2)
                for ie=1:size(obj.element_em_factors,1)
                    if ismember(obj.element_poly_los(ie,f),'green_A')
                        obj.element_em_rates(ie,f)=obj.element_em_factors(ie,f)*obj.f_los_a;
                        % em rates in (g*veh.)/(m*sec)
                        obj.element_em_rates(ie,f)=obj.element_em_rates(ie,f)/(1000*3600);
                        % em rates in (g*veh.)/(m^3*sec)
                        obj.element_em_rates(ie,f)=obj.element_em_rates(ie,f)/(obj.fem.areas(obj.element_indexes(ie)));
                    elseif ismember(obj.element_poly_los(ie,f),'yellow_B')
                        obj.element_em_rates(ie,f)=obj.element_em_factors(ie,f)*obj.f_los_b;
                        % em rates in (g*veh.)/(m*sec)
                        obj.element_em_rates(ie,f)=obj.element_em_rates(ie,f)/(1000*3600);
                        % em rates in (g*veh.)/(m^3*sec)
                        obj.element_em_rates(ie,f)=obj.element_em_rates(ie,f)/(obj.fem.areas(obj.element_indexes(ie)));
                    elseif ismember(obj.element_poly_los(ie,f),'orange_C')
                        obj.element_em_rates(ie,f)=obj.element_em_factors(ie,f)*obj.f_los_c;
                        % em rates in (g*veh.)/(m*sec)
                        obj.element_em_rates(ie,f)=obj.element_em_rates(ie,f)/(1000*3600);
                        % em rates in (g*veh.)/(m^3*sec)
                        obj.element_em_rates(ie,f)=obj.element_em_rates(ie,f)/(obj.fem.areas(obj.element_indexes(ie)));
                    elseif ismember(obj.element_poly_los(ie,f),'red_D')
                        obj.element_em_rates(ie,f)=obj.element_em_factors(ie,f)*obj.f_los_d;
                        % em rates in (g*veh.)/(m*sec)
                        obj.element_em_rates(ie,f)=obj.element_em_rates(ie,f)/(1000*3600);
                        % em rates in (g*veh.)/(m^3*sec)
                        obj.element_em_rates(ie,f)=obj.element_em_rates(ie,f)/(obj.fem.areas(obj.element_indexes(ie)));
                    end
                end
            end
        end
    end
end