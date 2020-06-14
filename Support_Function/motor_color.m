function [ acolor , color ] = motor_color ( A , xy )

% RBG color values
col.yellow = [255 255 0];

col.orange = [255 170 0];

col.green = [215 0 0];

col.darkgreen = [23 177 23];

col.red = [200 0 0];

PixXY = zeros(size( xy , 1 ),2);

List = zeros(size( xy , 1 ),3);

dis = zeros(size( xy , 1 ),5);

AssList = zeros(size( xy , 1 ),3);

dist = size( xy , 1 );

for i = 1:size( xy , 1 )
    
    PixXY(i,1) = xy(i,1);
    
    PixXY(i,2) = xy(i,2);
    
    List(i,1:3) = double([A(PixXY(i,2),PixXY(i,1),1) A(PixXY(i,2),... % list of colors drawn from RBG images
        PixXY(i,1),2) A(PixXY(i,2),PixXY(i,1),3)]);
    
    dis(i,1) = norm(List(i,1:3)-col.yellow);
    
    dis(i,2) = norm(List(i,1:3)-col.orange);
    
    dis(i,3) = norm(List(i,1:3)-col.green);
    
    dis(i,4) = norm(List(i,1:3)-col.red);
    
    dis(i,5) = norm(List(i,1:3)-col.darkgreen);
    
    dist(i) = min(dis(i,1:5));
    
    if dist(i) == dis(i,1)
        
        AssList(i,1:3) = col.yellow;
        
    elseif dist(i) == dis(i,2)
        
        AssList(i,1:3) = col.orange;
        
    elseif dist(i) == dis(i,3)
        
        AssList(i,1:3) = col.green;
        
    elseif dist(i) == dis(i,4)
        
        AssList(i,1:3) = col.red;
        
    elseif dist(i) == dis(i,5)
        
        AssList(i,1:3) = col.darkgreen;
        
    end
    
end

acolor = AssList;

color = List;

clearvars -except acolor color

end



