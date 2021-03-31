%% Sensor Timing

%%%% primi 33 min. partendo dalle 16 pm : 33 * 6 step temporali = 198 step
%%%% temporali

%%%% out{1}(1:71) -> sensors.timing(1:71) = 199:199 + 71 - 1 = 199:269

%%%% prima pausa 16:44:50/16:55:20 = 11 * 6 - 3 step temporali = 63 step
%%%% temporali -> 269:269 + 63 -1 = 269:331

%%%% out{1}(72:72+63-1=134) -> sensors.timing(72:72+63-1=134)=(332:332+63-1=394)

%%%% seconda pausa 17:05:40/17:11:30 = 6 * 6 - 1 = 35 step temporali -> (395:395+35-1=429)

%%%% out{1}(135:135+99=234) -> sensors.timing(135:234) = (430:430+99=529)

%%%% terza pausa 17:28:00/17:35:50 -> 7 * 6 + 5 = 47 step temporali -> (530:530+47-1=576)

%%%% out{1}(235:235+88=323) -> sensors.timing(235:323) = (577:577+88=665)

%%%% 4a ed ultima pausa 17:50:30/18:13:50 -> 23 * 6 + 2 = 140 step temporali -> (666:666+140-1=805)

%%%% out{1}(324:499) -> sensors.timing(324:499) = (806:806+176-1=981)

sensors.timing(1:71) = 199:269;
sensors.timing(72:134)=(332:394);
sensors.timing(135:234) = (430:529);
sensors.timing(235:323) = (577:665);
sensors.timing(324:499) = (806:981);

%% Select only measurements lying within borders

sensor_index = 1;

for is = 1:size( sensors.xy,1 )
    
    if inpolygon( sensors.xy(is,1),sensors.xy(is,2),[Mesh_Boundaries_X Mesh_Boundaries_X(1)],[Mesh_Boundaries_Y Mesh_Boundaries_Y(1)])
        sensors.labels(sensor_index) = is;
        sensor_index = sensor_index +1;
    end
    
end

%%%% Leave only geographic data lying within the borders
sensors.xy = sensors.xy(sensors.labels,1:2);

%%%% Leave only timing data lying within the borders
sensors.timing = sensors.timing(sensors.labels);

%%%% Check if CO2 measurements really lie within the borders
figure
pdeplot(Mesh_Nodes,Mesh_Edges,Mesh_Elements)
hold on
plot(sensors.xy(:,1),sensors.xy(:,2),'g*')

%% Draw only simulated CO2 measurements lying within the borders

sensor_index = 1;

for ip = 1:size(sensors.labels,2)
        
        sensors.simulated_mes(sensor_index) = ST(sensors.labels(ip),sensors.timing(sensor_index));
        sensor_index = sensor_index + 1;
        
end

%% Draw only real CO2 measurements lying within the borders

sensors.real_mes = num(sensors.labels,1)';

