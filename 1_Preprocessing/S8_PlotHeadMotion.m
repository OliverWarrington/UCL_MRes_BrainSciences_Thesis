% Plot and save head motion 
% TODO: Set consistent scale (ylim) for rotation plot
% Remake plots after doing that

Subjects = {'sub-05' 'sub-06'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)
    
    EPIFolders = dir(fullfile(PrDir, Subjects{SID}, '/Niftis/nc*'));
    
    for iFolder = 1:length(EPIFolders)
        
        FuncFolder = fullfile(EPIFolders(iFolder).folder, EPIFolders(iFolder).name, '/Realigned/');
        MotionFile = dir(fullfile(FuncFolder, 'rp*.txt'));
        
        fid = fopen(fullfile(FuncFolder, MotionFile(1).name), 'r');
        rp = fscanf(fid, ' %e %e %e %e %e %e', [6, inf])';
        fclose(fid);
        
        hf = figure('Position', get(0, 'ScreenSize'));
        set(hf, 'Color', 'w');
        
        subplot(2, 1, 1);
        plot(rp(:, 1:3));
        title('Translation', 'Fontsize', 20);
        ylabel('Distance (mm)', 'Fontsize', 18);
        xlabel('Time (scans)', 'Fontsize', 18);
        
        % Set axis fontsize
        set(gca, 'Fontsize', 16); 
        % Set x-axis to go from 1-number of scans
        set(gca, 'XLim', [1 size(rp,1)]);
        % Set y-axis to be the same for all images
        set(gca, 'YLim', [-2 2]);
%         set(gca, 'YTick', [-2:0.5:2]);
        box off;
        
        % Add legend at location outside the graph
        hl = legend('x-axis', 'y-axis', 'z-axis', 'Location', 'BestOutside');
        % Set fontsize of the legend
        set(hl, 'Fontsize', 18);
        
        subplot(2, 1, 2);
        plot(rp(:, 4:6));
        title('Rotation', 'Fontsize', 20);
        ylabel('Rotation (degrees)', 'Fontsize', 18);
        xlabel('Time (scans)', 'Fontsize', 18);
        set(gca, 'Fontsize', 16);
        set(gca, 'XLim', [1 size(rp,1)]);
        box off;
        hl = legend('x-axis', 'y-axis', 'z-axis', 'Location', 'BestOutside');
        set(hl, 'Fontsize', 18);
        
        name = fullfile(FuncFolder, sprintf('realignment_parameters_%s_run%d.jpg', Subjects{SID}, iFolder));
        saveas(hf, name, 'jpg');
        
        % extend rp; include derivs and derivs squared
        R = rp;
        R(:,7:12) = [zeros(1,6) ; diff(R)];
        R(:,13:18) = R(:,7:12) .^ 2;
        % save to a .mat file
        motRegrFile = fullfile(FuncFolder,'rp_extended.mat');
        save(motRegrFile, 'R');
        
    end
end
        
        