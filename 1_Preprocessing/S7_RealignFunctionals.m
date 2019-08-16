% Realign scans 
clear all

Subjects = {'sub-07' 'sub-08' 'sub-09'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

disp('Realigning Functionals')

parfor SID = 1:length(Subjects)
    
    fprintf('\nSubject %d out of %d\n',SID,length(Subjects))

    % Setup paramaters for SPM Realign - Estimate and Reslice
    matlabbatch = [];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

    % find EPI folders
    EPIFolders = dir(fullfile(PrDir, Subjects{SID}, 'Niftis', 'nc*'));

    for iFolder = 1:length(EPIFolders)
            
        % input EPIs
        EPIFiles = spm_select('FPList',fullfile(EPIFolders(iFolder).folder, EPIFolders(iFolder).name),'^f.*\.nii$');
            
        EPIFiles = cellstr([EPIFiles repmat(',1',size(EPIFiles,1),1)]);
            
        matlabbatch{1}.spm.spatial.realign.estwrite.data{iFolder} = EPIFiles;
            
    end
        
    % now run the job!
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);
    
    % Move realigned files to new folder
    for iFolder = 1:length(EPIFolders)
        
        cd(fullfile(PrDir, Subjects{SID}, 'Niftis', EPIFolders(iFolder).name));
        mkdir('Realigned')
        movefile 'r*' Realigned
        
    end
%     clear matlabbatch 
end
