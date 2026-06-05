function [a,e,i,LAAN,w,nu] = orbitEl(state,mu)
%Angles in radians 

r = state(1:3);
v = state(4:6);

x = r(1);
y = r(2);
z = r(3);

h = cross(r,v);

h_bar = h/norm(h);

i = atan2(sqrt(h_bar(1)^2 + h_bar(2)^2),h_bar(3));

LAAN = atan2(h_bar(1),-h_bar(2));

u = atan2(z, (x*cos(LAAN) + y*sin(LAAN))*sin(i));

a = ((2/norm(r))-(norm(v)^2)/ mu)^-1;     

e_vec = cross(v, h)/mu - r/norm(r);
e = norm(e_vec);
    
if e > 0 
    % Calculate the argument for acos
    arg = dot(e_vec, r) / (e * norm(r));
    
    % Clamp the argument to the domain [-1, 1] to prevent complex numbers
    arg = max(min(arg, 1), -1);
    
    nu = acos(arg);
    
    % if r ⋅ v < 0 then replace ν by 2π − ν
    if dot(r, v) < 0
        nu = 2*pi - nu;
    end
else
    nu = 0;
end

nu = mod(nu, 2*pi);

w = u-nu;

w = mod(w, 2*pi);

% fprintf("Orbital Parameters\n")
% fprintf("   Semi-major Axis: %10.5g km \n",a)
% fprintf("      Eccentricity: %10.5g \n",e)
% fprintf("       Inclination: %10.5g deg \n",rad2deg(i))
% fprintf("              LAAN: %10.5g deg \n",rad2deg(LAAN))
% fprintf("Arg. of Pericenter: %10.5g deg \n",rad2deg(w))
% fprintf("      True Anomaly: %10.5g deg \n",rad2deg(nu))

end