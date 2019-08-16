% Generate laminar specific timecourses.

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

runs = {'Run1' 'Run2' 'Run3' 'Run4' 'Localiser'};
ROIs = {'V1_45deg', 'V1_135deg', 'V2_45deg',  'V2_135deg'};

for SID = 1:length(Subjects)
    disp(['Processing ', Subjects{SID}]);

    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    
    for curRun = 1:length(runs)
        
        disp(['Currently on', runs{curRun}]);

        configuration.i_FunctionalFiles = ['Functional/Cropped/cr_', runs{curRun}, '.nii'];
        
        for curROI = 1:length(ROIs)
            
            disp(['Analysing ', ROIs{curROI}]);
            
            configuration.i_DesignMatrix{1} = ['DesignMatrices/', ROIs{curROI}, '.mat'];
            
            configuration.o_TimeCourse{1} = ['TimeCourses/', runs{curRun}, '/', ROIs{curROI}, '.mat'];
            
            tvm_designMatrixToTimeCourse(configuration);
        
        end
    end
end
