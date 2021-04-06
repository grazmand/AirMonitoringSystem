function [poly,long_max,AssList]=StreetGenerator_mod_2(v,AssList)

% data check
if size(AssList,1)*4+4~=size(v,1)
    if size(v,1)<=size(AssList,1)*4+4
        AssList=AssList(1:end-1,:);
    else
        error('check')
    end
end

index = 0;
count = size(AssList,1);
xx=zeros(1,count*2);
yy=zeros(1,count*2);
poly=zeros(10,count);
long_1=zeros(1,count);
long_2=zeros(1,count);
long_3=zeros(1,count);
long_4=zeros(1,count);
long_array=zeros(4,count);
long_max=zeros(count);

for i= 1:2:size(v,1)
    xx(index+1) = ( v(i) - 11.227 ) * 1000 ;
    yy(index+1) = ( v(i+1) - 43.790 ) * 1000;
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
        
        count = count - 1;
        
        %
        %         %               hold on
        %
        %         %               plot([xx(i-3) xx(i-2) xx(i-1) xx(i) xx(i-3)],...
        %         %                   [yy(i-3) yy(i-2) yy(i-1) yy(i) yy(i-3)],'r*-','Color',AssList(count,:)/255,'LineWidth',2);
        %
        %         %               strmax = ['',num2str(i)];
        %         %
        %         %               text(xx(i),yy(i),strmax,'HorizontalAlignment','right');
        
        if count==1
            deb=0;
        end
    end
end

% check
if count~=0
    error('count must be zero')
end