% Convert V1 & V2 labels to volume.nii

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)

    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    configuration.i_LabelFiles = {'Freesurfer/label/lh.V1_exvivo.label', 'Freesurfer/label/lh.V2_exvivo.label' ...
        'Freesurfer/label/rh.V1_exvivo.label', 'Freesurfer/label/rh.V2_exvivo.label'};
    configuration.i_Hemisphere = {'lh', 'lh', 'rh', 'rh'};
    configuration.i_CoregistrationMatrix = 'Coregistrations/Cropped/CoregistrationMatrix_CR.mat';
    configuration.i_ReferenceVolume = 'Functional/Cropped/meanfunctional.nii';
    configuration.i_RegisterDat = 'Coregistrations/register.dat';
    configuration.i_FreeSurfer = 'Freesurfer';
    configuration.o_VolumeFile = {'Masks/lh.V1_new.nii', 'Masks/lh.V2_new.nii' ...
        'Masks/rh.V1_new.nii', 'Masks/rh.V2_new.nii'};
    
    
    tvm_labelToVolume(configuration)
    
    clear configuration;
    
end
