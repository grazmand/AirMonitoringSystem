classdef Structures < matlab.mixin.SetGet
    properties (SetAccess = private, GetAccess = public)
        blocks cell % variable size cell array
        mesh Mesh
        n_blocks {mustBeInteger}
        nodes_blocks cell
    end
    
    methods
        function structures(obj ,vals)
            props = {'blocks','mesh'};
            obj.set(props, vals)
            obj.n_blocks = size(obj.blocks,2);
            obj.set_elements_blocks()
        end
        
        function set_elements_blocks(obj)
            indexProgress = 1;
            tic
            for i=1:obj.n_blocks
                n_elements = size(obj.blocks{i},2);
                for e=1:n_elements
                    if e>=floor(n_elements/10)*indexProgress
                        fprintf(' %d/%d ',indexProgress,min(n_elements,10));
                        indexProgress = indexProgress + 1;
                    end
                    [obj.nodes_blocks{i}{e}]=FemTools.find_elements_in_polygon(obj.mesh,obj.blocks{i}(:,e));
                end
            end
            toc
            fprintf(' \n')
        end
        
        function plot_blocks(obj,bool)
            if bool
                figure
                for i=1:obj.n_blocks
                    Structures.plot_block(obj.blocks{i})
                end
            end
        end
    end
    methods (Static)
        function plot_block(block)
            n_elements = size(block,2);
            for e=1:n_elements
                Structures.plot_element(block(:,e))
            end
        end
        function plot_element(polygon)
            hold on
            % polygon is 10-size column vector
            plot(polygon(3),polygon(7),':.r')
            plot(polygon(4),polygon(8),':.r')
            plot(polygon(5),polygon(9),':.r')
            plot(polygon(6),polygon(10),':.r')
        end
    end
end