% 1st Level analysis for Localiser
clear all

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

for SID = 1:length(Subjects)
    
    matlabbatch = [];
    
    resultsDir = fullfile(PrDir, Subjects{SID}, 'FirstLevel/Localiser');
    funcFolder = dir(fullfile(PrDir, Subjects{SID}, 'Functional', 'Cropped'));
    realignedFolder = dir(fullfile(PrDir, Subjects{SID}, 'Niftis', '*Loc*', 'Realigned'));
    
    % Input realigned and cropped 4D EPIs
%     EPIFiles = spm_select('ExtList',fullfile(funcFolder(1).folder, funcFolder(1).name),'^cr_L', [1:267]);
    EPIFiles = spm_select('expand', fullfile(funcFolder(1).folder, funcFolder(1).name, 'cr_Localiser.nii'));
    %EPIFiles = cellstr([EPIFiles repmat(',1',size(EPIFiles,1),1)]);
    EPIFiles = cellstr(EPIFiles);
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = EPIFiles;
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(resultsDir);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 3.5832;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = cellstr(fullfile(resultsDir, 'cond_localiser.mat'));
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(spm_select('FPList', fullfile(realignedFolder(1).folder, realignedFolder(1).name),'^rp_e'));
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(resultsDir, 'SPM.mat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(resultsDir, 'SPM.mat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Total Activity';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1 1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Right > Left';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
    
    % now run the job!
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);

end