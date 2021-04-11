classdef EmFactor < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        dt TimeDiscretizationStep
        % los velocities in Km/h
        v_los_a=52;
        v_los_b=37;
        v_los_c=27;
        v_los_d=22;
        % vehicle class probabilities
        p_passenger_cars double {mustBeInRange(p_passenger_cars,0,1)}=0.6
        p_mopeds double {mustBeInRange(p_mopeds,0,1)}=0.3
        p_trucks double {mustBeInRange(p_trucks,0,1)}=0.08
        p_urban_buses double {mustBeInRange(p_urban_buses,0,1)}=0.02
    end
    
    methods
        function em_factor(obj)
            obj.check_vehicle_probs()
        end
        function check_vehicle_probs(obj)
            sum=obj.p_mopeds+obj.p_passenger_cars+obj.p_trucks+obj.p_urban_buses;
            if abs(sum-1)>1e-15
                error('sum of probabilities must be equals to 1')
            end
        end
    end
end