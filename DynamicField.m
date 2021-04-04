classdef DynamicField  < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        ds DynamicSystem
        folder string
        startTime {mustBePositive}
        stepTime {mustBePositive}
        endTime {mustBePositive}
        nodes_data double
        %%%%%%%%%%%%%%%%%
        field_data double
    end
    
    methods
        function dynamicField(obj, vals)
            props = {'nodes_data','ds',...
                'startTime','stepTime','endTime','folder'};
            obj.set(props, vals)
            if (obj.endTime > obj.ds.ft.time.time_steps(end)) || (obj.startTime < obj.ds.ft.time.time_steps(1))
                error('timing must agree!')
            end
        end
        
        function plotField(obj, bool1, bool2)
            fem = obj.ds.fem;
            mesh = obj.ds.mesh;
            if bool1==true
                indexFig = 1;
                for k=obj.startTime:obj.stepTime:obj.endTime
                    [XI,YI] = DynamicField.setMeshGrid(mesh);
                    [obj.field_data] = DynamicField.getFieldValues(obj.nodes_data(:,k), mesh, XI, YI, fem);
                    h=figure;
                    pcolor(XI,YI,obj.field_data); shading interp; axis equal;
                    ax = gca;
                    ax.FontWeight = 'bold';
                    ax.LineWidth = 6;
                    grid on
                    caxis('auto');
                    colorbar();
                    tit = sprintf('Dynamic System, time %0.1d [sec.]', k*obj.ds.ft.time.dt.value);
                    title(tit)
                    xlabel('range [m]', 'FontWeight', 'bold')
                    ylabel('depth [m]', 'FontWeight', 'bold')
                    if bool2==true
                        if ismember(indexFig,1:9)
                            fileName = sprintf('%s/fig000%d.png', obj.folder, indexFig);
                        elseif ismember(indexFig,10:99)
                            fileName = sprintf('%s/fig00%d.png', obj.folder, indexFig);
                        elseif ismember(indexFig,100:999)
                            fileName = sprintf('%s/fig0%d.png', obj.folder, indexFig);
                        elseif ismember(indexFig,1000:9999)
                            fileName = sprintf('%s/fig%d.png', obj.folder, indexFig);
                        end
                        indexFig = indexFig + 1;
                        saveas(h,fileName)
                    end
                    %Enlarge figure to full screen.
                    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
                    close
                end
            end
        end
    end
    
    methods (Static)
        
        function [XI,YI] = setMeshGrid(mesh)
            Naux = 150;
            Xg = min(mesh.node_coordinates(1,:)):(max(mesh.node_coordinates(1,:))-min(mesh.node_coordinates(1,:)))/Naux:max(mesh.node_coordinates(1,:));
            Yg = min(mesh.node_coordinates(2,:)):(max(mesh.node_coordinates(2,:))-min(mesh.node_coordinates(2,:)))/Naux:max(mesh.node_coordinates(2,:));
            [XI,YI] = meshgrid(Xg,Yg);
        end
        
        function [ZI] = getFieldValues(fieldValuesOnNodes, mesh, XI, YI, fem)
            
            ZI = zeros(size(XI,1),size(XI,2));
            
            for ie=1:mesh.element_size_number
                xx = [mesh.node_coordinates(1, mesh.elements(1,ie)) mesh.node_coordinates(1, mesh.elements(2,ie)) mesh.node_coordinates(1, mesh.elements(3,ie))];
                yy = [mesh.node_coordinates(2, mesh.elements(1,ie)) mesh.node_coordinates(2, mesh.elements(2,ie)) mesh.node_coordinates(2, mesh.elements(3,ie))];
                IN = inpolygon(XI, YI, xx, yy);
                
                points = find(IN);
                
                for i = 1:length(points)
                    N = zeros(length(points),3);
                    N(i,:) = getShapes (fem,ie,[XI(points(i)) YI(points(i))]);
                    ZI(points(i)) = N(i,:)*[fieldValuesOnNodes(mesh.elements(1,ie));...
                        fieldValuesOnNodes(mesh.elements(2,ie));...
                        fieldValuesOnNodes(mesh.elements(3,ie))];
                end
            end
            
        end
    end
    
end