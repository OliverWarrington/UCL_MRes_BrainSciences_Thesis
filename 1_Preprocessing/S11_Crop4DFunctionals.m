% Crop functionals to only include the occipital lobe - to avoid
% distortions in other parts affecting registrations unnecessarily. Note x,
% y and z indices to include will change on a per subject / session basis!
% Edit these manually.
clear all;

Subjects = 'sub-03';
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

% Nifti files to process
niftis = {'Localiser', 'Run1' 'Run2' 'Run3' 'Run4' 'meanfunctional'};

% Indices to crop around
xind = 1:240;
zind = 4:48;
yind = 1:67;

niftiFolder = fullfile(PrDir, Subjects, 'Functional');

for curNifti = 1:length(niftis)

    croppedFolder = fullfile(niftiFolder, 'Cropped');
    
    if ~exist(croppedFolder, 'dir')
        mkdir(croppedFolder)
    end
    
    if isequal(niftis{curNifti}, 'meanfunctional')
        niipath = fullfile(niftiFolder, [niftis{curNifti} '.nii']);
    else
        niipath = fullfile(niftiFolder, ['4D_' niftis{curNifti} '.nii']);
    end
    vols = spm_vol(niipath);
    
    for iVol = 1:length(vols)
        oldVol = vols(iVol);
        img = spm_read_vols(vols(iVol));
        
        img = img(xind,yind,zind);
        
        newVol = oldVol;
        newVol = rmfield(newVol,'private');
        newVol.descrip = [newVol.descrip ' - cropped'];
        newVol.fname = [croppedFolder, '/', 'cr_', niftis{curNifti}, '.nii'];
        newVol.dim = size(img);
        spm_write_vol(newVol,img);
    end
    
end

% %% Covert back to 3D Niftis - Do we need to do this? - Maybe not, check SPM handles 4D
% 
% for iFolder = 1:length(EPIFolder)
%     
%     fprintf('%s \n', EPIFolder(iFolder).name);
%     
%     matlabbatch = [];
%     matlabbatch{1}.spm.util.split.outdir = {fullfile(EPIFolder(iFolder).folder, EPIFolder(iFolder).name, 'Realigned', 'Cropped')};
%     
%     % Input realigned EPIs
%     EPIFiles = spm_select('FPList', fullfile(EPIFolder(iFolder).folder, EPIFolder(iFolder).name, 'Realigned'), '^4D');
%     EPIFiles = cellstr([EPIFiles repmat(',1',size(EPIFiles,1),1)]);
%     
%     matlabbatch{1}.spm.util.split.vol = EPIFiles;
%     
%     % now run the job!
%     spm_jobman('initcfg');
%     spm_jobman('run', matlabbatch);
%     
% end