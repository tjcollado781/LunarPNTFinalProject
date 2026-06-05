function [outputTable, t_out, y_out] = orbitPropagator(coe,t0_ET,numYears,stepSize,plot,satType)
%Orbit Prop

%Start w/ initial definition of satellite positions using orbital elements
%Convert this to cartesian w.r.t moon
%generate equation for propagator
%propagate out to desired range
%Need to define a epoch date if I'm going to use spice for Earth distance

%maybe pull J2 and GM from spice instead of hard-coding
a = coe(1);   %[km]
e = coe(2);
i = coe(3);      %[deg]
LAAN = coe(4);  %[deg]
w = coe(5);     %[deg]
v = coe(6);      %[deg]

GM_Moon = 4902.800; %[km^3/s^2]
R_Moon = 1737.4;    %[km]
R_Moon_SOI = 60000; %[km]

[y0_mci, y0_mci_dot] = cartEl(a,e,deg2rad(i),deg2rad(LAAN),deg2rad(w),deg2rad(v),GM_Moon);

y0 = [y0_mci;y0_mci_dot];


numSecs = 365.25*24*3600*numYears;

tf_ET = t0_ET + numSecs;

tSpan = t0_ET:stepSize:tf_ET;

options = odeset('RelTol', 1e-10, 'AbsTol', 1e-10, 'Events', @endSimulation);
[t_out,y_out] = ode113(@orbitPropMaster,tSpan,y0,options);

%old ode function outputs stuff transposed compared to stock matlab ones
y_out = y_out';

if plot
    plotElements(t_out,y_out, GM_Moon, R_Moon,satType);
end

%Output a table with the elements in MCI

t_elapsed = t_out - t_out(1);

outputTableNames = ["EphermerisTime","ElapsedTime","x_MCI", "y_MCI", "z_MCI","vx_MCI","vy_MCI","vz_MCI"];
outputVariableTypes = ["double","double","double","double","double","double","double","double"];
outputTableSize = [length(t_elapsed),length(outputTableNames)];
outputTable =  table(Size=outputTableSize,VariableTypes=outputVariableTypes,VariableNames=outputTableNames);
outputTable.EphermerisTime = t_out;
outputTable.ElapsedTime = t_elapsed;
outputTable.x_MCI = y_out(1,:)';
outputTable.y_MCI = y_out(2,:)';
outputTable.z_MCI = y_out(3,:)';
outputTable.vx_MCI = y_out(4,:)';
outputTable.vy_MCI = y_out(5,:)';
outputTable.vz_MCI = y_out(6,:)';


    function [value, isterminal, direction] = endSimulation(t, y)
        R_Moon = 1737.4;  % [km] Lunar surface
        R_SOI = 60000;    % [km] Sphere of Influence
        
        % Calculate the satellite's current distance from the center of the Moon
        r_current = norm(y(1:3)); 
        
        % Preallocate column vectors for 2 distinct events
        value = zeros(2,1);
        isterminal = zeros(2,1);
        direction = zeros(2,1);
        
        % --- Event 1: Lunar Impact ---
        value(1)      = r_current - R_Moon; % Triggers when altitude is 0
        isterminal(1) = 1;                  % 1 = Stop the execution
        direction(1)  = -1;                 % -1 = Only trigger if falling towards Moon
        
        % --- Event 2: Escaping SOI ---
        value(2)      = r_current - R_SOI;  % Triggers when distance hits 60,000 km
        isterminal(2) = 1;                  % 1 = Stop the execution
        direction(2)  = 1;                  % 1 = Only trigger if moving away from Moon
    end
end