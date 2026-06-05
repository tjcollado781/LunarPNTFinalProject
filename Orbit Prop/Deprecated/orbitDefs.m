tic

cspice_furnsh(cellstr("Kernels/furnsh.tm"));

%%%%% Constant Definitions %%%%%
GM_Moon = 4902.800; %[km^3/s^2]
R_Moon = 1737.4;    %[km]

epoch_date = cellstr("2026 jun 01 00:00:00");
numYears = 3;   %[yrs]
stepSize = 360;  %[sec]

t0_ET = cspice_str2et(epoch_date);
oneDay = 1/365.25;

%%%%% Tundra Constellation %%%%%
% Four orbital planes of 3 sats each, in a lunar version of the Earth-based
% Tundra Frozen Orbit

e_Tundra = 0.3;

v_Tundra = [0 M2v(120,e_Tundra) M2v(240,e_Tundra)];

coeTundra = [9750.73,e_Tundra,63.4,0,90,v_Tundra(1)
             9750.73,e_Tundra,63.4,90,90,v_Tundra(1)
             9750.73,e_Tundra,63.4,180,90,v_Tundra(1)
             9750.73,e_Tundra,63.4,270,90,v_Tundra(1)
             9750.73,e_Tundra,63.4,0,90,v_Tundra(2)
             9750.73,e_Tundra,63.4,90,90,v_Tundra(2)
             9750.73,e_Tundra,63.4,180,90,v_Tundra(2)
             9750.73,e_Tundra,63.4,270,90,v_Tundra(2)
             9750.73,e_Tundra,63.4,0,90,v_Tundra(3)
             9750.73,e_Tundra,63.4,90,90,v_Tundra(3)
             9750.73,e_Tundra,63.4,180,90,v_Tundra(3)
             9750.73,e_Tundra,63.4,270,90,v_Tundra(3)];

%orbitPropHandler(coeTundra,"Tundra",t0_ET,numYears,stepSize,true,true)

%%%%% S-ELFO Constellation (Keidai) %%%%%
% Four orbital planes of 3 sats each, in a lunar version of the Earth-based
% Tundra Frozen Orbit

Ns = 12; % Number of satellites
Np = 3; % Number of planes
Nspp = Ns/Np; %Number of satellites per plane
f = 1; % Relative phasing between satellites in adjacent planes
i_op = 52; %Inclination in Earth OP

a_S_ELFO = 6541.4;
e_S_ELFO = 0.6;

for p = 1:Np
    for i = 1:Nspp
        M_S_ELFO = 2*pi*(i-1)/Nspp + 2*pi*p*f/Ns;
        v_S_ELFO(p,i) = M2v(rad2deg(M_S_ELFO),e_S_ELFO); 
    end
end

coe_S_ELFO_op =   [a_S_ELFO,e_S_ELFO,i_op,0,90,v_S_ELFO(1,1)
                a_S_ELFO,e_S_ELFO,i_op,0,90,v_S_ELFO(1,2)
                a_S_ELFO,e_S_ELFO,i_op,0,90,v_S_ELFO(1,3)
                a_S_ELFO,e_S_ELFO,i_op,0,90,v_S_ELFO(1,4)
                a_S_ELFO,e_S_ELFO,i_op,120,90,v_S_ELFO(2,1)
                a_S_ELFO,e_S_ELFO,i_op,120,90,v_S_ELFO(2,2)
                a_S_ELFO,e_S_ELFO,i_op,120,90,v_S_ELFO(2,3)
                a_S_ELFO,e_S_ELFO,i_op,120,90,v_S_ELFO(2,4)
                a_S_ELFO,e_S_ELFO,i_op,240,90,v_S_ELFO(3,1)
                a_S_ELFO,e_S_ELFO,i_op,240,90,v_S_ELFO(3,2)
                a_S_ELFO,e_S_ELFO,i_op,240,90,v_S_ELFO(3,3)
                a_S_ELFO,e_S_ELFO,i_op,240,90,v_S_ELFO(3,4)];

coe_S_ELFO = coeOPtocoeMCI(coe_S_ELFO_op,t0_ET,GM_Moon);

orbitPropHandler(coe_S_ELFO,"S-ELFO",t0_ET,numYears,stepSize,true,true)    

%need to convert op frame to mci
%Good SMA would be resonant with the lunar sideral period (27.3) (like
%1/30th or something) (2.732 or 1.366 days?)

%First Loop to produce plot showing orbits
% figure
% for orbit = 1:height(coeTundra)
%     [~,t_out,y_out] = orbitPropagator(coeTundra(orbit,:),t0_ET,oneDay,stepSize,false);
%     h = plot3(y_out(1,:),y_out(2,:),y_out(3,:)); hold on
%     % Plot a single dot at the starting position with the same color
%     startPos = y_out(:,1).';
%     plot3(startPos(1), startPos(2), startPos(3), '.', 'Color', h.Color, 'MarkerSize', 15)
% end
% 
% title("Orbit Plot - Moon-Centered Inertial")
% xlabel("X-Position [km]")
% ylabel("Y-Position [km]")
% zlabel("Z-Position [km]")
% %Plot the moon
% [x,y,z] = sphere;
% x = x*R_Moon;
% y = y*R_Moon;
% z = z*R_Moon;
% surf(x,y,z)
% colormap("gray")
% 
% axis equal, hold off
% 
% for orbit = 1:height(coeTundra)
%     [outputTable,t_out,y_out] = orbitPropagator(coeTundra(orbit,:),t0_ET,numYears,stepSize,true);
%     titlename = sprintf('Tundra Satellite %02d', orbit);
%     sgtitle(titlename)
%     filename = sprintf('Tundra_Satellite_%02d.csv', orbit);
%     writetable(outputTable,filename);
% end



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