function [street , long_array , long_max, List, buildpoly, Inbuildpoly, poly] = Handle_Street(mainFolder)

%1) Loading maps
[street , long_array , long_max] = preLoadingData(mainFolder);

poly = street.poly;

List = cell(1,size(street.data,2));
for ie = 1:size(street.data,2)
    for je = 1:size(street.data{ie}.acolor,2)
        
        List{ie}{je} = street.data{ie}.acolor{je};
        
    end
end

load(strcat(mainFolder,'\Shape_buildings_and_roads\build_coord.mat'));

build = build_coord;

load(strcat(mainFolder,'\Shape_buildings_and_roads\Inbuild_coord.mat'));

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