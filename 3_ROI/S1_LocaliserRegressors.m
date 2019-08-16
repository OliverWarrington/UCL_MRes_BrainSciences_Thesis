% Create variables that allow a first level GLM design.
clear all

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

TR = 3.5832;
stimDur = 14.3328;
iRun = 1;
names = {'right', 'left' };  %'fixation'

for SID = 1:length(Subjects)
    
     behFiles = dir(fullfile(PrDir, Subjects{SID}, 'beh/results_loc*'));
     load(fullfile(behFiles.folder, behFiles.name));
    
     for i = 1:length(names)
         onsets{i} = [];
         durations{i} = [];
     end

    startTime = data.initialTime;

    for iBlock = 1:size(data.stimOrder, 1) % 16 Blocks

        for iTrial = 1:2:3 % 1 and 3 because stimOrder = [1 NaN 2 NaN] etc
            
            if data.stimOrder(iBlock, iTrial) == 1 % 1 = 45 (right)

                onsets{1} = [onsets{1}, data.presentationTime(iBlock,iTrial,1) - startTime];
                
            elseif data.stimOrder(iBlock, iTrial) == 2 % 2 = 135 (left)
                
                onsets{2} = [onsets{2}, data.presentationTime(iBlock,iTrial,1) - startTime];
                
            end

        end
       
    % fixation block onsets
    % onsets{3} = [onsets{3}, presentation_time(iblock,2,end)- start_time];
        

    end

    % Convert from seconds to scans.
    for i = 1:length(names)
        onsets{i} = onsets{i} - 0.5 * TR; % No slice time correction (assume onset in middle of scan)
        onsets{i} = onsets{i} / TR;
    end

    % store durations
    for i = 1:length(names)
        nTrials = length(onsets{i});
        durations{i} = zeros(1, nTrials);
        durations{i}(:) = stimDur / TR; % 4 scans
    end

    %save variables
    outFile = 'cond_localiser.mat';
    outDir = fullfile(PrDir, Subjects{SID}, 'FirstLevel', 'Localiser');
    if ~exist(outDir,'dir'); mkdir(outDir); end
    save([outDir, '/', outFile], 'names', 'onsets', 'durations');

end
