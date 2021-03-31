clear 
close all
[main_folder,~,~] = fileparts(mfilename('fullpath'));
cd(main_folder)

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

%% load domain
load('./borders/coordinates_data.mat');
border_coordinates = Mesh_Boundaries_Coordinates';
Mesh_Boundaries_X = Mesh_Boundaries_Coordinates(1,:);
Mesh_Boundaries_Y = Mesh_Boundaries_Coordinates(2,:);
Domain_Geometry_Description = [2;size(Mesh_Boundaries_Coordinates,2);...
    Mesh_Boundaries_X';Mesh_Boundaries_Y'];
Mesh_Boundaries_Coordinates_Closed = [Mesh_Boundaries_Coordinates Mesh_Boundaries_Coordinates(:,1)]';
Domain_Geometry_Description_Decomposition = decsg(Domain_Geometry_Description);
clear Mesh_Boundaries_Coordinates

%% domain
domain = Domain;
domain.domain({'domain',border_coordinates,g})
domain.plot_domain(true)

%% mesh
mesh=Mesh;
mesh.mesh({'mesh',10,domain})
mesh.plot_mesh(true)

%% scenario
scenario = Scenario;
scenario.scenario({'dirichlet'});

%% bc
bc = BoundaryConditions;
bc.boundary_conditions({scenario,mesh});
bc.checkBoundaryConditions(true)