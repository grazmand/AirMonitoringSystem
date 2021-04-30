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
dt=TimeDiscretizationStep;
dt.time_discretization_step({0.01/2})

%% time
time=TimeT;
time.time({5,dt})
time.set_time

%% domain
domain=RectangularDomain;
domain.rec_domain({-30,50,-30,50})
domain.plot_domain(true)

%% mesh
mesh=RectangularDomainMesh;
mesh.mesh({'mesh',1.5,domain})
% good elementh length for analytical solution is 1 m
mesh.plot_mesh(true)

%% scenario
scenario = Scenario;
scenario.scenario({'dirichlet'})

%% bc
bc=RectangularDomainBoundaryConditions;
bc.boundary_conditions({scenario,mesh})
bc.checkBoundaryConditions(true)

%% medium
medium=Medium;
speed=[5 5]; % u.m. m/sec.
d_rate=5;
medium.medium({d_rate,speed})

%% fen model
fem = RectangularDomainFemModel;
fem.fem_model({mesh,medium,bc})

%% source
source=ImpulsiveSource;
source.source({'source','static',time,1,0,0,fem});
source.checkWaveForm(true)

%% force term
ft=StaticSingleSourceForceTerm;
ft.source_force_term({'ft',source})

%% dynamic system
ds=RectangularDomainDynamicSystem;
ds.dynamicSystem({time,fem,mesh,ft,0,'gaussian',6,'static'})
ds.setState()

%% sensor
s1=RectangularDomainSensor;
s1.setProperties({'s1',time,10,10,mesh,ds});
s1.viewSignalForm(true);

%% dynamic field
if true
    nodes_data_ds=ds.state;
    df=RectangularDomainDynamicField;
    n_frame=15;
    df.dynamicField({nodes_data_ds,ds,time.time_steps(1),round((time.time_steps(end)-time.time_steps(1))/n_frame),time.time_steps(end),videoFolderName});
    df.plotField(true, true)
    VideoManager.videoMaker(videoFolderName, '*.png', 'field.avi', true);
end
