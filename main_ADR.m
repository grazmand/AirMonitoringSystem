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
total_time=30; %um in sec.
time=TimeT;
time.time({total_time,dt})
time.set_time

%% domain
domain=RectangularDomain;
domain.rec_domain({-30,50,-30,50})
domain.plot_domain(true)

%% mesh
element_length=2;
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
speed=[0.5 0.2]; % u.m. m/sec.
d_rate=2;
medium.medium({d_rate,speed})

%% fen model
fem=RectangularDomainFemModel;
fem.fem_model({mesh,medium,bc})

n_sources=40;
ft=zeros(mesh.node_size_number,1);
for i=1:n_sources
    
sourcei=Source;
sourcei.source({'sourcei','static','gaussian',time,1,-20+i,-20+i,fem,10+(i-20)*0.25,...
    1.5+i/40,0.3+i/100});    

fti=StaticSingleSourceForceTerm;
fti.source_force_term({'fti',sourcei})

ft=ft+fti.force_term;
end
% %% sources
% source1=Source;
% source1.source({'source1','static','gaussian',time,1,-20,-20,fem});
% source1.checkWaveForm(true)
% 
% source2=Source;
% source2.source({'source2','static','gaussian',time,1,-15,-15,fem});
% source2.checkWaveForm(true)
% 
% source3=Source;
% source3.source({'source3','static','gaussian',time,1,-5,-5,fem});
% source3.checkWaveForm(true)
% 
% source4=Source;
% source4.source({'source4','static','gaussian',time,1,0,0,fem});
% source4.checkWaveForm(true)
% 
% source5=Source;
% source5.source({'source5','static','gaussian',time,1,5,5,fem});
% source5.checkWaveForm(true)
% 
% %% force terms
% ft1=StaticSingleSourceForceTerm;
% ft1.source_force_term({'ft1',source1})
% 
% ft2=StaticSingleSourceForceTerm;
% ft2.source_force_term({'ft2',source2})
% 
% ft3=StaticSingleSourceForceTerm;
% ft3.source_force_term({'ft3',source3})
% 
% ft4=StaticSingleSourceForceTerm;
% ft4.source_force_term({'ft4',source4})
% 
% ft5=StaticSingleSourceForceTerm;
% ft5.source_force_term({'ft5',source5})
% 
% ft=ft1.force_term+ft2.force_term+ft3.force_term+ft4.force_term+ft5.force_term;

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
    n_frame=25;
    df.dynamicField({nodes_data_ds,ds,time.time_steps(1),round((time.time_steps(end)-time.time_steps(1))/n_frame),time.time_steps(end),videoFolderName});
    df.plotField(true, true)
    VideoManager.videoMaker(videoFolderName, '*.png', 'field.avi', true);
end

ssf_path=sprintf('%s/l%d_sensor_signal_form.mat',sensor_folder,element_length);
ssf=s1.signalForm;
save(ssf_path,'ssf')