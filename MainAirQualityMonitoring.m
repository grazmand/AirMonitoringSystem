clear all
close all

tic

%% include the directory path of the work folder
disp('-> include the directory path of the work folder')
mainFolder = 'C:\Users\grazi\Desktop\articolo Monitoraggio Ambientale\Codice per Articolo MA'; % Notice!! this path has to be changed according to the computer in use
setenv('ENSEMBLE_KALMAN_FILTER_HOME',mainFolder); % sets the main folder as a system environmental variable
addpath(genpath(mainFolder)); % adds to path the main folder and all its sub-folder

%% list of paths in use
disp('-> list of paths in use')
workSpaceFolder = 'C:\Users\grazi\Desktop\articolo Monitoraggio Ambientale\articolo MA temporary WSs'; % Notice!! also this path has to be changed to guarantee the computation goes forward in the right way
data_folder = strcat(mainFolder, '\save_data');
videoFolder = strcat(mainFolder, '\video');

%% load the decomposed geometry matrix of the area of Novoli
disp('-> load the decomposed geometry matrix of the area of Novoli')
load(strcat(mainFolder,'\decomposed geometry matrix\g.mat'));

%% set all simulation parameters
disp('-> set all simulation parameters')
%%%% total time steps
steps_tot = 1000;

%%%% set the video time parameters
col_step_start = 1;
col_step_centr = 100;
col_step_tot = steps_tot;

rate_video_1 = 5;
rate_video_2 = 5;
rate_video_3 = 5;

%%%% temporal steps which cause a change in environmental pollutant concentration
%%%% conditions
step_time = [ 1 13 ];

%%%% set the initial pollutant concentration
initial_pollutant_concentration = 400;
initial_pollutant_concentration_red = 400;
initial_pollutant_concentration_orange = 400;
initial_pollutant_concentration_yellow = 400;
initial_pollutant_concentration_green = 400;

%%%%%% Wind Speed
Wind_Speed = 0; %val in Km/h
Wind_Speed = Wind_Speed * ( 1e+3/( 60 * 6 ) ); %val in m/decasec.

%%%%%% Wind Speed Correction
Wind_Speed_Corr_Factor = 1e-1;

%%%%%% Wind Direction
Wind_Dir_Deg = 270 - 25;
Wind_Dir_Rad = degtorad( Wind_Dir_Deg );

%%%%%% Wind Direction Components
X_Wind_Dir = cos( Wind_Dir_Rad );
Y_Wind_Dir = sin( Wind_Dir_Rad );

%%%%%% Correction Factor
Diffusion_Corr_Factor = 1;
Roughness_Corr_Factor = 5;

%%%%%% Diffusion Parameters
Alpha = 1.381e-5 * Diffusion_Corr_Factor;
Alpha_Building = ( 1.381e-5 * Diffusion_Corr_Factor )/Roughness_Corr_Factor;

%%%%%% Wind Speed Vector
Wind_Speed_Vector = Wind_Speed_Corr_Factor * Wind_Speed * Alpha * ...
    [ X_Wind_Dir Y_Wind_Dir ];

%%%% boolean parameters to manage the saved/loaded data

loadData_triIndex = true; % load the index values of the mesh elements
loadData_sysDir = true;
saveWorkSpace = false;
loadMeshData = true;

%% generate the mesh
disp('-> generate the mesh')
if ~loadMeshData
    
    Hgrad = 1.9999999999; % this parameter is the mesh growth rate, a real number strictly between 1 and 2
    
    [Mesh_Nodes,Mesh_Edges,Mesh_Elements] = initmesh(g,'Hgrad',Hgrad);
    
else
    
    load(fullfile(data_folder,'meshData.mat'));
    
end

figure
pdeplot(Mesh_Nodes,Mesh_Edges,Mesh_Elements); % add ",'NodeLabels','on');" if you want the node labels to be shown ('computational expensive in terms of gpu')

%% load the boundaries of the area of Novoli
disp('-> load the boundaries of the area of Novoli')
%%%% load and process mesh boundaries
load(strcat(mainFolder,'\Mesh_Dir\border_map_1.mat'));
Mesh_Boundaries = border_map_1;
clear border_map_1;
Mesh_Boundaries_X = zeros(1,size(Mesh_Boundaries,2));
Mesh_Boundaries_Y = zeros(1,size(Mesh_Boundaries,2));
Mesh_Boundaries_Coordinates = zeros(2,size(Mesh_Boundaries,2));
for i = 1:size(Mesh_Boundaries,2)
    Mesh_Boundaries_X(i) = Mesh_Boundaries(i).Position(1);
    Mesh_Boundaries_Y(i) = Mesh_Boundaries(i).Position(2);
    Mesh_Boundaries_Coordinates(:,i) = [Mesh_Boundaries_X(i) Mesh_Boundaries_Y(i)];
end
Domain_Geometry_Description = [2;size(Mesh_Boundaries,2);...
    Mesh_Boundaries_X';Mesh_Boundaries_Y'];
Mesh_Boundaries_Coordinates_Closed = [Mesh_Boundaries_Coordinates Mesh_Boundaries_Coordinates(:,1)]';
Domain_Geometry_Description_Decomposition = decsg(Domain_Geometry_Description);

%%%% display boundaries
figure;
plot([Mesh_Boundaries_X Mesh_Boundaries_X(1)],[Mesh_Boundaries_Y Mesh_Boundaries_Y(1)]);

%% build mesh object
disp('-> build mesh object')
Mesh.xy(1,:) = Mesh_Nodes(1,:);
Mesh.xy(2,:) = Mesh_Nodes(2,:);
Mesh.ele(1,:) = 3 * ones(size(Mesh_Elements,2),1)';
Mesh.ele(2,:) = Mesh_Elements(1,:);
Mesh.ele(3,:) = Mesh_Elements(2,:);
Mesh.ele(4,:) = Mesh_Elements(3,:);
[Mesh] = BuildMeshStruct_C_mod_1(Mesh,Mesh_Boundaries_Coordinates_Closed,...
    Mesh_Nodes,Mesh_Elements);

%% set the boundary conditions
disp('-> set the boundary conditions')
bound_nodes = Mesh.border_nodes;

Dirichlet_nodes = Mesh.border_nodes;

for iedge = 1:size(Domain_Geometry_Description_Decomposition,2)
    
    boundary.Dirichlet = iedge;
    
end

for edge = 1:size(Mesh.boundPoints,2)
    
    bound_nodes = union(bound_nodes,Mesh.boundPoints{edge});
    
end

%% set the pollutant source rate
disp('-> set the pollutant source rate')
[street , long_array , long_max, List, buildpoly, Inbuildpoly, poly] = Handle_Street(mainFolder);

emf_CO2 = zeros(size(Mesh_Nodes,2),size(step_time,2));

load(strcat(mainFolder,'\Area_Poly\area_poly.mat'));

index_time = 1;

for t = step_time
    
    emf_CO2(:,index_time) = emfactor_CO2(List, long_max, Mesh_Nodes, poly, area_poly, t);
    
    if ~loadData_triIndex
        
        [TriStreetIndex{index_time},TriStreetIndexRed{index_time},TriStreetIndexOrange{index_time},TriStreetIndexYellow{index_time},TriStreetIndexGreen{index_time}] =...
            triStreetIndexEngine(poly,Mesh_Nodes,Mesh_Elements,List,t,data_folder);
        
    else
        
        load(fullfile(data_folder,'tri.mat'));
        
    end
    
    index_time = index_time + 1;
    
end

if saveWorkSpace
    save('bck_up_wspace_co2_sim');
end

u_f = zeros(size(Mesh_Nodes,2),size(step_time,2));

nele = size(Mesh_Elements,2);

[u_f, PointInStreetRed, PointInStreetOrange, PointInStreetYellow, PointInStreetGreen] =...
    source_generator_mod(u_f, Mesh, step_time, nele, TriStreetIndexRed, TriStreetIndexOrange, TriStreetIndexYellow, TriStreetIndexGreen,...
    initial_pollutant_concentration, initial_pollutant_concentration_red, initial_pollutant_concentration_orange,...
    initial_pollutant_concentration_yellow, initial_pollutant_concentration, Mesh_Elements, emf_CO2);

%% assemble continuos time system matrices
disp('-> assemble continuos time system matrices')
nnode = size(Mesh_Nodes,2);

S  = zeros(nnode,nnode);
T  = zeros(nnode,nnode);

switch_case = 3;

for ie = 1:nele
    
    %------------Builds the element matrices
    [Se,Te,Shape,SVe] = EleN_2d_diffusion_adv( Mesh, ie, Wind_Speed_Vector, switch_case);
    
    Mesh.shape{ie} = Shape;
    
    %------------Builds the global matrices
    S (Mesh.ele(2:4,ie), Mesh.ele(2:4,ie)) =...
        S (Mesh.ele(2:4,ie), Mesh.ele(2:4,ie)) + Alpha * (Mesh.elab(ie))*Se + SVe;
    
    T (Mesh.ele(2:4,ie), Mesh.ele(2:4,ie)) =...
        T (Mesh.ele(2:4,ie), Mesh.ele(2:4,ie)) + Te;
    
end

%% compute discrete time system matrices
disp('-> compute discrete time system matrices')

DeltaT_sim = 10; % sampling interval (Simulator)

state_sys = setdiff((1:size(Mesh.xy,2)),bound_nodes);

S_Dirichlet = S(state_sys,Dirichlet_nodes);

S_state = S(state_sys,state_sys);
S_state = sparse(S_state);

clear S;

M_state = T(state_sys,state_sys);
M_state = sparse(M_state);

clear T;

Mat2 = M_state/DeltaT_sim;

Mat3 = Mat2 + S_state;

clear S_state;

%% compute the state of the system over the time
disp('-> compute the state of the system over the time')

T_zero = zeros(1,size(Mesh_Nodes,2));

for i = 1:size(Mesh_Nodes,2)
    
    T_zero(i) = initial_pollutant_concentration;
    
end

index_uf = 1;

%%%% Set initial state conditions (U0 & U0_sys)

U0 = zeros(length(state_sys),1) + T_zero(state_sys)';
U0_sys = zeros(size(Mesh_Nodes,2),1) + T_zero';

%% Set boundary condition initial state

u_Dirichlet_0 = U0_sys(Dirichlet_nodes); 
u_Dirichlet_k = u_Dirichlet_0;

Utot = zeros(length(state_sys),steps_tot);

u_f = u_f(state_sys,:);

if ~loadData_sysDir
    
    sys_dir = getInnerNodes(Mesh_Elements,Dirichlet_nodes);
    
else
    
    load(fullfile(data_folder,'sys_dir.mat'));
    
end

if saveWorkSpace
    save('bck_up_wspace_co2_sim');
end

%% Sensor Data acquisition

disp('-> Sensor data acquisition')

run('sensor_data_coordinates_acquisition.m');

%% Calculate shape functions for each sensor point

ST = zeros(size(sensors.xy,1),steps_tot);

sp_vertices = zeros(size(sensors.xy,1),Mesh.ele(1,1));
sp_shape = zeros(size(sensors.xy,1),Mesh.ele(1,1));

for point = 1:size(sensors.xy,1)
    
    fprintf( 'sensor shape computation n. %d/%d \n',point, size(sensors.xy,1));
    
    for ie = 1:size(Mesh.ele,2)
        
        IN = inpolygon(sensors.xy(point,1), sensors.xy(point,2), Mesh.xy(1, [Mesh.ele(2:4,ie);Mesh.ele(2,ie)]),...
            Mesh.xy(2, [Mesh.ele(2:4,ie);Mesh.ele(2,ie)]));
        ON = isPointOnPolyline(sensors.xy(point,:), Mesh.xy(:, [Mesh.ele(2:4,ie);Mesh.ele(2,ie)])',1e-09);
        
        if(IN) || (ON)
            % Calcolo N_E = [N_i N_j N_k] = matrice delle funzioni di forma del
            % generico elemento triangolare E di vertici i,j,k
            
            sp_vertices(point,:) = Mesh.ele(2:4,ie);
            sp_shape(point,:) = Get_shapeN(Mesh,ie,sensors.xy(point,:));
            
            break
        end
    end
    
end

sp_shape = abs( sp_shape );

%%%% Start with the State System Computation

for k = 1:steps_tot
    
    if ismember(k,step_time)
        u_f_time = u_f(:,index_uf);
        index_uf = index_uf + 1;
    end
    
    U1 = (Mat3)\((Mat2) * U0 + u_f_time - S_Dirichlet * u_Dirichlet_k);
    
    U0 = U1;
    
    Utot(state_sys,k) = U1;
    
    u_Dirichlet_k = Utot(sys_dir,k);
    
    Utot(Dirichlet_nodes,k) = Utot(sys_dir,k);
    
    for point = 1:size(sensors.xy,1)
        if sp_vertices(point,:) ~= [ 0 0 0 ]
            ST(point,k) = sp_shape(point,:) * Utot(sp_vertices(point,:),k);
        else
            ST(point,k) = 0;
        end
    end
    
end

%%%% End with the State System Computation

%% display the time-variant dynamics of the system on screen
disp('-> display the time-variant dynamics of the system on screen')
Minimum = min(min(Utot));
Maximum = max(max(Utot));
levels = Minimum:(max(max(Utot))-min(min(Utot)))/100:Maximum; % levels of isolines (500 fixed values for each time, ranging from the min and the max of the field values)

Naux_Param = 150;
Naux = Naux_Param;
Xg = min(Mesh.xy(1,:)):(max(Mesh.xy(1,:))-min(Mesh.xy(1,:)))/Naux:max(Mesh.xy(1,:));
Yg = min(Mesh.xy(2,:)):(max(Mesh.xy(2,:))-min(Mesh.xy(2,:)))/Naux:max(Mesh.xy(2,:));
[XI,YI] = meshgrid(Xg,Yg);

for k = col_step_start:col_step_centr:col_step_tot
    ZI{k} = zeros(length(XI),length(YI));
end

ZI_0 = zeros(length(XI),length(YI));

for k = col_step_start:col_step_centr:col_step_tot
    
    disp('-> mappatura griglia');
    
    fprintf( 'occurence n. %d\n',k );
    
    for ii=1:size(Mesh.ele,2)
        xx = [Mesh.xy(1, Mesh.ele(2,ii)) Mesh.xy(1, Mesh.ele(3,ii)) Mesh.xy(1, Mesh.ele(4,ii))];
        yy = [Mesh.xy(2, Mesh.ele(2,ii)) Mesh.xy(2, Mesh.ele(3,ii)) Mesh.xy(2, Mesh.ele(4,ii))];
        IN = inpolygon(XI, YI, xx, yy);
        
        points = find(IN);
        
        for i = 1:length(points)
            N(i,:) = Get_shapeN (Mesh,ii,[XI(points(i)) YI(points(i))]);
            ZI{k}(points(i)) = N(i,:)*[Utot(Mesh.ele(2,ii),k); Utot(Mesh.ele(3,ii),k); Utot(Mesh.ele(4,ii),k)];
            if k==1
                ZI_0(points(i)) = N(i,:)*[U0_sys(Mesh.ele(2,ii)); U0_sys(Mesh.ele(3,ii)); U0_sys(Mesh.ele(4,ii))];
            end
        end
    end
    
end

if saveWorkSpace
    save('bck_up_wspace_co2_sim');
end

%%%% Satellite picture

load(strcat(mainFolder,'\geo_map\geomap_data.mat'));

xxx = zeros(1,size(lat,2));
yyy = zeros(1,size(lat,2));

for i = 1:size(lat,2)
    
    xxx(i) = (lon(i)-11.227) * 1000 - 0.02;
    yyy(i) = (lat(i)-43.790) * 1000 + 4.7;
    
end

yyy = -yyy;

%%%% video
disp('-> video time')
video_Sim_CO2_mod(rate_video_2,col_step_start,col_step_centr,col_step_tot,Utot,xxx,yyy,M,Mcolor,XI,YI,ZI,videoFolder);

close all

toc