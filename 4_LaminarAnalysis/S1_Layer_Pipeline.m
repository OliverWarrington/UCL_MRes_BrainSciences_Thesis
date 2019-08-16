% Takes the cortical boundaries from freesurfer and defines the cortical
% layers.

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)
    disp(['Processing ', Subjects{SID}]);

    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    configuration.i_Boundaries = 'Coregistrations/Boundaries_RBR.mat';
    configuration.o_ObjWhite = 'Freesurfer/surf/?h.white.reg.obj';
    configuration.o_ObjPial = 'Freesurfer/surf/?h.pial.reg.obj';

    configuration.i_ReferenceVolume = 'Functional/Cropped/cr_meanfunctional.nii';
    configuration.i_ObjWhite = 'Freesurfer/surf/?h.white.reg.obj';
    configuration.i_ObjPial = 'Freesurfer/surf/?h.pial.reg.obj';
    configuration.o_SdfWhite = 'LevelSets/?h.white.sdf.nii';
    configuration.o_SdfPial  = 'LevelSets/?h.pial.sdf.nii';
    configuration.o_White  = 'LevelSets/brain.white.sdf.nii';
    configuration.o_Pial  = 'LevelSets/brain.pial.sdf.nii';

    configuration.i_b0  = 'LevelSets/brain.pial.sdf.nii';
    configuration.i_b1  = 'LevelSets/brain.white.sdf.nii';
    configuration.o_LaplacePotential = 'LevelSets/LaplacePotential.nii';

    configuration.o_Gradient = 'LevelSets/Gradient.nii';
    configuration.o_Curvature = 'LevelSets/Curvature.nii';

    configuration.i_White  = 'LevelSets/brain.white.sdf.nii';
    configuration.i_Pial  = 'LevelSets/brain.pial.sdf.nii';

    configuration.i_Levels = 0:1/3:1;
    configuration.o_Layering = 'LevelSets/Layering.nii';
    configuration.o_LevelSet = 'LevelSets/LevelSet.nii';

    tvm_layerPipeline(configuration);
    clear configuration
end
