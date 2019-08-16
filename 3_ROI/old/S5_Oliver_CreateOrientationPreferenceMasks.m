clear all

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

for SID = 1:length(Subjects)

    %% Pass spmT and betas through ROI masks
    disp('Extracting timecourses.')
    
    ROIs = {'V1_dilM', 'V2_dilM'};
    ROIFolder = fullfile(PrDir, Subjects{SID}, 'Masks');

    fprintf('Subject %d / %d: %s \n', SID, length(Subjects), Subjects{SID});

    if ~exist(ROIFolder,'dir')
        mkdir(ROIFolder);
    end
    
    % Load in spmT and beta data
    for iSpmt = 1:2
        SPMTFile = fullfile(PrDir, Subjects{SID}, 'FirstLevel', 'Localiser', sprintf('spmT_000%d.nii', iSpmt));
        SPMTHeader = spm_vol(SPMTFile);
        SPMTData{iSpmt} = spm_read_vols(SPMTHeader);
        nVox = numel(SPMTData{1});
        SPMTData{iSpmt} = reshape(SPMTData{iSpmt}, nVox, 1); 
    end
    
    betaInds = 1:21;
    betaData = zeros(numel(SPMTData{1}), length(betaInds));   

    for iBeta = 1:length(betaInds)
        betaFile = fullfile(PrDir, Subjects{SID}, 'FirstLevel', 'Localiser' ,sprintf('beta_%04g.nii', betaInds(iBeta)));
        betaHeader = spm_vol(betaFile);
        tmp = spm_read_vols(betaHeader);
        betaData(:,iBeta) = reshape(tmp, nVox, 1);
    end
    
    SPMT_ROIdata = cell(1, length(ROIs));
    beta_ROIdata = cell(1, length(ROIs));
    
    % Load in ROI masks
    for iROI = 1:length(ROIs)
        ROIFile = fullfile(ROIFolder, sprintf('%s.nii', ROIs{iROI}));
        fprintf('Extracting spmT & betas for: %s \n', ROIs{iROI});
        ROIHeader = spm_vol(ROIFile);
        ROIMask = spm_read_vols(ROIHeader);
        ROIMask = reshape(ROIMask, numel(ROIMask), 1);
        
    % Pass spmT & betas through ROI masks    
        for i = 1:2
            SPMT_ROIdata{iROI}{i} = SPMTData{i}(ROIMask >= 1, :);
        end
        beta_ROIdata{iROI} = betaData(ROIMask >= 1, :);
    end
   
    %% Create Orientation Preference Masks and Save as .nii
    
    for iROI = 1:length(ROIs)
        
        fprintf('Creating orientation preference masks for: %s \n', ROIs{iROI});
        
        % Find and delete voxels not matching criteria
        critT = 3.0; 
        nVoxels = 1500; % Only going to take 500 right pref and 500 left pref from this
        TotalActivity = SPMT_ROIdata{iROI}{1};
        RightLeft = SPMT_ROIdata{iROI}{2};
        
        % Sort by T value       
        [val, sortedVox] = sort(TotalActivity, 'descend');
        
        % How many do we have above the threshold?
        sigVox = numel(TotalActivity(TotalActivity > critT));
        
        % Find the indices of the strongest voxels 
        % (Still taking 1000 even if not all sig atm)
        StrongVox = sortedVox(1:nVoxels);
        
        % Split voxels into Right and Left
        RightVox = StrongVox(1:500);
        LeftVox = StrongVox(end-499:end);
        
        % Make the indices match the size of the EPIData
        Right = zeros(nVox, 1);
        Left = zeros(nVox, 1);

        % Fill in the location of the voxels
        Right(RightVox) = 1;
        Left(LeftVox) = 1;
        
        % Make the mask match the shape of the EPIData
        Right = reshape(Right, SPMTHeader.dim);
        Left = reshape(Left, SPMTHeader.dim);
        
        % Save as nifti
        Ori = {'Right', 'Left'};
        for iORI = 1:length(Ori)
            template = spm_vol([ROIFolder, '/V1.nii']);
            newVol = template;
            newVol = rmfield(newVol,'private');
            newVol.fname = [ROIFolder, '/', Ori{iORI}, ROIs{iROI}, '_500.nii'];
            newVol.dim = size(Right);
            
            if iORI == 1
                spm_write_vol(newVol, Right);
            elseif iORI == 2
                spm_write_vol(newVol, Left);
            end
            
        end
    end
end
