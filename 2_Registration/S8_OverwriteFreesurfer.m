% Overwrite freesurfer boundaries with results of recursive boundary
% registration

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)
    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    configuration.i_ReferenceVolume = 'Functional/Cropped/cr_meanfunctional.nii';
    configuration.i_Boundaries = 'Coregistrations/Boundaries_RBR.mat';
    configuration.i_CoregistrationMatrix = 'Coregistrations/CoregistrationMatrix_BBR.mat';
    configuration.i_FreeSurferFolder = 'Freesurfer/';
    configuration.o_WhiteMatterSurface = 'Freesurfer/surf/?h.white';
    configuration.o_PialSurface = 'Freesurfer/surf/?h.pial';

    tvm_boundariesToFreesurferFile(configuration);
    clear configuration;
end
