function orbitPropHandler(coeTable,satType,t0_ET,numYears,stepSize,showOrbits,showElements)
    GM_Moon = 4902.800; %[km^3/s^2]
    R_Moon = 1737.4;    %[km]
    
    numSecs = 365.25 * 24 * 3600 * numYears;
    final_target_time = t0_ET + numSecs;
    commonView = [45, 30]; 
    numOrbits = height(coeTable);
    
    if showOrbits
        fig = figure;
        % tiledlayout keeps subplots exactly the same size when adding a legend
        tl = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact'); 
        
        % --- SETUP INITIAL ORBIT PLOT (left) ---
        ax1 = nexttile(tl);
        hold(ax1, 'on')
        [x,y,z] = sphere;
        surf(ax1, x*R_Moon, y*R_Moon, z*R_Moon, 'HandleVisibility', 'off')
        colormap(ax1, "gray")
        axis(ax1, 'equal')
        view(ax1, commonView) 
        title(ax1, "Initial Orbit Plot - Moon-Centered Inertial")
        xlabel(ax1, "X-Position [km]")
        ylabel(ax1, "Y-Position [km]")
        zlabel(ax1, "Z-Position [km]")
        grid on
        
        % --- SETUP FINAL ORBIT PLOT (right) ---
        ax2 = nexttile(tl);
        hold(ax2, 'on')
        surf(ax2, x*R_Moon, y*R_Moon, z*R_Moon, 'HandleVisibility', 'off')
        colormap(ax2, "gray")
        axis(ax2, 'equal')
        view(ax2, commonView) 
        title(ax2, "Final Orbit Plot - Moon-Centered Inertial")
        xlabel(ax2, "X-Position [km]")
        ylabel(ax2, "Y-Position [km]")
        zlabel(ax2, "Z-Position [km]")
        grid on
    end
    
    for orbit = 1:numOrbits
        % Moved inside the loop: Ensure orbit period is calculated for EACH specific satellite
        orbitPeriod = 2*pi*sqrt(coeTable(orbit,1)^3 / GM_Moon);
        
        satLabel = sprintf('%s Satellite %02d', satType, orbit);
        
        % Propagate ONLY ONCE per satellite
        [outputTable,t_out,y_out] = orbitPropagator(coeTable(orbit,:),t0_ET,numYears,stepSize,showElements,satLabel);
        
        if showOrbits
            % --- PLOT INITIAL ORBIT STATE ---
            % Find indices for the first orbital period
            idx_init_period = t_out <= (t_out(1) + orbitPeriod);
            
            % Plot trajectory for initial period on ax1
            h = plot3(ax1, y_out(1, idx_init_period), y_out(2, idx_init_period), y_out(3, idx_init_period), 'DisplayName', satLabel);
            
            % Plot start dot
            startPos = y_out(:,1).';
            plot3(ax1, startPos(1), startPos(2), startPos(3), '.', 'Color', h.Color, 'MarkerSize', 15, 'HandleVisibility', 'off');
            
            % --- PLOT FINAL ORBIT STATE ---
            if t_out(end) >= (final_target_time - stepSize*2)
                % Find indices for the last orbital period
                idx_final_period = t_out >= (t_out(end) - orbitPeriod);
                
                % Plot trajectory on ax2 (HandleVisibility off to avoid duplicate legend entries)
                plot3(ax2, y_out(1, idx_final_period), y_out(2, idx_final_period), y_out(3, idx_final_period), 'Color', h.Color, 'HandleVisibility', 'off');
                
                % Plot end dot
                finalPos = y_out(:, end).';
                plot3(ax2, finalPos(1), finalPos(2), finalPos(3), '.', 'Color', h.Color, 'MarkerSize', 15, 'HandleVisibility', 'off');
            end
        end
        
        if showElements
            if exist('fig','var') && isvalid(fig)
                sgtitle(fig, satLabel)
            else
                sgtitle(satLabel)
            end
        end
        
        filename = sprintf('%s_Satellite_%02d.csv', satType, orbit);
        writetable(outputTable,filename);
    end
    
    if showOrbits
        hold(ax1, 'off')
        hold(ax2, 'off')
        
        % Attach legend to the tiled layout rather than a specific axis
        lgd = legend(ax1);
        lgd.Layout.Tile = 'east';
    end
end