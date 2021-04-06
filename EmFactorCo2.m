classdef EmFactorCo2<EmFactor
    properties (Constant)
        type string='co2'
    end
    
    properties (SetAccess=private,GetAccess=public)
        ef_los_a
        ef_los_b
        ef_loc_c
        ef_los_d
    end
    
    methods
        function set_ef_los_a(obj)
            
        end
    end
    methods (Static)
        function ef_los=set_ef_los(V,p_pc,p_t,p_m,p_ub)
            ef_los=p_pc*EmFactorCo2.set_ef_passenger_cars(V)+...
                p_t*EmFactorCo2.set_ef_passenger_cars(V)+...
                p_m*EmFactorCo2.set_ef_passenger_cars(V)+...
                p_ub*EmFactorCo2.set_ef_passenger_cars(V);
        end
        function ef_passenger_cars=set_ef_passenger_cars(V)
            ef_passenger_cars=231-3.62*V+0.0263*V^2+2526/V;
        end
        function ef_trucks=set_ef_trucks(V)
            K=110;
            a=0;
            b=0;
            c=0.000375;
            
            ef_trucks=231-3.62*V+0.0263*V^2+2526/V;
        end
        function ef_passenger_cars=set_ef_passenger_cars(V)
            ef_passenger_cars=231-3.62*V+0.0263*V^2+2526/V;
        end
        function ef_passenger_cars=set_ef_passenger_cars(V)
            ef_passenger_cars=231-3.62*V+0.0263*V^2+2526/V;
        end
    end
    
end

