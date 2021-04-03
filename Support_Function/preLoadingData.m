function street=preLoadingData(mainFolder)


%% this script preloads map data

%% paths
traffic_rgb_data_path = strcat(mainFolder,'/Wheater_and_traffic_data/2017-11-15/2');
rgb_image_road_coordinates_path = strcat(mainFolder,'/RGB_Data/Dati RGB');
path_rgb_3 = strcat(mainFolder,'/Shape_buildings_and_roads/street_coord.mat');

%% 1) loading rgb traffic image data
%
%
% traffic image data : 141-size cell array whose each element contains
% a 1080x1920x3-size array storing the rgb coordinates of a image sample
%
% rgb image road coordinates : coordinates of position of each road polygon
% with respect of the traffic image data axis
% so that x-coordinate range among 1 and 1080 and y-coordinate range among
% 1 and 1920
%
%
% street coord : lat and long data of each road blocks
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pngpattern = fullfile(traffic_rgb_data_path, '*.png');
dinfo = dir(pngpattern);
rgb = cell(1,size(dinfo,1));
for ip = 1:size(dinfo,1)
    rgb{ip} = imread(dinfo(ip).name);
end
street.rgb = rgb;
clear rgb;

%% 2) Loading of the road points in which the RGB coordinates are stored
mat_pattern = fullfile(rgb_image_road_coordinates_path, '*.mat');
dinfo_2 = dir(mat_pattern);
for ip = 1:size(dinfo_2,1)
    load(dinfo_2(ip).name);
end
for ip = 1:size(dinfo_2,1)
    street.datacolor{ip} = eval(sprintf('rgbs%d', ip));
end
clearvars rgbs*

%% 3) Caricamento delle coordinate geografiche delle strade
load(path_rgb_3);
street.coord = street_coord;
clear street_coord;

%% 4) Prelevamento dei dati del traffico

for ip = 1:size(street.datacolor,2)
    for jp = 1:size(street.datacolor{ip},2)
        street.xy{ip}(jp,1) = street.datacolor{ip}(jp).Position(1);
        street.xy{ip}(jp,2) = street.datacolor{ip}(jp).Position(2);
    end
end
for ip = 1:size(street.rgb,2)
    street = street_data ( street, ip );
end
clearvars -except street long_array long_max

end
