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
dt.time_discretization_step({0.01})

%% time
time = TimeT;
time.time({3,dt})
time.set_time

%% load domain boundary
load('./borders/coordinates_data.mat');
%
% data : Mesh_Boundaries_Coordinates is a matrix 2xN containig boundary
% coordinates; values are in 1mdeg~=0.11Km=110m
%
% coordinates in mdeg
border_coordinates = Mesh_Boundaries_Coordinates';

% coordinates in m
border_coordinates=border_coordinates*110;

%% domain
domain = Domain;
domain.domain({'domain',border_coordinates,g})
domain.plot_domain(true)

%% mesh
mesh=Mesh;
mesh.mesh({'mesh',1,domain})
mesh.plot_mesh(true)

%% set boundaries
run('check_boundary_alignment.m')
mesh.set_boundaries({boundary_counterclockwiseNodeIndexes})

%% scenario
scenario = Scenario;
scenario.scenario({'dirichlet'});

%% bc
bc=BoundaryConditions;
bc.boundary_conditions({scenario,mesh});
bc.checkBoundaryConditions(true)

% tlc1=false;
% %% handle road data
% if tlc1
%     [street,List,buildpoly,Inbuildpoly,roads_poly] = Handle_Street(main_folder);
%     roads=Roads;
%     roads.structures({roads_poly,mesh})
%     roads.set_rgb_list({List});
%     roads.set_long_max({street.long_max});
%     roads.plot_blocks(true)
%     save('data/roads.mat','roads')
% else
%     load('data/roads.mat')
% end

%% medium
medium=Medium;
d_factor=1e0;
% medium.medium({d_factor*0.1381*10^-4,[10 0]})
medium.medium({0,[0 -100]})

%% fem model
fem = FemModel;
fem.fem_model({mesh,medium,bc})

% tlc2=true;
% if tlc2
%     sources=SourcesCO2;
%     sources.sources({'road_sources',roads,mesh,fem})
%     sources.sources_co2()
%     sources.plot_sources(true)
%     save('data/sources.mat','sources')
% else
%     load('data/sources.mat')
%     sources.plot_sources(true)
% end
% 
% %% force term
% ft=ForceTermCO2;
% corr=1e0;
% ft.forceTerm({'FT',time,mesh,corr})
% ft.setForceTerm({sources})
% ft.plot_force_term(true)

%% source
source=ImpulsiveSource;
source.source({'source','static',time,1,0,0,fem});
source.checkWaveForm(true)

%% force term
ft=StaticSingleSourceForceTerm;
ft.source_force_term({'ft',source})

%% dynamic system
ds=DynamicSystem;
ds.dynamicSystem({time,fem,mesh,ft,0,'constant','static'})
ds.setState()

%% sensor
s1=Sensor;
index=1;
n_index=mesh.allNodesExceptDirichletNodes_indexes(index);
xs=mesh.node_coordinates(1,n_index);
ys=mesh.node_coordinates(2,n_index);
s1.setProperties({'s1',time,xs,ys,mesh,ds});
s1.viewSignalForm(true);

%% save data
tlc3=false;
if tlc3
    save(strcat(data_folder,'/data.mat'))
end

if true
    %% dynamic field
    nodes_data_ds = ds.state;
    df = DynamicField;
    n_frame=7;
    df.dynamicField({nodes_data_ds,ds,time.time_steps(1),round((time.time_steps(end)-time.time_steps(1))/n_frame),time.time_steps(end),videoFolderName});
    df.plotField(true, true)
    VideoManager.videoMaker(videoFolderName, '*.png', 'field.avi', true);
end
