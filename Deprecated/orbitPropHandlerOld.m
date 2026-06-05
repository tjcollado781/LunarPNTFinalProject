function orbitPropHandler(coeTable,satType,t0_ET,numYears,stepSize,showOrbits,showElements)
%coeTable,t0_ET,numYears,stepSize,showOrbits,showElemets

GM_Moon = 4902.800; %[km^3/s^2]
R_Moon = 1737.4;    %[km]
orbitPeriod = 2*pi*sqrt(coeTable(1,1)^3 / GM_Moon)

if showOrbits
    figure
    for orbit = 1:height(coeTable)
        [~,t_out,y_out] = orbitPropagator(coeTable(orbit,:),t0_ET,orbitPeriod/3.154e+7,stepSize,false);
        h = plot3(y_out(1,:),y_out(2,:),y_out(3,:)); hold on
        % Plot a single dot at the starting position with the same color
        startPos = y_out(:,1).';
        plot3(startPos(1), startPos(2), startPos(3), '.', 'Color', h.Color, 'MarkerSize', 15)
    end
    
    title("Inital Orbit Plot - Moon-Centered Inertial")
    xlabel("X-Position [km]")
    ylabel("Y-Position [km]")
    zlabel("Z-Position [km]")
    %Plot the moon
    [x,y,z] = sphere;
    x = x*R_Moon;
    y = y*R_Moon;
    z = z*R_Moon;
    surf(x,y,z)
    colormap("gray")

axis equal, hold off

numSecs = 365.25*24*3600*numYears
finalOrbitTime = t0_ET + numSecs - orbitPeriod

end

% hWait = waitbar(0,'Propagating orbits...','Name','Orbit Propagation Progress');
% nOrbits = height(coeTable);
% for orbit = 1:nOrbits
%     satLabel = sprintf('%s Satellite %02d', satType, orbit);
%     waitbar((orbit-1)/nOrbits,hWait,sprintf('Propagating %s (%d of %d)...', satLabel, orbit, nOrbits));
%     [outputTable,t_out,y_out] = orbitPropagator(coeTable(orbit,:),t0_ET,numYears,stepSize,showElements);
%     titlename = satLabel;
%     sgtitle(titlename)
%     filename = sprintf('%s_Satellite_%02d.csv', satType, orbit);
%     writetable(outputTable,filename);
% end
% waitbar(1,hWait,'Completed');
% pause(0.25); % allow users to see completion
% close(hWait);

for orbit = 1:height(coeTable)
    [outputTable,t_out,y_out] = orbitPropagator(coeTable(orbit,:),t0_ET,numYears,stepSize,showElements);
    titlename = sprintf('%s Satellite %02d', satType, orbit);
    sgtitle(titlename)
    filename = sprintf('%s_Satellite_%02d.csv', satType, orbit);
    writetable(outputTable,filename);
end