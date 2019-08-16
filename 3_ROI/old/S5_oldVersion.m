% Extract voxel timecourses from ROIs using localiser
clear all

PrDir = '/Users/OliverW/Desktop/Project/Subjects';
Subjects = {'sub-03'};

for SID = 1:length(Subjects)
    disp('Extracting timecourses.')
    
    ROIs = {'V1', 'V2'};
    ROIFolder = fullfile(PrDir, Subjects{SID}, 'Masks');
    meanEPIFile = fullfile(PrDir, Subjects{SID}, 'Functional', 'meanfunctional.nii');

    fprintf('Subject %d / %d\n', SID, length(Subjects));

    if ~exist(ROIFolder,'dir')
        mkdir(ROIFolder);
    end

    % find EPI folders
    EPIfolders = dir(fullfile(PrDir, Subjects{SID}, 'Niftis', 'nc*'));

    ROIdata = cell(length(EPIfolders), length(ROIs));

    % load EPI data and pass through ROI masks
    for iFolder = 1:length(EPIfolders)

        fprintf('Run %d / %d\n', iFolder, length(EPIfolders));

        % input EPIs
        EPIfiles = spm_select('FPList', fullfile(EPIfolders(iFolder).folder, EPIfolders(iFolder).name, 'Realigned'),'^rf.*\.nii$');
        EPIheader = spm_vol(EPIfiles);
        EPIdata = spm_read_vols(EPIheader);
        nVox = numel(EPIdata(:,:,:,1));
        nScans = size(EPIdata, 4);
        EPIdata = reshape(EPIdata, nVox, nScans); % reshape 4D matrix to 2D (nVox x nScans)
        for iROI = 1:length(ROIs)
            ROIfile = fullfile(ROIFolder, sprintf('%s.nii', ROIs{iROI}));
            ROIheader = spm_vol(ROIfile);
            ROImask = spm_read_vols(ROIheader);
            ROImask = reshape(ROImask,nVox,1);

            ROIdata{iFolder, iROI} = EPIdata(ROImask >= 1,:);
        end

        clear EPIdata
    end

    % also pass SPMT and beta maps from localiser analysis through ROIs
    SPMTfile = fullfile(PrDir, Subjects{SID}, 'beh', 'results', 'FirstLevel', 'Localiser', 'spmT_0001.nii');
    SPMTheader = spm_vol(SPMTfile);
    SPMTdata = spm_read_vols(SPMTheader);
    SPMTdata = reshape(SPMTdata, nVox, 1);
    
    betaInds = 1:21;
    betaData = zeros(numel(SPMTdata), length(betaInds));
    
    for iBeta = 1:length(betaInds)
        betaFile = fullfile(PrDir, Subjects{SID}, 'beh', 'results', 'FirstLevel', 'Localiser' ,sprintf('beta_%04g.nii', betaInds(iBeta)));
        betaHeader = spm_vol(betaFile);
        tmp = spm_read_vols(betaHeader);
        betaData(:,iBeta) = reshape(tmp,nVox,1);
    end
    
    SPMT_ROIdata = cell(1, length(ROIs));
    beta_ROIdata = cell(1, length(ROIs));
    
    for iROI = 1:length(ROIs)
        ROIfile = fullfile(ROIFolder, sprintf('%s.nii', ROIs{iROI}));
        ROIheader = spm_vol(ROIfile);
        ROImask = spm_read_vols(ROIheader);
        ROImask = reshape(ROImask,nVox,1);

        SPMT_ROIdata{iROI} = SPMTdata(ROImask >= 1, :);
        beta_ROIdata{iROI} = betaData(ROImask >= 1, :);
    end

    % save ROI data
    for iROI = 1:length(ROIs)
        ROIdataFile = fullfile(ROIFolder, sprintf('%s_data.mat', ROIs{iROI}));
        EPIdata = ROIdata(:, iROI);
        SPMTdata = SPMT_ROIdata{iROI};
        betaData = beta_ROIdata{iROI};
        
%         % bit of a hack; for visual cortex, only save the 1000 most
%         % active voxels.
%         if strcmp(ROIs{iROI},'V1') || strcmp(ROIs{iROI},'V2')
%             [val, ind] = sort(SPMTdata,'descend');
%             selVox = ind(1:1000);
%             
%             for i = 1:length(EPIdata)
%                EPIdata{i} = EPIdata{i}(selVox,:);
%             end
%             
%             SPMTdata = SPMTdata(selVox);
%             betaData = betaData(selVox,:);
%             
%         end
        
        save(ROIdataFile, 'EPIdata', 'SPMTdata', 'betaData');
        
    end
end