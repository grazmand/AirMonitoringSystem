classdef BoundaryCondition < matlab.mixin.SetGet
    
    properties (SetAccess = private, GetAccess = public)
        type string % this field is a string and can assume 3 values: 'radiation','dirichlet' or 'neumann'
        counterclockwiseNodeIndexes {mustBeInteger}
        counterclockwiseNodeCoordinates double
        scenario Scenario
        mesh Mesh
        nodeSize {mustBeNonnegative} = 0;
    end
    
    methods
        function boundary_condition(obj, vals)
            props = {'type','mesh','scenario'};
            obj.set(props,vals)
            obj.set_boundary_condition_nodes()
        end
        
        function set_boundary_condition_nodes(obj)
            obj.counterclockwiseNodeIndexes = obj.mesh.boundary_counterclockwiseNodeIndexes;
            obj.counterclockwiseNodeCoordinates = obj.mesh.boundary_counterclockwiseNodeCoordinates;
            obj.nodeSize = length(obj.counterclockwiseNodeIndexes);
        end
    end
end