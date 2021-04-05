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

%% simulator video folder
videoFolderName = sprintf('%s/simulator/video', data_folder);
mkdir(videoFolderName)

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

tlc1=false;
%% handle road data
if tlc1
    [street,List,buildpoly,Inbuildpoly,roads_poly] = Handle_Street(main_folder);
    roads=Roads;
    roads.set_rgb_list({List});
    roads.structures({roads_poly,mesh})
    roads.plot_blocks(true)
    save('data/roads.mat','roads')
else
    load('data/roads.mat')
end

medium = Medium;
medium.medium({1e-6})

fem = FemModel;
fem.fem_model({mesh,medium,bc})

sources = Sources;
sources.sources({'road_sources',roads,mesh,fem,0.001})
sources.plot_sources(true)

ft = ForceTerm;
ft.forceTerm({'FT',sources,time,mesh})

ds = DynamicSystem;
ds.dynamicSystem({fem,mesh,ft,0})
ds.setState()

%% dynamic field
nodes_data_ds = ds.state;
df = DynamicField;
df.dynamicField({nodes_data_ds,ds,1,20,1000,videoFolderName});
df.plotField(true, true)
VideoManager.videoMaker(videoFolderName, '*.png', 'field.avi', true);

%% save data
if false
    save(strcat(data_folder,'/data.mat'))
end



