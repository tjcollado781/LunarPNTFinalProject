%Orbit Prop

%Start w/ inital definition of satellite positions using orbital elements
%Convert this to cartesian w.r.t moon
%generate equation for propagator
%propogate out to desired range


%Need to define a epoch date if I'm going to use spice for Earth distance

cspice_furnsh(cellstr("Kernels/furnsh.tm"));


%maybe pull J2 and GM from spice instead of hard-coding

a = 10000;   %[km]
e = 0.3;
i = 85;      %[deg]
LAAN = 0;  %[deg]
w = 270;     %[deg]
v = 0;      %[deg]

GM_Moon = 4902.800; %[km^3/s^2]
R_Moon = 1737.4;    %[km]

[y0_mci, y0_mci_dot] = cartEl(a,e,deg2rad(i),deg2rad(LAAN),deg2rad(w),deg2rad(v),GM_Moon);

y0 = [y0_mci;y0_mci_dot];

numYears = 1;    
numSecs = 365.25*24*3600*numYears;

%Consider plotting multiple cases 
%Just Lunar J2, w/ Earth, w/ Sun, etc

epoch_date = cellstr("2026 jun 01 00:00:00");
t0_ET = cspice_str2et(epoch_date);
tf_ET = t0_ET + numSecs;

timeStepSize = 60;  %[secs]

tSpan = t0_ET:timeStepSize:tf_ET;
[t_out,y_out] = ode_rk4(@orbitPropMaster,tSpan,y0);

plot3(y_out(1,:),y_out(2,:),y_out(3,:)), hold on


%Plot the moon
[x,y,z] = sphere;
x = x*R_Moon;
y = y*R_Moon;
z = z*R_Moon;
surf(x,y,z), hold off

axis equal


plotElements(t_out,y_out, GM_Moon, R_Moon);

toc

