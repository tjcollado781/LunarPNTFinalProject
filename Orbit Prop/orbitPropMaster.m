function y_dot = orbitPropMaster(t,y)
%Assuming MCI Frame,
%Moon Body Properties
GM_Moon = 4902.800; %[km^3/s^2]
R_Moon = 1737.4;    %[km]

GM_Earth = 398600.4418; %[km^3/s^2]
GM_Sun = 132712440041.279419; %[km^3/s^2]

%Double-check J2 coefficent in future
%(https://www.sciencedirect.com/science/article/pii/S0273117705008720)
J2_Moon = 202*10^-6;

r_vec = y(1:3);
v_vec = y(4:6);

% Create the derivative vector
y_dot      = zeros(6,1);
% Rate of change in position = current velocity
y_dot(1:3) = v_vec;


% central gravity term    
r_Sat_Moon = norm(r_vec);
a_Sat_Moon = - GM_Moon * r_vec ./ (r_Sat_Moon .^ 3);
y_dot(4:end)  = a_Sat_Moon;

rot_mci_to_pa = cspice_pxform('J2000', 'MOON_PA', t);
r_vec_pa = rot_mci_to_pa*r_vec;

% Extract current position
x_Sat = r_vec_pa(1);
y_Sat = r_vec_pa(2);
z_Sat = r_vec_pa(3);

%acceleration due to Moon's oblateness
coef = - 0.5 * GM_Moon * J2_Moon * R_Moon .^ 2;
term = 3.0 / r_Sat_Moon .^ 4 - 15 * (z_Sat .^ 2 / r_Sat_Moon .^ 6);

ax_J2 = coef .* term .* x_Sat ./ r_Sat_Moon;
ay_J2 = coef .* term .* y_Sat ./ r_Sat_Moon;
az_J2 = coef .* (6 * z_Sat / r_Sat_Moon .^ 5 + term * z_Sat ./ r_Sat_Moon);

a_J2_pa = [ax_J2; ay_J2; az_J2];

%Rotate from PA to MCI
a_J2 = rot_mci_to_pa'*a_J2_pa;

%Impact due to Earth's 3-body gravity
pos_Earth_Moon = cspice_spkpos('Earth',t,'J2000','NONE','MOON');
pos_Sat_Earth = pos_Earth_Moon - r_vec(1:3);

a_Earth = GM_Earth*(pos_Sat_Earth/norm(pos_Sat_Earth)^3 - pos_Earth_Moon/norm(pos_Earth_Moon)^3);

%Impact due to Sun's 3-body gravity
pos_Sun_Moon = cspice_spkpos('Sun',t,'J2000','NONE','MOON');
pos_Sat_Sun = pos_Sun_Moon - r_vec(1:3);

a_Sun = GM_Sun*(pos_Sat_Sun/norm(pos_Sat_Sun)^3 - pos_Sun_Moon/norm(pos_Sun_Moon)^3);

y_dot(4) = y_dot(4) + a_J2(1) + a_Earth(1) + a_Sun(1);
y_dot(5) = y_dot(5) + a_J2(2) + a_Earth(2) + a_Sun(2);
y_dot(6) = y_dot(6) + a_J2(3) + a_Earth(3) + a_Sun(3);

end
