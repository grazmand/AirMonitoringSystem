clear 
close all
[main_folder,~,~] = fileparts(mfilename('fullpath'));
cd(main_folder)
addpath(genpath(main_folder)); % adds to path the main folder and all its sub-folder

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
[street,long_array,long_max,List,buildpoly,Inbuildpoly,poly] = Handle_Street(main_folder);

