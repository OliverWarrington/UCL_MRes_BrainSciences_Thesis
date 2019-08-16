% Delete first 4 scans from each run

Subjects = {'sub-08' 'sub-09'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

for SID = 1:length(Subjects)
    
    NiiDir = dir(fullfile(PrDir, Subjects{SID}, 'Niftis', 'nc*'));
    
    for iFolder = 1:length(NiiDir)
        
       for dummy = 1:4
           dummyFiles = sprintf('*%05g-1.nii', dummy);
           DummyRuns = dir(fullfile(NiiDir(iFolder).folder, NiiDir(iFolder).name, dummyFiles));
           delete(fullfile(DummyRuns.folder,DummyRuns.name))
       end
    end
end