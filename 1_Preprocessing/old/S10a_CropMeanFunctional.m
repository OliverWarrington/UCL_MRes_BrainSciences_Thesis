%% Crop 4D Niftis
clear all;
Subjects = 'sub-07';
PrDir = '/Users/OliverW/Desktop/Project/Subjects/'; 

% Nifti files to process
niftis = {'meanfunctional'};

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
    
    niipath = fullfile(niftiFolder, [niftis{curNifti} '.nii']);
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