function [ poly ,long_array , long_max ] = StreetGenerator_mod_2( v , AssList )

index = 1;

count = size(AssList,1);

for i= 1:2:size(v,1)
    
    xx(index) = ( v(i) - 11.227 ) * 1000 ;
    
    yy(index) = ( v(i+1) - 43.790 ) * 1000;
    
    index = index + 1;
end

for i = 1:index
    
    if i >= 4 && mod(i,2) == 0
        
        poly(:,count) = [2;4;xx(i-3);xx(i-2);xx(i-1);xx(i);...
            yy(i-3);yy(i-2);yy(i-1);yy(i)];
        
        long_1(count)=norm([xx(i) yy(i)]-[xx(i-1) yy(i-1)]);
        long_2(count)=norm([xx(i-1) yy(i-1)]-[xx(i-2) yy(i-2)]);
        long_3(count)=norm([xx(i-2) yy(i-2)]-[xx(i-3) yy(i-3)]);
        long_4(count)=norm([xx(i-3) yy(i-3)]-[xx(i) yy(i)]);
        long_array(:,count)=[long_1(count);long_2(count);long_3(count);long_4(count)];
        long_max(count)=max(long_array(:,count));
        
        %               hold on
        
        %               plot([xx(i-3) xx(i-2) xx(i-1) xx(i) xx(i-3)],...
        %                   [yy(i-3) yy(i-2) yy(i-1) yy(i) yy(i-3)],'r*-','Color',AssList(count,:)/255,'LineWidth',2);
        
        %               strmax = ['',num2str(i)];
        %
        %               text(xx(i),yy(i),strmax,'HorizontalAlignment','right');
        
        count = count - 1;
        
    end
    
end