function [poly] = JmapBuilding(v)
          index=1;
          for i=3:2:size(v)
              
              xx(index)=(v(i)-11.227)*1000 ;  
              yy(index)=(v(i+1)-43.790)*1000;
                
              index=index+1;
          end
          
%           pdepoly(xx,yy)
              
          a=xx';
          b=yy';
          poly=[2;size(xx,2);a;b];
          
%           figure(2)
%               hold on
%               plot([xx xx(1)],[yy yy(1)],'b*-','LineWidth',2)
              
%               for i=1:index-1
%                strmax = [num2str(i)];
%           text(xx(i),yy(i),strmax);
%               end
          
              
              
             