% Extract laminar timecourses for each ROI

clear all; close all;

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

% ROIs to process
ROIs = {'V1_45deg' 'V1_135deg' ...
    'V2_45deg' 'V2_135deg'};

for SID = 1:length(subjects)
    disp(['Processing ', subjects{SID}]);
    
    configuration = [];
    configuration.i_SubjectDirectory = fullfile(PrDir,'Subjects', Subjects{SID});
    
    % find functional runs
    EPIs = dir(fullfile(PrDir,'Subjects',subjects{SID},'FunctionalFiles','r*.nii'));
    
    for curRun = 1:length(EPIs)
        disp(['Currently on run ', EPIs(curRun).name]);
        configuration.i_FunctionalFiles = ['FunctionalFiles/', EPIs(curRun).name];
        for curROI = 1:length(ROIs)
            disp(['Analysing ', ROIs{curROI}]);
            configuration.i_DesignMatrix{1} = ['DesignMatrices/', ROIs{curROI}, '.mat'];
            configuration.o_TimeCourse{1} = ['TimeCourses/', 'zScored_', ROIs{curROI}, '_', EPIs(curRun).name(1:end-4), '.mat'];
            tvm_designMatrixToTimeCourse(configuration);
        end
    end
    
    clear configuration;
end
