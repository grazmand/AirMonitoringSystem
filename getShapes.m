function [shape] = getShapes( fem, element, point )
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% input :
% point = [x y]
%                                                                                _        _ Transpose
% fem : FemModel object                                                         | a1 b1 c1 |
% fem.shapes_coefficients is 3x3xn_elements where shapes_coefficients(:,:,ie) = | a2 b2 c2 |
%                                                                               |_a3 b3 c3_|
%
% output :
% shape : row vector of length 3
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

shape = zeros(1,3);
for vertex = 1:3
    shape(vertex) = fem.shape_coefficients(:,vertex,element)' * [1;point'];
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % the above operation over the whole for iteration is equivalent to
    %   _          _
    %  | phi_1(x,y) |
    %  | phi_2(x,y) | = [a1 b1 c1; a2 b2 c2; a3 b3 c3] ° [1; x; y]
    %  |_phi_3(x,y)_|
    %
    %
end
end