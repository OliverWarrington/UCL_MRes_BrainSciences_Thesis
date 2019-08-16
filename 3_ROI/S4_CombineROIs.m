% Combine rh and lh masks into a single mask for both V1 and V2
clear all

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';
ROIs = {'V1', 'V2'};

for SID = 1:length(Subjects)
    for iROI = 1:length(ROIs)

        matlabbatch{1}.spm.util.imcalc.input = {
                                                [PrDir, '/', Subjects{SID}, '/Masks/lh.', ROIs{iROI}, '.nii,1']
                                                [PrDir, '/', Subjects{SID}, '/Masks/rh.', ROIs{iROI}, '.nii,1']
                                                };

        matlabbatch{1}.spm.util.imcalc.output = [ROIs{iROI}, '.nii'];
        matlabbatch{1}.spm.util.imcalc.outdir = {[PrDir, '/', Subjects{SID}, '/Masks/']};
        matlabbatch{1}.spm.util.imcalc.expression = 'i1+i2';
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 1;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

        spm_jobman('initcfg');
        spm_jobman('run', matlabbatch);

    end
end