classdef EmFactor < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        time TimeT
        % los velocities in Km/h
        v_los_a=52;
        v_los_b=37;
        v_los_c=27;
        v_los_d=22;
        % vehicle class probabilities
        p_passenger_cars {mustBeInRange(p_passenger_cars,0,1)}=0.6
        p_mopeds {mustBeInRange(p_mopeds,0,1)}=0.3
        p_trucks{mustBeInRange(p_trucks,0,1)}=0.08
        p_urban_buses{mustBeInRange(p_urban_buses,0,1)}=0.02
        em_factors double
    end
    
    methods
        function em_factor(obj ,vals)
            props = {'sources'};
            obj.set(props, vals)
            obj.check_vehicle_probs()
            obj.conv_v_los()
        end
        
        function conv_v_los(obj)
            % conv Km/h in m/(sec*deltaT)
            conv=10000*obj.time.dt.value/3600;
            obj.v_los_a=obj.v_los_a*conv;
            obj.v_los_b=obj.v_los_b*conv;
            obj.v_los_c=obj.v_los_c*conv;
            obj.v_los_d=obj.v_los_d*conv;
        end
        
        function check_vehicle_probs(obj)
            sum=obj.p_mopeds+obj.p_passenger_cars+obj.p_trucks+obj.p_urban_buses;
            if sum~=1
                error('sum of probabilities must be equals to 1')
            end
        end
    end
end