clear 

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

%% load and process mesh boundaries
load('./Mesh_Dir/border_map_1.mat');

%% domain
domain = Domain;