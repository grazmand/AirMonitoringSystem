function [street, List, buildpoly, Inbuildpoly, poly] = Handle_Street(mainFolder)
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% poly : 37-size cell array set of variable size cell blocks of polygons defining the shapes of the roads. Each polygon is
% represented as a geometry description matrix : https://www.mathworks.com/help/pde/ug/decsg.html#bu_fft3-gd
%
% examples :
%
% poly --> set of 37 blocks of variable size
%
% poly{36} --> cell {10x1 double} --> [2; 4; ....] (geometry description of a single polygon)
%  _____
% |_____| (sinle polygon)
%
% poly{24} --> cell {10x29 double} --> [[2; 4; ....] [2; 4; ....] ....] (geometry description of a plural of polygons)
%  ______ ______________ _________________________ ___
% |______|______________|_________________________|___| (plural of adjacent polygons)
%
% List : rgb information list of the 37-size cell array
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% loading maps
street = preLoadingData(mainFolder);
poly = street.poly;
List = cell(1,size(street.data,2));
for ie = 1:size(street.data,2)
    for je = 1:size(street.data{ie}.acolor,2)
        List{ie}{je} = street.data{ie}.acolor{je};
    end
end
load(strcat(mainFolder,'/Shape_buildings_and_roads/build_coord.mat'));
build = build_coord;
load(strcat(mainFolder,'/Shape_buildings_and_roads/Inbuild_coord.mat'));
Inbuild = Inbuild_coord;
buildpoly = cell(1,size(build,2));
for i = 1:size(build,2)
    [buildpoly{i}] = JmapBuilding(build{i});
end
Inbuildpoly = cell(1,size(Inbuild,2));
for i = 1:size(Inbuild,2)
    [Inbuildpoly{i}] = JmapBuilding(Inbuild{i});
end
clearvars -except street long_array long_max List buildpoly Inbuildpoly poly
end