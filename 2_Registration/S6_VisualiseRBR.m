% Visualise results of recursive boundary registration and compare to BBR.

Subjects = {'sub-07'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)
    configuration = [];
    subjectDirectory = [PrDir, Subjects{SID}, '/'];
    functional = spm_vol([subjectDirectory, 'Functional/Cropped/cr_meanfunctional.nii';]);
    configuration.i_Volume = spm_read_vols(functional);
    configuration.i_Axis = 'x'; 

    
    for curSlice = 100:5:180   % 100:5:150 for pull down % Different axis have different slice ranges
        configuration.i_Slice = curSlice;

        figure;
        subplot(1,3,1)
%         subplot(2,1,1)
%         subplot(1, 2, 1)
        load([subjectDirectory, 'Coregistrations/Boundaries.mat'], 'wSurface', 'pSurface', 'faceData');
        configuration.i_Vertices{1} = wSurface;
        configuration.i_Vertices{2} = pSurface;
        configuration.i_Faces{1} = faceData;
        configuration.i_Faces{2} = faceData;

        tvm_showObjectContourOnSlice(configuration);
        
        subplot(1,3,2)
%         subplot(1,2,2)
        load([subjectDirectory, 'Coregistrations/Boundaries_BBR.mat'], 'wSurface', 'pSurface', 'faceData');
        configuration.i_Vertices{1} = wSurface;
        configuration.i_Vertices{2} = pSurface;
        configuration.i_Faces{1} = faceData;
        configuration.i_Faces{2} = faceData;

        tvm_showObjectContourOnSlice(configuration);
        

        subplot(1,3,3)
%         subplot(2,1,2)
%         subplot(1, 2, 2)
        load([subjectDirectory, 'Coregistrations/Boundaries_RBR.mat'], 'wSurface', 'pSurface', 'faceData');
        configuration.i_Vertices{1} = wSurface;
        configuration.i_Vertices{2} = pSurface;
        configuration.i_Faces{1} = faceData;
        configuration.i_Faces{2} = faceData;

        tvm_showObjectContourOnSlice(configuration);
    end
        clear configuration;
end
