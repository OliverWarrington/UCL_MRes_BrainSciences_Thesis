% Backup old Freesurfer files before replacing them with new corrected
% files

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)
    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    configuration.i_Files = {'Freesurfer/surf/lh.white', 'Freesurfer/surf/lh.pial', 'Freesurfer/surf/lh.orig',...
                            'Freesurfer/surf/rh.white', 'Freesurfer/surf/rh.pial', 'Freesurfer/surf/rh.orig'};
    configuration.p_Suffix = '_backup';

    tvm_backupFiles(configuration);
    tvm_restoreBackupFiles(configuration);

    clear configuration;
end
