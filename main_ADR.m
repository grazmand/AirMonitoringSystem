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

%% dt
dt = TimeDiscretizationStep;
dt.time_discretization_step({0.01})

%% time
time = TimeT;
time.time({3,dt})
time.set_time

%% domain
domain=RectangularDomain;
domain.rec_domain({-30,50,-50,50})
domain.plot_domain(true)

%% mesh
mesh=RectangularDomainMesh;
mesh.mesh({'mesh',2.5,domain})
mesh.plot_mesh(true)

%% scenario
scenario = Scenario;
scenario.scenario({'neumann'})

%% bc
bc = RectangularDomainBoundaryConditions;
bc.boundary_conditions({scenario,mesh})
bc.checkBoundaryConditions(true)

%% medium
medium = Medium;
d_factor=1e0;
medium.medium({0,[10 0]})

%% fen model
fem = RectangularDomainFemModel;
fem.fem_model({mesh,medium,bc})

%% dynamic system
ds = RectangularDomainDynamicSystem;
ds.dynamicSystem({time,fem,mesh,0,'gaussian','static'})
ds.setState()

if true
    %% dynamic field
    nodes_data_ds = ds.state;
    df = RectangularDomainDynamicField;
    n_frame=5;
    df.dynamicField({nodes_data_ds,ds,time.time_steps(1),round((time.time_steps(end)-time.time_steps(1))/n_frame),time.time_steps(end),videoFolderName});
    df.plotField(true, true)
    VideoManager.videoMaker(videoFolderName, '*.png', 'field.avi', true);
end
