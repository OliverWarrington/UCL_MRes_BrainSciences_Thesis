% Create weighted z scored functional files

clear all; close all;

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/';

for SID = 1:length(subjects)
    disp(['Processing ', subjects{SID}]);
    
    subjectDir = fullfile(PrDir, 'Subjects', subjects{SID});
    
    % find main exp functional runs
    EPIs = dir(fullfile(subjectDir,'Niftis','Realigned','rRun*.nii'));
    
    for iRun = 1:length(EPIs)
        disp(['Analysing run ', num2str(iRun)]);
        
        % Load 45deg > 135deg T map
        orientTfile = fullfile(subjectDir, 'FirstLevel', 'Localiser', 'spmT_0002.nii');
        orientTvol = spm_vol(orientTfile);
        orientTdata = spm_read_vols(orientTvol);
        orientTdata = reshape(orientTdata, numel(orientTdata), 1);
        % Remove sign from tmap
        orientTdata = abs(orientTdata);
        
        % Load time course and tmap data
        EPIvol = spm_vol(fullfile(EPIs(iRun).folder, EPIs(iRun).name));
        EPIdata = spm_read_vols(EPIvol);
        EPIdata = reshape(EPIdata, numel(orientTdata), size(EPIdata,4));
        
        % Zscore each voxel
        EPIdata = (zscore(EPIdata'))';
        
        % Multiple at each time point to create weighted time course
        EPIdata = EPIdata .* repmat(orientTdata, 1, size(EPIdata,2));
        
        % reshape back into 4D
        EPIdata = reshape(EPIdata, [EPIvol(1).dim size(EPIdata,2)]);
        
        % Save out weighted functional files
        newVol = EPIvol;
        for iVol = 1:length(newVol)
            newVol(iVol).fname = fullfile(subjectDir, 'FunctionalFiles', EPIs(iRun).name);
            spm_write_vol(newVol(iVol), EPIdata(:,:,:,iVol));
        end
    end
end
