% Create variables that allow a first level GLM design.
clear all

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

TR = 3.5832;
names = {'Stim45', 'Stim135', 'Omis45', 'Omis135'};  %'fixation'

for SID = 1:length(Subjects)
    
     behFiles = dir(fullfile(PrDir, Subjects{SID}, 'beh/results_main*'));
     
    for iRun = 1:length(behFiles)
        load(fullfile(behFiles(iRun).folder, behFiles(iRun).name));
        
        % orientation 1 = 45 degrees
        % orientation 2 = 135 degrees
        if data{1}.runType == 1
            % orientation task
            names = {'Stim45deg_Orient', 'Stim135deg_Orient', 'Omit45deg_Orient', 'Omit135deg_Orient'};
        elseif data{1}.runType == 2
            % contrast task
            names = {'Stim45deg_Contrast', 'Stim135deg_Contrast', 'Omit45deg_Contrast', 'Omit135deg_Contrast'};
        end
        
        for i = 1:length(names)
            onsets{i} = [];
            durations{i} = [];
        end
        
        startTime = data{1}.initialTime;
        for iBlock = 1:length(data)
            for iTrial = 1:data{iBlock}.nTrialsPerBlock
                predOrient = data{iBlock}.predOrientation(iTrial);
                if ~isnan(data{iBlock}.grating1Orientation(iTrial))
                    onsets{predOrient} = [onsets{predOrient}, data{iBlock}.presentationTime{iTrial}(2) - startTime];
                else
                    onsets{predOrient+2} = [onsets{predOrient+2}, data{iBlock}.presentationTime{iTrial}(1)+0.5 - startTime];
                end
            end
        end
        
        % Convert from seconds to scans.
        for i = 1:length(names)
            onsets{i} = onsets{i} / TR;
        end
        
        % store durations
        for i = 1:length(names)
            nTrials = length(onsets{i});
            durations{i} = zeros(1, nTrials);
            durations{i}(:) = stimDur / TR;
        end
        
        %save variables
        outFile = sprintf('cond_run%d.mat',runNrs(iRun));
        outDir = fullfile(rootDir, 'Subject_data', subjects{SID}, 'TaskRegressors');
        if ~exist(outDir,'dir'); mkdir(outDir); end
        save(fullfile(outDir,outFile), 'names', 'onsets', 'durations');
    end
    
end