% Localiser Laminar Analysis
% - Stim vs Baseline
% - Right vs Left preferring 
% Convert paramater estimates into %signal change and then average over
% layers to produce a cortical depth profile
clear all;

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

ROIs = {'V1_45deg'};

for SID = 1:length(Subjects)
    
    SubDir = fullfile(PrDir, Subjects{SID});
    
    for iROI = 1:length(ROIs)
        
        load(fullfile(SubDir, 'TimeCourses', 'Localiser', ROIs{iROI}));
        
        FirstLevelDir = dir(fullfile(SubDir, 'FirstLevel', 'Localiser', 'beta*'));
        
        stimHeader = spm_vol([FirstLevelDir(1).folder, '/', FirstLevelDir(1).name]);
        stimData = spm_read_vols(stimHeader);
        baseHeader = spm_vol([FirstLevelDir(2).folder, '/', FirstLevelDir(2).name]);
        baseData = spm_read_vols(baseHeader);
        
        meanSignal = mean2(timeCourses{:});
    end
    
end