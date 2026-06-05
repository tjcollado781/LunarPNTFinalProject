tic

cspice_furnsh(cellstr("Kernels/furnsh.tm"));

%%%%% Constant Definitions %%%%%
GM_Moon = 4902.800; %[km^3/s^2]
R_Moon = 1737.4;    %[km]

epoch_date = cellstr("2026 jun 01 00:00:00");
numYears = 1;   %[yrs]
stepSize = 60;  %[sec]

t0_ET = cspice_str2et(epoch_date);
oneDay = 1/365.25;

%%%%% S-ELFO Constellation (Keidai) %%%%%
% Four orbital planes of 3 sats each, in a lunar version of the Earth-based
% Tundra Frozen Orbit

Ns = 12; % Number of satellites
Np = 3; % Number of planes
Nspp = Ns/Np; %Number of satellites per plane
f = 1; % Relative phasing between satellites in adjacent planes



%Orbital Elements
%a - semi-major axis
%Want to use numbers that are subsets of the lunar sidreal period (27.32 d)
% 10%, 5%, and 2.5%, for 10, 20, and 40 orbits per lunar orbit respectively
T_lunar = 27.32*3600*24; %[sec]
T_range = [T_lunar/10 T_lunar/20 T_lunar/40];
%T_range = [T_lunar/10]
% Kepler's third law: T = 2*pi*sqrt(a^3/GM)  ->  a = (GM*(T/(2*pi))^2)^(1/3)
a_range = (GM_Moon .* (T_range./(2*pi)).^2).^(1/3);

% i - inclination
%chosen from a range of values in Keidai's paper (in Earth OP frame)
i_op_range = 40:5:60;
%i_op_range = 60
%Define the coe matrix, as we now have the range of values that impact the
%total number of combinations
numCombinations = length(a_range)*length(i_op_range);
coe = zeros(Ns,6,numCombinations);

% e - eccentricity
% calculated based on inclination using lunar frozen orbit condition
e_range = sqrt(1 - (5/3).*cosd(i_op_range).^2);

%RAAN - Right Acension of Acsending Node
%Walker Constellation with 3 planes of 4 satellitess each, 
%Based on walker constellation, with 
%
RAAN_step = 360/Np;
RAAN = 0:RAAN_step:360-RAAN_step;

%w - Argument of periapsis
% 90 degrees so periapsis is over north pole, and apoapsis over south pole,
% to maximize dwell time over the lunar south polar regions
w = 90;

%True Anomaly
%Defined based on mean anomaly using walker constellation parameters and
%the orbital eccentricity


curCombo = 1;
for a_step = 1:length(a_range)
    for i_op_step = 1:length(i_op_range)
        %Define a, i, and e values
        a_cur = a_range(a_step);
        i_op_cur = i_op_range(i_op_step);
        e_cur = e_range(i_op_step);
        %Iterate through each satellite 
        curSat = 1;
        for plane = 1:Np
            RAAN_cur = RAAN(plane);
            for satInPlane = 1:Nspp
                M_cur = 2*pi*(satInPlane-1)/Nspp + 2*pi*plane*f/Ns;
                v_cur = M2v(rad2deg(M_cur),e_cur); 
                
                coe(curSat,:,curCombo) = [a_cur,e_cur,i_op_cur,RAAN_cur,w,v_cur];
                curSat = curSat + 1;
            end
        end

        coe(:,:,curCombo) = coeOPtocoeMCI(coe(:,:,curCombo),t0_ET,GM_Moon);

        satType = sprintf('a%05.0f-i%02d', a_cur, i_op_cur);

        orbitPropHandler(coe(:,:,curCombo),satType,t0_ET,numYears,stepSize,false,false)
        %orbitPropHandlerAnimated(coe(:,:,curCombo),satType,t0_ET,numYears,stepSize,true,false)

        curCombo = curCombo + 1;
    end
end

toc

function v = M2v(M,e)
[E,~] = M2E(deg2rad(M),e,deg2rad(M));
E = rad2deg(E);
v = 2*atan2d(sqrt(1+e)*sind(E/2),sqrt(1-e)*cosd(E/2));
end

function [E, iter] = M2E(M, e, E0)
d   = 1.0;
eps = 1.0e-12;
E   = E0;
iter   = 0;
while (d > eps)
    E_new = E - (E - e .* sin(E) - M) ./ (1.0 - e .* cos(E));
    d = abs(E_new - E);
    E = E_new;
    iter = iter + 1;
end
end