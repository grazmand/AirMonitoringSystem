
function [Se,Te,Shape] = EleN_B( Mesh, ie )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computes Nodal Elements
%
%   [Se,Te] = EleE( Mesh, ie )
%
% NOTE:: This is a multipart funtion. This is the driver, in this same file
% there are other functions which are private to EleN()
%
%   [IN]
%       Mesh  - A mesh object
%       ie    - The index of an element within the Mesh
%
%   [OUT]
%       Se,Te - The local matrices of the nodal element
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    XY = Mesh.xy(:,Mesh.ele(2:(Mesh.ele(1,ie)+1),ie))';

    switch Mesh.ele(1,ie)
        case 3
            [Se,Te,Shape] = EleNT1(XY);
        case 4
            [Se,Te] = EleNQ1(XY);
        case 6
            [Se,Te] = EleNT2(XY);
        case 8
            [Se,Te] = EleNQ2(XY);
    end

end

function [Se,Te,Shape] = EleNT1(XY)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Element is a first order tri
%
%   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    A = ((XY(2,1)-XY(1,1))*(XY(3,2)-XY(1,2)) - ...
         (XY(3,1)-XY(1,1))*(XY(2,2)-XY(1,2)))/2;

    Dx(1) =  XY(3,1) - XY(2,1);
    Dx(2) =  XY(1,1) - XY(3,1);
    Dx(3) =  XY(2,1) - XY(1,1);
    Dy(1) =  XY(2,2) - XY(3,2);
    Dy(2) =  XY(3,2) - XY(1,2);
    Dy(3) =  XY(1,2) - XY(2,2);

    % New: Shape functions
    
    a(1)=XY(2,1)*XY(3,2)-XY(3,1)*XY(2,2);
    a(2)=XY(3,1)*XY(1,2)-XY(1,1)*XY(3,2);
    a(3)=XY(1,1)*XY(2,2)-XY(2,1)*XY(1,2);
    
    Shape = [a;Dy;Dx]/(2*A);
    
    Se = zeros(3,3);
    Te = zeros(3,3);
    
    for i = 1 : 3
        for j = 1 : i
          Se(i,j) = (Dy(i)*Dy(j)+Dx(i)*Dx(j)) / (4*A);
          Se(j,i) = Se(i,j);
          Te(i,j) = A / 12;
          Te(j,i) = Te(i,j);
        end
        Te(i,i) = 2 * Te(i,i);
    end
end

function [Se,Te] = EleNT2(XY)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Element is a second order tri
%
%   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     Td = [ 6,  0,  0, -1, -4, -1
            0, 32, 16,  0, 16, -4
            0, 16, 32, -4, 16,  0
           -1,  0, -4,  6,  0, -1
           -4, 16, 15,  0, 32,  0
           -1, -4,  0, -1,  0,  6 ];
     
     Sd = [ 0,  0,  0,  0,  0,  0
            0,  8, -8,  0,  0,  0
            0, -8,  8,  0,  0,  0
            0,  0,  0,  3, -4,  1
            0,  0,  0, -4,  8, -4
            0,  0,  0,  1, -4,  3 ];

    A = ((XY(2,1)-XY(1,1))*(XY(3,2)-XY(1,2)) - ...
         (XY(3,1)-XY(1,1))*(XY(2,2)-XY(1,2)))/2;

    Co(1) = ((XY(4,1)-XY(1,1))*(XY(6,1)-XY(1,1)) + ...
             (XY(4,2)-XY(1,2))*(XY(6,2)-XY(1,2)))/(2.*A);
    Co(2) = ((XY(6,1)-XY(4,1))*(XY(1,1)-XY(4,1)) + ...
             (XY(6,2)-XY(4,2))*(XY(1,2)-XY(4,2)))/(2.*A);
    Co(3) = ((XY(1,1)-XY(6,1))*(XY(4,1)-XY(6,1)) + ...
             (XY(1,2)-XY(6,2))*(XY(4,2)-XY(6,2)))/(2.*A);
      
    Se = zeros(6,6);
    Te = zeros(6,6);

    for i = 1 : 6
        for j = 1 : i
          Te(i,j) = A*Td(i,j)/180;
          Te(j,i) = Te(I,J);
          Se(i,j) = (Co(1)*Sd(IR6(i,0),IR6(j,0))+...
                     Co(2)*Sd(IR6(i,1),IR6(j,1))+...   
                     Co(3)*Sd(IR6(i,2),IR6(j,2)))/6;
          Se(j,i) = SE(i,j);
        end
    end
end

function [it] = IR6(i,n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Permutations for second order tris
%
%   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    itwist = [6, 3, 5, 1, 2, 4];
      
    it = i;
    for j = 1 : n
        it = itwist(it);
    end
   
end

function [Se,Te] = EleNQ1(XY)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Element is a first order quad
%
%   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    Wq = [0.2369269, 0.4786287, 0.5688889, 0.4786287, 0.2369269];
    Sq = [-0.9061799, -0.5384693, 0.0000000, 0.5384693, 0.9061799];
    
    Se = zeros(4,4);
    Te = zeros(4,4);
    
%---------- Perform a 5x5 points gauss quadrature
    for m = 1 : 5
        for n = 1 : 5
          
            [Shape,ShapeDu,ShapeDv,TJTI,DetJ] = ISO4 (XY,Sq(m),Sq(n));
          
            for i = 1 : 4
                for j = 1 : i
                    Te(i,j) = Te(i,j) + Wq(m)*Wq(n)*Shape(I)*Shape(J)*DetJ;
                    Sum     = ShapeDU(i)*TJTI(1,1)*ShapeDU(j)+...
                              ShapeDU(i)*TJTI(1,2)*ShapeDV(j)+...
                              ShapeDV(i)*TJTI(2,1)*ShapeDU(j)+...
                              ShapeDV(i)*TJTI(2,2)*ShapeDV(j);
                    Se(i,j) = SE(i,j) + Wq(m)*Wq(n)*Sum*DetJ;
                end
            end
        end
    end

%---------- MAKE SE, TE SYMMETRIC!
    for i = 1 : 4
        for j = 1 : i
          Te(j,i) = Te(i,j);
          Se(j,i) = Se(i,j);
        end
    end
      
end


function [Shape,ShapeDu,ShapeDv,TJTI,DetJ] = ISO4 (XY,u,v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isoparametric first order quads
%
%   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------INTERPOLATION FUNCTIONS FOR 4-NODE ELEMENT
    Shape(1) =   0.25*(u-1.0)*(v-1.0);
    Shape(2) = - 0.25*(u+1.0)*(v-1.0);
    Shape(3) =   0.25*(u+1.0)*(v+1.0);
    Shape(4) = - 0.25*(u-1.0)*(v+1.0);
      
%----------FUNCTION DERIVATIVES WITH RESPECT TO U
    ShapeDu(1) =   0.25*(v-1.0);
    ShapeDu(2) = - 0.25*(v-1.0);
    ShapeDu(3) =   0.25*(v+1.0);
    ShapeDu(4) = - 0.25*(v+1.0);
      
%----------FUNCTION DERIVATIVES WITH RESPECT TO V
    ShapeDv(1) =   0.25*(u-1.0);
    ShapeDv(2) = - 0.25*(u+1.0);
    ShapeDv(3) =   0.25*(u+1.0);
    ShapeDv(4) = - 0.25*(u-1.0);
         
%----------COMPUTE THE JACOBIAN
    TJ = zeros(2,2);
    for k = 1:4
        TJ(1,1) = TJ(1,1) + XY(k,1)*ShapeDu(k);
        TJ(1,2) = TJ(1,2) + XY(k,2)*ShapeDu(k);
        TJ(2,1) = TJ(2,1) + XY(k,1)*ShapeDv(k);
        TJ(2,2) = TJ(2,2) + XY(k,2)*ShapeDv(k);
    end

%----------JACOBIAN DETERMINANT, INVERSE, TRANSPOSE-INVERSE
    DetJ = TJ(1,1)*TJ(2,2) - TJ(1,2)*TJ(2,1);
    TJI  = inv(TJ);
    TJTI = TJI' * TJI;
end

function [Se,Te] = EleNQ2(XY)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Element is a second order quad
%
%   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    Wq = [ 0.2369269, 0.4786287, 0.5688889, 0.4786287, 0.2369269];
    Sq = [-0.9061799, -0.5384693, 0.0000000, 0.5384693, 0.9061799];
      
    Se = zeros(8,8);
    Te = zeros(8,8);
    
%----------Perform a 5x5 points gauss quadrature
    for m = 1 : 5
        for n = 1 : 5
            [Shape,ShapeDu,ShapeDv,TJTI,DetJ] = ISO8 (XY,Sq(m),Sq(n));

            for i = 1 : 8
                for j = 1 : i
                    Te(i,j) = Te(i,j) + Wq(m)*Wq(n)*Shape(i)*Shape(j)*DetJ;
                    Sum     = ShapeDu(i)*TJTI(1,1)*ShapeDu(j)+...
                              ShapeDu(i)*TJTI(1,2)*ShapeDv(j)+...
                              ShapeDv(i)*TJTI(2,1)*ShapeDu(j)+...
                              ShapeDv(i)*TJTI(2,2)*ShapeDv(j);
                    Se(i,j) = Se(i,j) + Wq(m)*Wq(n)*Sum*DetJ;
                end
            end
        end
    end

%---------- MAKE SE, TE SYMMETRIC!
    for i = 1 : 8
        for j = 1 : i
          Te(j,i) = Te(i,j);
          Se(j,i) = Se(i,j);
        end
    end

end                                        

function [Shape,ShapeDu,ShapeDv,TJTI,DetJ] = ISO8 (XY,u,v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isoparametric second order quads
%
%   (C) 1997-2008 PELOSI - COCCIOLI - SELLERI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  
%----------INTERPOLATION FUNCTIONS FOR 8-NODED ELEMENT
    Shape(1) = 0.25*(1.0-u)*(1.0-v)*(-u-v-1.0);
    Shape(2) = 0.5*(1.0-u*u)*(1.0-v);
    Shape(3) = 0.25*(1.0+u)*(1.0-v)*(u-v-1.0);
    Shape(4) = 0.5*(1.0-v*v)*(1.0+u);  
    Shape(5) = 0.25*(1.0+u)*(1.0+v)*(u+v-1.0);
    Shape(6) = 0.5*(1.0-u*u)*(1.0+v);
    Shape(7) = 0.25*(1.0-u)*(1.0+v)*(-u+v-1.0);
    Shape(8) = 0.5*(1.0-v*v)*(1.0-u);

%----------FUNCTION DERIVATIVES WITH RESPECT TO U
    ShapeDu(1) = 0.25*(v+1.0)*(2.0*u+v);
    ShapeDu(2) = (v+1.0)*(-u);
    ShapeDu(3) = 0.25*(1.0+v)*(2.0*u-v);
    ShapeDu(4) = 0.5*(v*v-1.0);
    ShapeDu(5) = 0.25*(1.0-v)*(2.0*u+v);
    ShapeDu(6) = (v-1.0)*u;
    ShapeDu(7) = 0.25*(1.0-v)*(2.0*u-v);
    ShapeDu(8) = 0.5*(1.0-v*v);

%----------FUNCTION DERIVATIVES WITH RESPECT TO V
    ShapeDv(1) = 0.25*(u+1.0)*(2.0*v+u);
    ShapeDv(2) = 0.5*(1-u*u);
    ShapeDv(3) = 0.25*(1.0-u)*(2.0*v-u);
    ShapeDv(4) = (u-1.0)*v;
    ShapeDv(5) = 0.25*(1.0-u)*(2.0*v+u);
    ShapeDv(6) = 0.5*(u*u-1.0);
    ShapeDv(7) = 0.25*(1.0+u)*(2.0*v-u);
    ShapeDv(8) = (u+1.0)*(-v);
         
%----------COMPUTE THE JACOBIAN
    TJ=zeros(2,2);
    for k = 1 : 8
        TJ(1,1) = TJ(1,1) + XY(k,1)*ShapeDu(k);
        TJ(1,2) = TJ(1,2) + XY(k,2)*ShapeDu(k);
        TJ(2,1) = TJ(2,1) + XY(k,1)*ShapeDv(k);
        TJ(2,2) = TJ(2,2) + XY(k,2)*ShapeDv(k);
    end

    %----------JACOBIAN DETERMINANT, INVERSE, TRANSPOSE-INVERSE
    DetJ = TJ(1,1)*TJ(2,2) - TJ(1,2)*TJ(2,1);
    TJI  = inv(TJ);
    TJTI = TJI' * TJI;
    
end
     
