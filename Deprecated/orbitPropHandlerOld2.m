function orbitPropHandler(coeTable,satType,t0_ET,numYears,stepSize,showOrbits,showElements)
%coeTable,t0_ET,numYears,stepSize,showOrbits,showElements
GM_Moon = 4902.800; %[km^3/s^2]
R_Moon = 1737.4;    %[km]
orbitPeriod = 2*pi*sqrt(coeTable(1,1)^3 / GM_Moon);

numSecs = 365.25*24*3600*numYears;
final_target_time = t0_ET + numSecs;

if showOrbits
    % --- INITIAL ORBIT PLOT ---
    figure
    for orbit = 1:height(coeTable)
        satLabel = sprintf('%s Satellite %02d', satType, orbit);
        [~,t_out,y_out] = orbitPropagator(coeTable(orbit,:),t0_ET,orbitPeriod/3.154e+7,stepSize,false);
        h = plot3(y_out(1,:),y_out(2,:),y_out(3,:), 'DisplayName', satLabel); hold on
        
        % Plot a single dot at the starting position (hidden from legend)
        startPos = y_out(:,1).';
        plot3(startPos(1), startPos(2), startPos(3), '.', 'Color', h.Color, 'MarkerSize', 15, 'HandleVisibility', 'off')
    end
    
    title("Initial Orbit Plot - Moon-Centered Inertial")
    xlabel("X-Position [km]")
    ylabel("Y-Position [km]")
    zlabel("Z-Position [km]")
    
    %Plot the moon (hidden from legend)
    [x,y,z] = sphere;
    surf(x*R_Moon, y*R_Moon, z*R_Moon, 'HandleVisibility', 'off')
    colormap("gray")
    
    legend('show', 'Location', 'best')
    axis equal, hold off
    
    % --- PREPARE FINAL ORBIT PLOT ---
    fig_final = figure;
    title("Final Orbit Plot - Moon-Centered Inertial")
    xlabel("X-Position [km]")
    ylabel("Y-Position [km]")
    zlabel("Z-Position [km]")
    hold on
    surf(x*R_Moon, y*R_Moon, z*R_Moon, 'HandleVisibility', 'off')
    colormap("gray")
    axis equal
    view(3)
end

for orbit = 1:height(coeTable)
    [outputTable,t_out,y_out] = orbitPropagator(coeTable(orbit,:),t0_ET,numYears,stepSize,showElements);
    satLabel = sprintf('%s Satellite %02d', satType, orbit);
    
    % --- CAPTURE FINAL ORBIT STATE ---
    if showOrbits
        % Check if the orbit survived to the end (allowing a small tolerance of 2 step sizes)
        if t_out(end) >= (final_target_time - stepSize*2)
            % Target the final figure without forcing it to steal screen focus every loop
            set(0, 'CurrentFigure', fig_final);
            
            % Find indices for the last orbital period
            idx_final_period = t_out >= (t_out(end) - orbitPeriod);
            
            % Plot the trajectory for only the final period
            h = plot3(y_out(1, idx_final_period), y_out(2, idx_final_period), y_out(3, idx_final_period), 'DisplayName', satLabel);
            
            % Plot a dot at the final ending position (hidden from legend)
            finalPos = y_out(:, end).';
            plot3(finalPos(1), finalPos(2), finalPos(3), '.', 'Color', h.Color, 'MarkerSize', 15, 'HandleVisibility', 'off');
        end
    end
    
    if showElements
        % Ensure sgtitle applies to the figure created by orbitPropagator, if any
        sgtitle(satLabel)
    end
    filename = sprintf('%s_Satellite_%02d.csv', satType, orbit);
    writetable(outputTable,filename);
end

if showOrbits
    % Release the hold on the final plot and show its legend
    set(0, 'CurrentFigure', fig_final);
    legend('show', 'Location', 'best');
    hold off;
end
end