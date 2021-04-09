classdef Sources < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        name string
        roads Roads
        mesh Mesh
        fem FemModel
        coordinates string % NX2 array
        em_factor EmFactor
        %% poly
        poly_indexes {mustBeInteger}
        poly_length double
        poly_rgb double
        poly_los string
        %% elements
        element_indexes {mustBeInteger}
        %
        % element_indexes : vector of indexes of elements belonging the
        % polygonal blocks of roads;
        %
        element_poly_indexes {mustBeInteger}
        element_poly_length {mustBePositive}
        %
        % element_poly_length : vector of lengths of polygonal blocks
        % sorted with respect of the element indexes;
        %
        element_poly_rgb double
        element_poly_los string
        element_poly_multeplicity {mustBeInteger}
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        shapes double {mustBeInRange(shapes,0,1)}% (n_element_indexes)x(3)
        element_em_factors double
        element_em_rates double
    end
    
    methods
        function sources(obj ,vals)
            props = {'name','roads','mesh','fem'};
            obj.set(props, vals)
            obj.set_element_indexes()
            obj.set_coordinates()
            obj.set_shapes()
        end
        
        %% poly settings
        
        function set_poly_indexes(obj)
            i_p=1;
            for ib=1:size(obj.roads.blocks,2)
                for ip=1:size(obj.roads.blocks{ib},2)
                    obj.poly_indexes(i_p)=i_p;
                    i_p=i_p+1;
                end
            end
        end
        
        function set_poly_length(obj)
            i_p=1;
            for ib=1:size(obj.roads.long_max,2)
                for ip=1:size(obj.roads.long_max{ib},1)
                    obj.poly_length(i_p)=obj.roads.long_max{ib}(ip,1);
                    i_p=i_p+1;
                end
            end
        end
        
        function set_poly_rgb(obj)
            for f=1:size(obj.roads.list,2)
                i_p=1;
                for ib=1:size(obj.roads.list{f},2)
                    for ip=1:size(obj.roads.list{f}{ib},2)
                        obj.poly_rgb(i_p,:,f)=obj.roads.list{f}{ib}(ip,:);
                        i_p=i_p+1;
                    end
                end
            end
        end
        
        function set_poly_los(obj)
            a=[255 255 0];
            b=[23 177 23];
            c=[20 200 20];
            d=[20 200 20];
            for f=1:size(obj.roads.list,2)
                for i=1:size(obj.poly_los,1)
                    if ismember(a,obj.poly_rgb(i,:,f))
                        obj.poly_los(i,f)='green_A';
                    elseif ismember(b,obj.poly_rgb(i,:,f))
                        obj.poly_los(i,f)='yellow_B';
                    elseif ismember(c,obj.poly_rgb(i,:,f))
                        obj.poly_los(i,f)='orange_C';
                    elseif ismember(d,obj.poly_rgb(i,:,f))
                        obj.poly_los(i,f)='red_D';
                    end
                end
            end
        end
        
        %% element poly setting
        
        function set_element_indexes(obj)
            i_p=1;
            i_e=1;
            for ib=1:size(obj.roads.elements_blocks,2)
                for ip=1:size(obj.roads.elements_blocks{ib},2)
                    for ie=1:size(obj.roads.elements_blocks{ib}{ip},2)
                        obj.element_indexes(i_e)=obj.roads.elements_blocks{ib}{ip}(ie);
                        obj.element_poly_indexes(i_e)=obj.poly_indexes(i_p);
                        obj.element_poly_length(i_e)=obj.poly_length(i_p);
                        obj.element_poly_rgb(i_e,:,:)=obj.poly_rgb(i_p,:,:);
                        obj.element_poly_los(i_e)=obj.poly_los(i_p,:);
                        % check
                        if true && obj.element_indexes(i_e)==0
                            error('element indexes must be positive')
                        end
                        i_e=i_e+1;
                    end
                    i_p=i_p+1;
                end
            end
        end
        
        function set_element_poly_multeplicity(obj)
            for ie=1:length(obj.element_poly_indexes)
                obj.element_poly_multeplicity(ie)=length(find(obj.element_poly_indexes==obj.element_poly_indexes(ie)));
            end
        end
        
        function set_element_em_factors(obj)
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function set_coordinates(obj)
            obj.coordinates=obj.mesh.element_centroids(obj.element_indexes,:);
        end
        
        function set_shapes(obj)
            for ie=1:length(obj.element_indexes)
                obj.shapes(ie,:)=getShapes(obj.fem,obj.element_indexes(ie),[str2double(obj.coordinates(ie,1)),...
                    str2double(obj.coordinates(ie,2))] );
            end
        end
        
        function plot_sources(obj,bool)
            if bool
                figure
                plot(str2double(obj.coordinates(:,1)),str2double(obj.coordinates(:,2)),'ro')
                title('source coords')
            end
        end
    end
end