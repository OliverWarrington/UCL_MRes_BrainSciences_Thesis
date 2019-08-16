% Convert Dicoms to Nifti using SPM

Subjects = {'sub-08' 'sub-09'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

parfor SID = 1:length(Subjects) %parfor
    
    DicomDir = fullfile(PrDir, Subjects{SID}, 'Dicoms/');
    cd(DicomDir)
    OutDir = fullfile(PrDir, Subjects{SID}, 'Niftis/');

    
    matlabbatch = [];
    matlabbatch{1}.spm.util.import.dicom.data = cellstr(spm_select('List' , DicomDir, 'MR*'));
    matlabbatch{1}.spm.util.import.dicom.outdir{1} = OutDir;
    matlabbatch{1}.spm.util.import.dicom.root = 'series';
    matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
    matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
    matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
    matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
    
    
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);
    
%     clear matlabbatch DicomDir OutDir

end
