clear
close all
[main_folder,~,~] = fileparts(mfilename('fullpath'));
cd(main_folder)
addpath(genpath(main_folder)); % adds to path the main folder and all its sub-folder

%% current date
currDate = strrep(datestr(datetime), ':', '_');
fprintf('---------air quality monitoring system at %s---------\n',currDate)

%% data folder
data_folder = sprintf('data/sim_%s', currDate);
mkdir(data_folder)

if false
    
    %% load the decomposed geometry matrix of the area of Novoli
    disp('-> load the decomposed geometry matrix of the area of Novoli')
    load('./decomposed geometry matrix/g.mat');
    
    %% dt
    dt = TimeDiscretizationStep;
    dt.time_discretization_step({0.001})
    
    %% time
    time = TimeT;
    time.time({1,dt})
    time.set_time
    
    %% load domain boundary
    load('./borders/coordinates_data.mat');
    %
    % data : Mesh_Boundaries_Coordinates is a matrix 2xN containig boundary
    % coordinates
    %
    border_coordinates = Mesh_Boundaries_Coordinates';
    
    %% domain
    domain = Domain;
    domain.domain({'domain',border_coordinates,g})
    domain.plot_domain(true)
    
    %% mesh
    mesh=Mesh;
    mesh.mesh({'mesh',10,domain})
    mesh.plot_mesh(true)
    
    %% check boundaries alignment
    run('check_boundary_alignment.m')
    
    %% scenario
    scenario = Scenario;
    scenario.scenario({'dirichlet'});
    
    %% bc
    bc = BoundaryConditions;
    bc.boundary_conditions({scenario,mesh,boundary_counterclockwiseNodeIndexes});
    bc.checkBoundaryConditions(true)
    
    %% handle road data
    [street,long_array,long_max,List,buildpoly,Inbuildpoly,roads_poly] = Handle_Street(main_folder);
    roads=Roads;
    roads.set_rgb_list({List});
    roads.structures({roads_poly,mesh})
    roads.plot_blocks(true)
    
end

load('data/sim_02-Apr-2021 02_33_37/data.mat')

%% save data
if false
save(strcat(data_folder,'/data.mat'))
end



