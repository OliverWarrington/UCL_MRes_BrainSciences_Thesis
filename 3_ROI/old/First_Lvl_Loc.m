% Make this regressors for localiser only atm.

% TODO:
%   Check the names 
%   What do I need for runType == 2?
%   Where do the predicted orientations come in?


Subjects = {'sub-03'};
Pr_dir = '/Users/OliverW/Desktop/Project/Subjects/';
TR = 3.5832; 

for SID = 1:length(Subjects)
	behDir = [Pr_dir, Subjects{SID}, '/beh'];
	outDir = [Pr_dir, Subjects{SID}, '/beh/results'];
	
	if ~exist(outDir,'dir')
		mkdir(outDir);
    end

    % Loading and sorting data by start time
	behFiles = dir(fullfile(behDir, 'results_loc*.mat'));
    for iRun = 1:length(behFiles)
        load(fullfile(behDir, behFiles(iRun).name));
        beh(iRun).data = data;
        time(iRun) = % Make this regressors for localiser only atm.

% TODO:
%   Check the names 
%   What do I need for runType == 2?
%   Where do the predicted orientations come in?


Subjects = {'sub-03'};
Pr_dir = '/Users/OliverW/Desktop/Project/Subjects/';
TR = 3.5832; 

for SID = 1:length(Subjects)
	behDir = [Pr_dir, Subjects{SID}, '/beh'];
	outDir = [Pr_dir, Subjects{SID}, '/beh/results'];
	
	if ~exist(outDir,'dir')
		mkdir(outDir);
    end

    % Loading and sorting data by start time
	behFiles = dir(fullfile(behDir, 'results_loc*.mat'));
    for iRun = 1:length(behFiles)
        % Skip run 2 for sub-01
        if iRun == 2
            continue
        else
            load(fullfile(behDir, behFiles(iRun).name));
            beh(iRun).data = data;
            time(iRun) = beh(iRun).data(1).initialTime;
        end
    end
    
    [val, ind] = sort(time);
    beh = beh(ind);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    for iRun = 1:length(beh)
        
        % Skip run 2 for sub-01
        if iRun == 2
            continue
        else

            for iBlock = 1:length(beh(iRun).data)

                if beh(iRun).data{iBlock}.runType == 1

                    % We have two conditions, left-tilted and right-tilted
                    % gratings
                    names = {'left' 'right'};

                    % Presentation time in 6x64 matrix
                    % 6 stimulus presentations in 64 trials 
                    % (1 column = 1 trial)
                    presTimes = cell2mat(beh(iRun).data{iBlock}.presentationTime);
                    presTimes = reshape(presTimes,numel(presTimes)/...
                        beh(iRun).data{iBlock}.nTrialsPerBlock,beh(iRun).data{iBlock}.nTrialsPerBlock);
                    presTimes = presTimes - beh(iRun).data{1}.initialTime;

                    % Onset of the first grating (e.g. trial start)
                    presTimes = presTimes(2,:); 

                    % Presentation of end fixation for duration calculation
                    % endTimes = presTimes(6, :);

                    for iCond = 1:length(names)
                        % Is orientation == 1 left tilted or other way around?
                        selTrials = (beh(iRun).data{iBlock}.grating1Orientation == iCond);

                        onsets{iCond} = [];
                        onsets{iCond} = [onsets{iCond} presTimes(selTrials)];
                        onsets{iCond} = onsets{iCond} - 0.5*TR;
                        onsets{iCond} = onsets{iCond} / TR;

                        % Why is durations empty??
                        durations{iCond} = [];
                        % durations{iCond} = endTimes(selTrials) - presTimes(selTrials);
                        durations{iCond} = durations{iCond} / TR; % for even related can = 0 but not slow e.g. localiser

                    end  

    %             elseif beh(iRun).data{iBlock}.runType == 2
                        % TODO
                        
                end
            end
        end
        % save variables in condition files
        regressorFile = sprintf('simpleModel_run%d.mat',iRun);
        regressorFile = fullfile(outDir,regressorFile);
        save(regressorFile, 'names', 'onsets', 'durations');
    end
end.data{1}.initialTime;
    end
    
    [val, ind] = sort(time);
    beh = beh(ind);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    for iRun = 1:length(beh)

        for iBlock = 1:length(beh(iRun).data)

            % We have two conditions, left-tilted and right-tilted
            % gratings
            names = {'left' 'right'};

            % Presentation time in 6x64 matrix
            % 6 stimulus presentations in 64 trials 
            % (1 column = 1 trial)
            presTimes = cell2mat(beh(iRun).data{iBlock}.presentationTime);
            presTimes = reshape(presTimes,numel(presTimes)/...
                beh(iRun).data{iBlock}.nTrialsPerBlock,beh(iRun).data{iBlock}.nTrialsPerBlock);
            presTimes = presTimes - beh(iRun).data{1}.initialTime;

            % Onset of the first grating (e.g. trial start)
            presTimes = presTimes(2,:); 

            % Presentation of end fixation for duration calculation
            % endTimes = presTimes(6, :);

            for iCond = 1:length(names)
                % Is orientation == 1 left tilted or other way around?
                selTrials = (beh(iRun).data{iBlock}.grating1Orientation == iCond);

                onsets{iCond} = [];
                onsets{iCond} = [onsets{iCond} presTimes(selTrials)];
                onsets{iCond} = onsets{iCond} - 0.5*TR;
                onsets{iCond} = onsets{iCond} / TR;

                % Why is durations empty??
                durations{iCond} = [];
                % durations{iCond} = endTimes(selTrials) - presTimes(selTrials);
                durations{iCond} = durations{iCond} / TR; % for even related can = 0 but not slow e.g. localiser

            end  
        end
    end
    % save variables in condition files
    regressorFile = sprintf('simpleModel_run%d.mat',iRun);
    regressorFile = fullfile(outDir,regressorFile);
    save(regressorFile, 'names', 'onsets', 'durations');
end