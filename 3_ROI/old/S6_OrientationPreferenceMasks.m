% Create masks for right and left tilting preference.
% TODO: Merge this with the extract ROI timecourse step
clear all

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

ROIs = {'V1' 'V2'};
ori = {'Right', 'Left'};

disp('Creating right/left preference masks.')

for SID = 1:length(Subjects)
    
    for iROI = 1:length(ROIs)
        
        fprintf('Processing %s\n', ROIs{iROI});
        
        % Load ROI data
        ROIFolder = fullfile(PrDir, Subjects{SID}, 'Masks');
        ROIfile = fullfile(ROIFolder, sprintf('%s_data.mat', ROIs{iROI}));
        ROIfile = load(ROIfile, 'EPIData', 'SPMTData', 'betaData');
        
        EPIdata = ROIfile.EPIData;
        betaData = ROIfile.betaData;
        TotalActivity = ROIfile.SPMTData(1);
        LeftRight = ROIfile.SPMTData(2);

        % Find and delete voxels not matching criteria
        critT = 1.65; % Check value to use
        tmp = find(TotalActivity{1} < critT);
        TotalActivity{1}(tmp) = [];
        betaData(tmp, :) = [];
        for i = 1:length(EPIdata)
            EPIdata{i}(tmp, :) = [];
        end
        
        % Sort all data by T value
        [val, sortedVox] = sort(TotalActivity{1}, 'descend');
        TotalActivity{1} = TotalActivity{1}(sortedVox);
        betaData = betaData(sortedVox, :);
        for i = 1:length(EPIdata)
            EPIdata{i} = EPIdata{i}(sortedVox, :);
        end
        
%         % Take the 500 voxels with the highest T value (right preferring)
        rightT = TotalActivity{1}(1:500);
        rightBeta = betaData(1:500, :);
        rightEPI = cell(5, 1);
        for i = 1:length(EPIdata)
            rightEPI{i} = EPIdata{i}(1:500, :);
        end
        
        % Take the 500 voxels with the lowest T value (left preferring)
        leftT = TotalActivity{1}(end-499:end);
        leftBeta = betaData(end-499:end, :);
        leftEPI = cell(5, 1);
        for i = 1:length(EPIdata)
            leftEPI{i} = EPIdata{i}(end-499:end, :);
        end
        
%         % save ROI right/left data
%         for iORI = 1:length(ori)
%             dataFile = fullfile(ROIFolder, sprintf('%s_%s_data.mat', ori{iORI}, ROIs{iROI}));
%             
%             % Right
%             if iORI == 1
%                 % Save .mat and .nii files
%                 save(dataFile, 'leftEPI', 'leftT', 'leftBeta');
%                 for i = 1:length(EPIdata)
%                     niiName = fullfile(ROIFolder, sprintf('%s_%s_Run%d.nii', ori{iORI}, ROIs{iROI}, i));
%                     niftiwrite(leftEPI{i}, niiName);
%                 end     
%             
%             % Left
%             elseif iORI == 2
%                 % Save .mat and .nii files
%                 save(dataFile, 'rightEPI', 'rightT', 'rightBeta');
%                 for i = 1:length(EPIdata)
%                     niiName = fullfile(ROIFolder, sprintf('%s_%s_Run%d.nii', ori{iORI}, ROIs{iROI}, i));
%                     niftiwrite(rightEPI{i}, niiName);
%                 end 
%             end
%         end
    end
end
    