% Create 4D Niftis
clear all;

Subjects = 'sub-07';
PrDir = '/Users/OliverW/Desktop/Project/Subjects/'; 

% Convert each run to a 4D nifti to crop all images easier
EPIFolder = dir(fullfile(PrDir, Subjects, 'Niftis', 'nc*'));

for iFolder = 1:length(EPIFolder)
    
    matlabbatch = [];
    matlabbatch{1}.spm.util.cat.name = sprintf('4D_%s.nii', EPIFolder(iFolder).name);
    matlabbatch{1}.spm.util.cat.dtype = 4;
    matlabbatch{1}.spm.util.cat.RT = 3.5832;
    
    % Input realigned EPIs
    EPIFiles = spm_select('FPList', fullfile(EPIFolder(iFolder).folder, EPIFolder(iFolder).name, 'Realigned'), '^rf');
    EPIFiles = cellstr([EPIFiles repmat(',1',size(EPIFiles,1),1)]);
    
    matlabbatch{1}.spm.util.cat.vols = EPIFiles;
    
    % now run the job!
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);
    
    
end
