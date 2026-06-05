function [r_eci,rDot_eci] = cartEl(a,e,i,LAAN,w,v,mu)
%Angles in radians

p = a*(1-e^2);
r = p/(1+e*cos(v));

h = sqrt(p*mu);

%vDot = h/r^2


x_orb = r*cos(v);
y_orb = r*sin(v);
z_orb = 0;

xDot_orb = (-mu/h)*sin(v);
yDot_orb = (mu/h)*(e+cos(v));
zDot_orb = 0;

r_orb = [x_orb;y_orb;z_orb];
rDot_orb = [xDot_orb;yDot_orb;zDot_orb]; 

%3
R_LAAN = [cos(-LAAN)  sin(-LAAN) 0;
         -sin(-LAAN)  cos(-LAAN) 0;
         0 0 1];
%1
R_i = [1 0 0;
       0 cos(-i) sin(-i);
       0 -sin(-i) cos(-i)];
%3
R_w = [cos(-w)  sin(-w) 0;
         -sin(-w)  cos(-w) 0;
         0 0 1];

r_eci = R_LAAN*R_i*R_w*r_orb;
rDot_eci = R_LAAN*R_i*R_w*rDot_orb;

% fprintf("Cartesian Coordinates\n")
% fprintf( '  X: %20.8f km\n', r_eci(1) )
% fprintf( '  Y: %20.8f km\n', r_eci(2) )
% fprintf( '  Z: %20.8f km\n', r_eci(3) )
% fprintf( 'V_X: %20.8f km/s\n', rDot_eci(1) )
% fprintf( 'V_Y: %20.8f km/s\n', rDot_eci(2) )
% fprintf( 'V_Z: %20.8f km/s\n', rDot_eci(3) )

end