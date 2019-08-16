% Extract voxel timecourses from ROIs using localiser
% TODO: Pass spmT through whole ROI mask and then create the preference
% masks which you can use to pass EPI data though, therefore only
% extracting the timecourses for 1000 voxels instead of all of V1
clear all

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

for SID = 1:length(Subjects)
    disp('Extracting timecourses.')
    
    ROIs = {'V1', 'V2'};
    ROIFolder = fullfile(PrDir, Subjects{SID}, 'Masks');

    fprintf('Subject %d / %d\n', SID, length(Subjects));

    if ~exist(ROIFolder,'dir')
        mkdir(ROIFolder);
    end

    % find EPI folders
    EPIFolders = dir(fullfile(PrDir, Subjects{SID}, 'Niftis', 'nc*'));

    ROIData = cell(length(EPIFolders), length(ROIs));

    % load EPI data and pass through ROI masks
    for iFolder = 1:length(EPIFolders)

        fprintf('Run %d / %d\n', iFolder, length(EPIFolders));

        % input EPIs
        EPIFiles = spm_select('FPList', fullfile(EPIFolders(iFolder).folder, EPIFolders(iFolder).name, 'Realigned'),'^rf.*\.nii$');
        EPIHeader = spm_vol(EPIFiles);
        EPIData = spm_read_vols(EPIHeader);
        nVox = numel(EPIData(:,:,:,1));
        nScans = size(EPIData, 4);
        EPIData = reshape(EPIData, nVox, nScans); % reshape 4D matrix to 2D (nVox x nScans)
        for iROI = 1:length(ROIs)
            ROIFile = fullfile(ROIFolder, sprintf('%s.nii', ROIs{iROI}));
            ROIHeader = spm_vol(ROIFile);
            ROIMask = spm_read_vols(ROIHeader);
            ROIMask = reshape(ROIMask, numel(ROIMask),1);

            ROIData{iFolder, iROI} = EPIData(ROIMask >= 1,:);
        end

        clear EPIdata
    end

    % also pass SPMT and beta maps from localiser analysis through ROIs
    for j = 1:2
        SPMTFile = fullfile(PrDir, Subjects{SID}, 'FirstLevel', 'Localiser', sprintf('spmT_000%d.nii', j));
        SPMTHeader = spm_vol(SPMTFile);
        SPMTData{j} = spm_read_vols(SPMTHeader);
        SPMTData{j} = reshape(SPMTData{j}, nVox, 1); 
    end
    
    betaInds = 1:21;
    betaData = zeros(numel(SPMTData{1}), length(betaInds));   

    for iBeta = 1:length(betaInds)
        betaFile = fullfile(PrDir, Subjects{SID}, 'FirstLevel', 'Localiser' , sprintf('beta_%04g.nii', betaInds(iBeta)));
        betaHeader = spm_vol(betaFile);
        tmp = spm_read_vols(betaHeader);
        betaData(:,iBeta) = reshape(tmp, nVox, 1);
    end
    
    SPMT_ROIdata = cell(1, length(ROIs));
    beta_ROIdata = cell(1, length(ROIs));

    for iROI = 1:length(ROIs)
        ROIFile = fullfile(ROIFolder, sprintf('%s.nii', ROIs{iROI}));
        ROIHeader = spm_vol(ROIFile);
        ROIMask = spm_read_vols(ROIHeader);
        ROIMask = reshape(ROIMask, numel(ROIMask), 1);
        
        for i = 1:2
            SPMT_ROIdata{iROI}{i} = SPMTData{i}(ROIMask >= 1, :);
        end
        beta_ROIdata{iROI} = betaData(ROIMask >= 1, :);
    end
        
    % save ROI data
    for iROI = 1:length(ROIs)
        ROIdataFile = fullfile(ROIFolder, sprintf('%s_data.mat', ROIs{iROI}));
        EPIData = ROIData(:, iROI);
        SPMTData = SPMT_ROIdata{iROI};
        betaData = beta_ROIdata{iROI};

        save(ROIdataFile, 'EPIData', 'SPMTData', 'betaData');

    end
end