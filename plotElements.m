function plotElements(t_out,y_out,mu,R_Moon,satLabel)

len = length(y_out);

a = zeros(1,len);
e = zeros(1,len);
i = zeros(1,len);
LAAN = zeros(1,len);
w = zeros(1,len);



for step = 1:len
    [a(step),e(step),i(step),LAAN(step),w(step),~] = orbitEl(y_out(:,step),mu);
end

% prepare time vector in days since epoch for plotting
t_plot = (t_out - t_out(1))/(24*3600);

figure
% subplot order: 3 rows x 2 cols, leave one blank (use subplot and do nothing on that axis)
subplot(2,3,1)
plot(t_plot,a), grid on, hold on
peri = a.*(1-e);
plot(t_plot,peri), 
yline(R_Moon), hold off
xlabel('Time [days]'), ylabel('Semi-major axis [km]')
title('a vs Time')

subplot(2,3,2)
plot(t_plot,e), grid on
xlabel('Time [days]'), ylabel('Eccentricity')
title('e vs Time')

subplot(2,3,3)
plot(t_plot,rad2deg(i)), grid on
xlabel('Time [days]'), ylabel('Inclination [deg]')
title('i vs Time')

subplot(2,3,4)
plot(t_plot,rad2deg(LAAN)), grid on
xlabel('Time [days]'), ylabel('RAAN [deg]')
title('RAAN vs Time')

subplot(2,3,5)
plot(t_plot,rad2deg(w)), grid on
xlabel('Time [days]'), ylabel('Arg. of Perigee [deg]')
title('\omega vs Time')

subplot(2,3,6)
plot3(y_out(1,:),y_out(2,:),y_out(3,:)), hold on
title("Orbit Plot - Moon-Centered Inertial")
xlabel("X-Position [km]")
ylabel("Y-Position [km]")
zlabel("Z-Position [km]")
%Plot the moon
[x,y,z] = sphere;
x = x*R_Moon;
y = y*R_Moon;
z = z*R_Moon;
surf(x,y,z), hold off
colormap("gray")
axis equal

sgtitle(satLabel)

set(gcf,'Color','w')

%have the orbit plot be the 6th window, and reorient to be horizontal

end