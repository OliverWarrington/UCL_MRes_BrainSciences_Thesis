% Run FSL fast to remove bias field from T1.
clear all; close all;

Subjects = {'sub-07'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

disp('Running FSL fast to remove bias field from T1.')
for SID = 1:length(Subjects)

        % find T1 scan
        T1Folder = dir(fullfile(PrDir, Subjects{SID}, 'Niftis', 'Anatomical'));
        T1Image = dir(fullfile(T1Folder(1).folder, 'T1.nii'));
        T1File = fullfile(T1Image.folder, T1Image.name);
        output = fullfile(T1Image.folder,'T1_fast');
        
        fastCommand = sprintf('fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -B -b -o %s %s', output, T1File);
        unix(fastCommand);
        
        gunzip([output, '_restore.nii.gz'], T1Folder(1).folder);
end
