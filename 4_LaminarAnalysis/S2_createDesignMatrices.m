% Generate laminar design matrices for each ROI

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

ROIs = {'V1_45deg', 'V1_135deg', 'V2_45deg',  'V2_135deg'};

for SID = 1:length(Subjects)
    
    disp(['Processing ', Subjects{SID}]);
    
    configuration = []; 
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    
    for curROI = 1:length(ROIs)
        
        configuration.i_ROI{curROI} = ['Masks/', ROIs{curROI}, '.nii'];
        configuration.o_DesignMatrix{curROI} = ['DesignMatrices/', ROIs{curROI}, '.mat'];
        
    end
    
    configuration.i_Layers = 'LevelSets/Layering.nii';
    
    tvm_roiToDesignMatrix(configuration);
    
    clear configuration;
    
end
