function [street , long_array , long_max] = preLoadingData(mainFolder)


%% This script preloads the map data:

%% Path
path_rgb_1 = strcat(mainFolder,'\Wheater_and_traffic_data\2017-11-15\2');
path_rgb_2 = strcat(mainFolder,'\RGB_Data\Dati RGB');
path_rgb_3 = strcat(mainFolder,'\Shape_buildings_and_roads\street_coord.mat');

%% 1) Loading of the traffic images

dir_to_search = path_rgb_1;

pngpattern = fullfile(dir_to_search, '*.png');

dinfo = dir(pngpattern);

rgb = cell(1,size(dinfo,1));

for ip = 1:size(dinfo,1)
    
    rgb{ip} = imread(dinfo(ip).name);
    
end

street.rgb = rgb;

clear rgb;

%% 2) Loading of the road points in which the RGB coordinates are stored

dir_to_search_2 = path_rgb_2;

mat_pattern = fullfile(dir_to_search_2, '*.mat');

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
    
    [ street , long_array , long_max  ] = street_data ( street, ip );
    
end

clearvars -except street long_array long_max

end









