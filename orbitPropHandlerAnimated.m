function orbitPropHandler(coeTable, satType, t0_ET, numYears, stepSize, showOrbits, showElements)
    GM_Moon = 4902.800; %[km^3/s^2]
    R_Moon = 1737.4;    %[km]
    
    numSecs = 365.25 * 24 * 3600 * numYears;
    final_target_time = t0_ET + numSecs;
    commonView = [45, 30]; 
    numOrbits = height(coeTable);
    
    % --- 1. PRE-ALLOCATE STORAGE FOR ANIMATION ---
    if showOrbits
        all_y_out = cell(numOrbits, 1);
        all_t_out = cell(numOrbits, 1);
        satLabels = cell(numOrbits, 1);
        tail_lengths = zeros(numOrbits, 1); 
    end
    
    % --- 2. PROPAGATE ALL ORBITS ---
    for orbit = 1:numOrbits
        satLabel = sprintf('%s Satellite %02d', satType, orbit);
        
        if showOrbits
            satLabels{orbit} = satLabel;
            orbitPeriod = 2*pi*sqrt(coeTable(orbit,1)^3 / GM_Moon);
            tail_lengths(orbit) = max(10, round(orbitPeriod / stepSize)); 
        end
        
        [outputTable, t_out, y_out] = orbitPropagator(coeTable(orbit,:), t0_ET, numYears, stepSize, showElements, satLabel);
        
        if showOrbits
            all_y_out{orbit} = y_out;
            all_t_out{orbit} = t_out;
        end
        
        if showElements
            sgtitle(satLabel)
        end
        
        filename = sprintf('%s_Satellite_%02d.csv', satType, orbit);
        writetable(outputTable, filename);
    end
    
    % --- 3. ANIMATE AND SAVE VIDEO ---
    if showOrbits
        fig = figure;
        
        % Force figure to a specific size for consistent video resolution
        fig.Position = [100, 100, 1280, 720]; 
        
        ax = axes('Parent', fig);
        hold(ax, 'on')
        
        % Setup Moon Environment
        [x, y, z] = sphere;
        surf(ax, x*R_Moon, y*R_Moon, z*R_Moon, 'HandleVisibility', 'off', 'EdgeColor', 'none')
        colormap(ax, "gray")
        axis(ax, 'equal')
        view(ax, commonView) 
        title(ax, "Satellite Orbit Animation")
        xlabel(ax, "X-Position [km]")
        ylabel(ax, "Y-Position [km]")
        zlabel(ax, "Z-Position [km]")
        grid on
        
        % --- LOCK AXES LIMITS ---
        max_extent = R_Moon; 
        for orbit = 1:numOrbits
            current_max = max(abs(all_y_out{orbit}(1:3, :)), [], 'all');
            max_extent = max(max_extent, current_max);
        end
        
        max_extent = max_extent * 1.1; 
        xlim(ax, [-max_extent, max_extent]);
        ylim(ax, [-max_extent, max_extent]);
        zlim(ax, [-max_extent, max_extent]);
        axis(ax, 'manual'); 
        
        colors = lines(numOrbits); 
        traj_lines = gobjects(numOrbits, 1);
        sat_markers = gobjects(numOrbits, 1);
        
        for orbit = 1:numOrbits
            traj_lines(orbit) = plot3(ax, NaN, NaN, NaN, '-', 'Color', colors(orbit,:), 'DisplayName', satLabels{orbit});
            sat_markers(orbit) = plot3(ax, NaN, NaN, NaN, '.', 'Color', colors(orbit,:), 'MarkerSize', 20, 'HandleVisibility', 'off');
        end
        
        legend(ax, 'Location', 'eastoutside');
        
        % --- SETUP VIDEO WRITER W/ SAVE PROMPT ---
        defaultFileName = sprintf('%s_Orbit_Animation.mp4', satType);
        [file, path] = uiputfile('*.mp4', 'Save Animation As', defaultFileName);
        
        saveVideo = ~(isequal(file, 0) || isequal(path, 0));
        
        if saveVideo
            videoName = fullfile(path, file);
            v = VideoWriter(videoName, 'MPEG-4');
            v.FrameRate = 30; 
            v.Quality = 100;
            open(v);
        else
            disp('Save canceled by user. Playing animation on screen without saving.');
        end
        
        % --- FRAME-LOCKED ANIMATION LOOP ---
        numSteps = length(all_t_out{1});
        targetFrames = 300; 
        frameSkip = max(1, round(numSteps / targetFrames)); 
        
        baseFrameSize = []; 
        
        for k = 1:frameSkip:numSteps
            for orbit = 1:numOrbits
                idx = min(k, length(all_t_out{orbit}));
                tail_start = max(1, idx - tail_lengths(orbit));
                
                current_X_history = all_y_out{orbit}(1, tail_start:idx);
                current_Y_history = all_y_out{orbit}(2, tail_start:idx);
                current_Z_history = all_y_out{orbit}(3, tail_start:idx);
                
                set(traj_lines(orbit), 'XData', current_X_history, ...
                                       'YData', current_Y_history, ...
                                       'ZData', current_Z_history);
                set(sat_markers(orbit), 'XData', all_y_out{orbit}(1, idx), ...
                                        'YData', all_y_out{orbit}(2, idx), ...
                                        'ZData', all_y_out{orbit}(3, idx));
            end
            
            drawnow; 
            
            if saveVideo
                frame = getframe(fig);
                
                % Lock frame dimensions to prevent VideoWriter crashes
                if isempty(baseFrameSize)
                    baseFrameSize = size(frame.cdata);
                end
                
                currSize = size(frame.cdata);
                if any(currSize ~= baseFrameSize)
                    fixed_cdata = uint8(zeros(baseFrameSize));
                    r = min(baseFrameSize(1), currSize(1));
                    c = min(baseFrameSize(2), currSize(2));
                    fixed_cdata(1:r, 1:c, :) = frame.cdata(1:r, 1:c, :);
                    frame.cdata = fixed_cdata;
                end
                
                writeVideo(v, frame);
            end
        end
        
        if saveVideo
            close(v);
            fprintf('Animation saved successfully to %s\n', videoName);
        end
        hold(ax, 'off')
    end
end