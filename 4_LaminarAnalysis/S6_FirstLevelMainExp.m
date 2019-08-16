% 1st Level analysis for Localiser
clear all; close all;

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/';

TR = (48*74.65)/1000;

for SID = 1:length(subjects)
    
    matlabbatch = [];
    
    resultsDir = fullfile(PrDir, 'Subjects', subjects{SID}, 'FirstLevel', 'MainExp');
    realignedFolder = dir(fullfile(PrDir, 'Subjects', subjects{SID}, 'Niftis', 'Realigned'));
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(resultsDir);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 32;  %16 
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 16; %8
    
    % Input realigned EPIs
    EPIFiles = spm_select('FPList',fullfile(realignedFolder(1).folder, realignedFolder(1).name),'^rRun');
    EPIFiles = cellstr(EPIFiles);
    for iRun = 1:length(EPIFiles)
        runNr = str2num(EPIFiles{iRun}(end-4));
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).scans = EPIFiles(iRun);
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).multi = cellstr(fullfile(PrDir, 'Subjects', subjects{SID}, 'TaskRegressors', sprintf('cond_run%d.mat', runNr)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).multi_reg = cellstr(fullfile(PrDir, 'Subjects', subjects{SID}, 'Niftis', 'Realigned', sprintf('rp_extended_Run_%d.mat', runNr)));
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).hpf = 128;
    end
    
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.5;
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(resultsDir, 'SPM.mat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(resultsDir, 'SPM.mat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Stim vs baseline';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'both';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Omit vs baseline';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [0 0 0 0 1 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'both';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Stim 45deg';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'both';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Stim 135deg';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = [0 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'both';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Omit 45deg';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.convec = [0 0 0 0 1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'both';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Omit 135deg';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.convec = [0 0 0 0 0 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'both';
    matlabbatch{3}.spm.stats.con.delete = 1;
    
    % now run the job!
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);

end
