% Create separate masks for voxels that prefer clockwise and
% counter-clockwise orientations
clear all; close all;

PrDir = '/Users/OliverW/Desktop/Project/Subjects';
Subjects = {'sub-03'};

nVoxels = 500; % Number of voxels per orientation to include
Tthresh = 2;
ROIs = {'V1.nii', 'V2.nii'};

for SID = 1:length(Subjects)
    
    SubDir = fullfile(PrDir, Subjects{SID});
    ROIFolder = fullfile(SubDir, 'Masks');
    
    for iROI = 1:length(ROIs)
        
        disp(['Currently on ', ROIs{iROI}]);
        
        % Load masks
        anatomicalROIfile = fullfile(ROIFolder, ROIs{iROI});
        anatomicalROIvol = spm_vol(anatomicalROIfile);
        anatomicalROIdata = spm_read_vols(anatomicalROIvol);
        anatomicalROIdata = reshape(anatomicalROIdata, numel(anatomicalROIdata), 1);
        
        % Load stim > baseline T map
        activationTfile = fullfile(SubDir, 'FirstLevel', 'Localiser', 'spmT_0001.nii');
        activationTvol = spm_vol(activationTfile);
        activationTdata = spm_read_vols(activationTvol);
        activationTdata = reshape(activationTdata, numel(activationTdata), 1);
        
        % Load 45deg > 135deg T map
        orientTfile = fullfile(SubDir, 'FirstLevel', 'Localiser', 'spmT_0002.nii');
        orientTvol = spm_vol(orientTfile);
        orientTdata = spm_read_vols(orientTvol);
        orientTdata = reshape(orientTdata, numel(orientTdata), 1);
        
        % select active voxels
        activeVox = anatomicalROIdata > 0.5 & activationTdata > Tthresh;
        
        fprintf('Found %d active voxels\n', sum(activeVox));

        % select 45 prefering voxels
        orientPref = -Inf * ones(size(anatomicalROIdata));
        orientPref(activeVox) = orientTdata(activeVox);
        [val, ind] = sort(orientPref, 'descend');
        orient45Vox = ind(1:nVoxels);
        
        % select 135 prefering voxels
        orientPref = -Inf * ones(size(anatomicalROIdata));
        orientPref(activeVox) = -1*orientTdata(activeVox);
        [val, ind] = sort(orientPref, 'descend');
        orient135Vox = ind(1:nVoxels);
        
        % create masks: one for 45 deg voxels, one for 135 deg voxels, and
        % the combination of the two.
        orient45Mask = zeros(size(anatomicalROIdata));
        orient45Mask(orient45Vox) = 1;
        orient135Mask = zeros(size(anatomicalROIdata));
        orient135Mask(orient135Vox) = 1;
        combinedMask = zeros(size(anatomicalROIdata));
        combinedMask([orient45Vox ; orient135Vox]) = 1;
        
        % save these masks as niftis
        newVol = anatomicalROIvol;
        newVol.fname = fullfile(ROIFolder, [ROIs{iROI}(1:end-4) '_45deg.nii']);
        newImg = reshape(orient45Mask, newVol.dim);
        spm_write_vol(newVol,newImg);
        
        newVol = anatomicalROIvol;
        newVol.fname = fullfile(ROIFolder, [ROIs{iROI}(1:end-4) '_135deg.nii']);
        newImg = reshape(orient135Mask, newVol.dim);
        spm_write_vol(newVol,newImg);
                
        newVol = anatomicalROIvol;
        newVol.fname = fullfile(ROIFolder, [ROIs{iROI}(1:end-4) '_bothOrients.nii']);
        newImg = reshape(combinedMask, newVol.dim);
        spm_write_vol(newVol,newImg);
    end
end