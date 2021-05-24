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

%% sensor data folder
sensor_folder = sprintf('%s/sensor_folder', data_folder);
mkdir(sensor_folder)

%% picture folder
image_folder = sprintf('%s/pics', data_folder);
mkdir(image_folder)

%% simulator video folder
videoFolderName = sprintf('%s/simulator/video', data_folder);
mkdir(videoFolderName)

%% dt
dt=TimeDiscretizationStep;
dt.time_discretization_step({0.01/2})

%% time
time=TimeT;
time.time({20,dt})
time.set_time

%% domain
domain=RectangularDomain;
domain.rec_domain({-30,50,-30,50})
domain.plot_domain(true)

%% mesh
element_length=1;
mesh=RectangularDomainMesh;
mesh.mesh({'mesh',element_length,domain})
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
speed=[2 2]; % u.m. m/sec.
d_rate=0.1;
medium.medium({d_rate,speed})

%% fen model
fem=RectangularDomainFemModel;
fem.fem_model({mesh,medium,bc})

%% sources
source1=Source;
source1.source({'source1','static','gaussian',time,1,0,0,fem});
source1.checkWaveForm(true)

source2=Source;
source2.source({'source2','static','gaussian',time,1,20,20,fem});
source2.checkWaveForm(true)

%% force terms
ft1=StaticSingleSourceForceTerm;
ft1.source_force_term({'ft1',source1})

% ft2=StaticSingleSourceForceTerm;
% ft2.source_force_term({'ft2',source2})

ft=ft1.force_term;

%% dynamic system
ds=RectangularDomainDynamicSystem;
ds.dynamicSystem({time,fem,mesh,ft,0,'constant',6,'static'})
ds.setState()

%% sensor
s1=RectangularDomainSensor;
s1.setProperties({'s1',time,0,0,mesh,ds});
s1.viewSignalForm(true);

%% dynamic field
tlc_field=true;
if tlc_field
    nodes_data_ds=ds.state;
    df=RectangularDomainDynamicField;
    n_frame=7;
    df.dynamicField({nodes_data_ds,ds,time.time_steps(1),round((time.time_steps(end)-time.time_steps(1))/n_frame),time.time_steps(end),videoFolderName});
    df.plotField(true, true)
    VideoManager.videoMaker(videoFolderName, '*.png', 'field.avi', true);
end

ssf_path=sprintf('%s/l%d_sensor_signal_form.mat',sensor_folder,element_length);
ssf=s1.signalForm;
save(ssf_path,'ssf')