function [possi, ordrei]=sourcesimages(Lx,Ly,Lz,poss,N)

indcorn=   [ 0 0 0;
     -1  0  0; 
      0 -1  0; 
      0  0 -1; 
     -1 -1  0;
     -1  0 -1;
      0 -1 -1;
     -1 -1 -1];

a = [ 1  1  1;
     -1  1  1; 
      1 -1  1; 
      1  1 -1; 
     -1 -1  1;
     -1  1 -1;
      1 -1 -1;
     -1 -1 -1];

posscorn=repmat(poss,8,1).*a;

[X,Y,Z]    = meshgrid([-N:N]*2*Lx, [-N:N]*2*Ly, [-N:N]*2*Lz);
[iX,iY,iZ] = meshgrid([-N:N]*2, [-N:N]*2, [-N:N]*2);

possi=[];
indicesi=[];

for i = 1:8
     possi    = [possi; [X(:) Y(:) Z(:)] + repmat(posscorn(i,:),length(X(:)),1)];
     indicesi = [indicesi; [iX(:)+indcorn(i,1) iY(:)+indcorn(i,2) iZ(:)+indcorn(i,3)]];
end
ordrei = sum(abs(indicesi),2);
 
