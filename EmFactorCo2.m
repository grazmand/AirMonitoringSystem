classdef EmFactorCo2<EmFactor
    properties (Constant)
        type string='co2'
    end
    properties (SetAccess=private,GetAccess=public)
        ef_los_a double {mustBeScalarOrEmpty}
        ef_los_b double {mustBeScalarOrEmpty}
        ef_loc_c double {mustBeScalarOrEmpty}
        ef_los_d double {mustBeScalarOrEmpty}
    end
    methods
        function set_ef_los_a(obj)
            Va=obj.v_los_a;
            p_pc=obj.p_passenger_cars;
            p_m=obj.p_mopeds;
            p_t=obj.p_trucks;
            p_ub=obj.p_urban_buses;
            % ef in g/Km
            obj.ef_los_a=set_ef_los(Va,p_pc,p_t,p_m,p_ub);
            % ef in (g*veh.)/(Km*h)
            obj.ef_los_a=obj.ef_los_a*obj.f_los_a;
            % ef in (g*veh.)/(m*sec.*deltaT)
            conv=obj.dt.value/(1000*3600);
            obj.ef_los_a=conv*obj.ef_los_a;
        end
        function set_ef_los_b(obj)
            % ef in g/Km
            Vb=obj.v_los_b;
            p_pc=obj.p_passenger_cars;
            p_m=obj.p_mopeds;
            p_t=obj.p_trucks;
            p_ub=obj.p_urban_buses;
            % ef in g/Km
            obj.ef_los_b=set_ef_los(Vb,p_pc,p_t,p_m,p_ub);
            % ef in (g*veh.)/(Km*h)
            obj.ef_los_b=obj.ef_los_b*obj.flow.a;
            % ef in (g*veh.)/(m*sec.*deltaT)
            conv=obj.dt.value/(1000*3600);
            obj.ef_los_b=conv*obj.ef_los_b;
        end
        function set_ef_los_c(obj)
            % ef in g/Km
            Vc=obj.v_los_c;
            p_pc=obj.p_passenger_cars;
            p_m=obj.p_mopeds;
            p_t=obj.p_trucks;
            p_ub=obj.p_urban_buses;
            % ef in g/Km
            obj.ef_los_c=set_ef_los(Vc,p_pc,p_t,p_m,p_ub);
            % ef in (g*veh.)/(Km*h)
            obj.ef_los_c=obj.ef_los_c*obj.flow.a;
            % ef in (g*veh.)/(m*sec.*deltaT)
            conv=obj.dt.value/(1000*3600);
            obj.ef_los_c=conv*obj.ef_los_c;
        end
        function set_ef_los_d(obj)
            % ef in g/Km
            Vd=obj.v_los_d;
            p_pc=obj.p_passenger_cars;
            p_m=obj.p_mopeds;
            p_t=obj.p_trucks;
            p_ub=obj.p_urban_buses;
            % ef in g/Km
            obj.ef_los_d=set_ef_los(Vd,p_pc,p_t,p_m,p_ub);
            % ef in (g*veh.)/(Km*h)
            obj.ef_los_d=obj.ef_los_d*obj.flow.a;
            % ef in (g*veh.)/(m*sec.*deltaT)
            conv=obj.dt.value/(1000*3600);
            obj.ef_los_d=conv*obj.ef_los_d;
        end
    end
    methods (Static)
        function ef_los=set_ef_los(V,p_pc,p_t,p_m,p_ub)
            ef_los=p_pc*EmFactorCo2.set_ef_passenger_cars(V)+...
                p_t*EmFactorCo2.set_ef_trucks(V)+...
                p_m*27.3+...
                p_ub*EmFactorCo2.set_ef_urban_buses(V);
        end
        function ef_passenger_cars=set_ef_passenger_cars(V)
            ef_passenger_cars=231-3.62*V+0.0263*V^2+2526/V;
        end
        function ef_trucks=set_ef_trucks(V)
            k=110;
            a=0;
            b=0;
            c=0.000375;
            d=8702;
            e=0;
            f=0;
            ef_trucks=k+a*V+b*V^2+c*V^3+d/V+e/V^2+f/V^3;
        end
        function ef_urban_buses=set_ef_urban_buses(V)
            k=679;
            a=0;
            b=0;
            c=-0.00268;
            d=9635;
            e=0;
            f=0;
            ef_urban_buses=k+a*V+b*V^2+c*V^3+d/V+e/V^2+f/V^3;
        end
    end
end

