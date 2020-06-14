function [emf_CO2] = emfactor_CO2(List, long_max, Mesh_Nodes, poly, area_poly, time)

pp = Mesh_Nodes;

%speed and flowrate
flowrate_red=(2800+1800)/2;
flowrate_orange=(1800+1200)/2;
flowrate_yellow=(1200+750)/2;
flowrate_green=(750+450)/2;
speed_red=(10+17)/2;
speed_orange=(17+23)/2;
speed_yellow=(23+30)/2;
speed_green=(30+40)/2;

%Calcolo dell'emission factor per ciascuna classe di veicoli,
%considerando come inquinante NOx

N_Park_Passenger_Car= 656758;
N_Park_HGV= 80929;
N_Park_mopeds= 150973;
N_Park_Bus= 1224;
N_Park_Tot=N_Park_Passenger_Car+N_Park_HGV+N_Park_mopeds+N_Park_Bus;
Perc_Pc=N_Park_Passenger_Car/N_Park_Tot;
Perc_HGV=N_Park_HGV/N_Park_Tot;
Perc_mopeds=N_Park_mopeds/N_Park_Tot;
Perc_Bus=N_Park_Bus/N_Park_Tot;
%EF for passenger cars
EF_Pc_red = 294 - 5.50 * speed_red + 0.0393 * speed_red^2 + 3513/speed_red;
EF_Pc_orange = 294 - 5.50 * speed_orange + 0.0393 * speed_orange^2 + 3513/speed_orange;
EF_Pc_yellow = 294 - 5.50 * speed_yellow + 0.0393 * speed_yellow^2 + 3513/speed_yellow;
EF_Pc_green = 294 - 5.50 * speed_green + 0.0393 * speed_green^2 + 3513/speed_green;
%EF for hgv
K_HGV=871;
A_HGV=-16;
B_HGV=0.143;
C_HGV=0;
D_HGV=0;
E_HGV=32031;
F_HGV=-5736;
EF_HGV_red=K_HGV+A_HGV*speed_red+B_HGV*speed_red^2+C_HGV*speed_red^3+D_HGV/speed_red+...
    E_HGV/speed_red^2+F_HGV/speed_red^3;
EF_HGV_orange=K_HGV+A_HGV*speed_orange+B_HGV*speed_orange^2+C_HGV*speed_orange^3+D_HGV/speed_orange+...
    E_HGV/speed_orange^2+F_HGV/speed_orange^3;
EF_HGV_yellow=K_HGV+A_HGV*speed_yellow+B_HGV*speed_yellow^2+C_HGV*speed_yellow^3+D_HGV/speed_yellow+...
    E_HGV/speed_yellow^2+F_HGV/speed_yellow^3;
EF_HGV_green=K_HGV+A_HGV*speed_green+B_HGV*speed_green^2+C_HGV*speed_green^3+D_HGV/speed_green+...
    E_HGV/speed_green^2+F_HGV/speed_green^3;
%EF for bus
K_Bus=679;
A_Bus=0;
B_Bus=0;
C_Bus=-0.00268;
D_Bus=9635;
E_Bus=0;
F_Bus=0;
EF_Bus_red=K_Bus+A_Bus*speed_red+B_Bus*speed_red^2+C_Bus*speed_red^3+D_Bus/speed_red+...
    E_Bus/speed_red^2+F_Bus/speed_red^3;
EF_Bus_orange=K_Bus+A_Bus*speed_orange+B_Bus*speed_orange^2+C_Bus*speed_orange^3+D_Bus/speed_orange+...
    E_Bus/speed_orange^2+F_Bus/speed_orange^3;
EF_Bus_yellow=K_Bus+A_Bus*speed_yellow+B_Bus*speed_yellow^2+C_Bus*speed_yellow^3+D_Bus/speed_yellow+...
    E_Bus/speed_yellow^2+F_Bus/speed_yellow^3;
EF_Bus_green=K_Bus+A_Bus*speed_green+B_Bus*speed_green^2+C_Bus*speed_green^3+D_Bus/speed_green+...
    E_Bus/speed_green^2+F_Bus/speed_green^3;
%EF for mopeds
EF_mop=27.3;
%EF totale without flowrate and average speed g/(veh*Km)
EF_TOT_RED=EF_Pc_red*Perc_Pc+EF_HGV_red*Perc_HGV+EF_Bus_red*Perc_Bus+EF_mop*Perc_mopeds;
EF_TOT_ORANGE=EF_Pc_orange*Perc_Pc+EF_HGV_orange*Perc_HGV+EF_Bus_orange*Perc_Bus+EF_mop*Perc_mopeds;
EF_TOT_YELLOW=EF_Pc_yellow*Perc_Pc+EF_HGV_yellow*Perc_HGV+EF_Bus_yellow*Perc_Bus+EF_mop*Perc_mopeds;
EF_TOT_GREEN=EF_Pc_green*Perc_Pc+EF_HGV_green*Perc_HGV+EF_Bus_green*Perc_Bus+EF_mop*Perc_mopeds;
%EF totale with flowrate and average speed in g/h*Km
EF_TOT_RED=EF_TOT_RED*flowrate_red;%*speed_red;
EF_TOT_ORANGE=EF_TOT_ORANGE*flowrate_orange;%*speed_orange;
EF_TOT_GREEN=EF_TOT_GREEN*flowrate_green;%*speed_green;
EF_TOT_YELLOW=EF_TOT_YELLOW*flowrate_yellow;%*speed_yellow;
%EF totale with flowrate and average speed in g/min*m
EF_TOT_RED = EF_TOT_RED/(60*1e+03);%*speed_red;
EF_TOT_ORANGE = EF_TOT_ORANGE/(60*1e+03);%*speed_orange;
EF_TOT_GREEN = EF_TOT_GREEN/(60*1e+03);%*speed_green;
EF_TOT_YELLOW = EF_TOT_YELLOW/(60*1e+03);%*speed_yellow;

%Inizializzazione emission factor
emf_CO2 = zeros(size(pp,2),1);
met = zeros(1,size(area_poly,2));

corr = 0.03;
hi = 10;

for i = 1:size(area_poly,2)
    
    met(i) = max(area_poly{i});
    
end

for j=1:size(poly,2)
    
    fprintf('-> poly occurence at number %d\n',j);
    
    for k=1:size(poly{j},2)
        
        if area_poly{j}(k) == 0
            
            area_poly{j}(k) = mean( met );
            
        end
        
        for i=1:size(pp,2)
            
            if inpolygon(pp(1,i),pp(2,i),poly{j}(3:6,k),poly{j}(7:10,k))==1
                if List{time}{j}(k,:) == [200 0 0]
                    
                    emf_CO2(i) = corr * EF_TOT_RED * long_max{j}(k) * 10^2/(hi * area_poly{j}(k)*...
                        10^4); %evaluetion in g/(m^3*min)
                    %                 emf_CO2(i)=corr*emf_NOx(i)/(10^9*60);%((10^9*60*60); %evaluetion in g/(m^3*min)
                elseif  List{time}{j}(k,:) == [255 170 0]
                    
                    emf_CO2(i) = corr * EF_TOT_ORANGE * long_max{j}(k)*10^2/(hi * area_poly{j}(k)*...
                        10^4);
                    %                 emf_CO2(i)=corr*emf_NOx(i)/(10^9*60);%(10^9*60*60);
                elseif List{time}{j}(k,:) == [255 255 0]
                    
                    emf_CO2(i) = corr * EF_TOT_YELLOW * long_max{j}(k)*10^2/(hi * area_poly{j}(k)*...
                        10^4);
                    %                 emf_CO2(i)=corr*emf_NOx(i)/(10^9*60);%((10^9*60*60);
                elseif List{time}{j}(k,:) == [215 0 0] | List{time}{j}(k,:) == [23 177 23]
                    
                    emf_CO2(i) = corr * EF_TOT_GREEN * long_max{j}(k)*10^2/(hi * area_poly{j}(k)*...
                        10^4);
                    %                 emf_CO2(i)=corr*emf_NOx(i)/(10^9*60);%((10^9*60*60);
                end
            end
            
            if emf_CO2(i) == inf
                
                disp ('-> error occurs due to inf dedection in emfactor_CO2')
                
            end
            
        end
        
        
    end
end

end




