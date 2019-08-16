% Align the Freesurfer surface to the functional data using Boundary Based Registration.
% This generates Boundaries_BBR.mat and CoregistrationMatrix_BBR.mat
clear all

Subjects = {'sub-07'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)

    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    configuration.i_FreeSurferFolder = 'Freesurfer/';
    configuration.i_ReferenceVolume = 'Functional/Cropped/cr_meanfunctional.nii';
    configuration.i_CoregistrationMatrix = 'Coregistrations/CoregistrationMatrix.mat';
    configuration.i_Boundaries = 'Coregistrations/Boundaries.mat';
    configuration.o_CoregistrationMatrix = 'Coregistrations/CoregistrationMatrix_BBR.mat';
    configuration.o_Boundaries = 'Coregistrations/Boundaries_BBR.mat';


    realignmentConfiguration = [];
    realignmentConfiguration.ReverseContrast       = true;
    realignmentConfiguration.ContrastMethod        = 'gradient';
    realignmentConfiguration.OptimisationMethod    = 'centred';
    realignmentConfiguration.Mode                  = 'rt'; % rt default
    realignmentConfiguration.Display               = 'on';


    tvm_boundaryBasedRegistration(configuration, realignmentConfiguration);

    clear configuration; clear realignmentConfiguration;
end
