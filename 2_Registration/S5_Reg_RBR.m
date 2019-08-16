% Align the Freesurfer surface to the functional data using Recursive Boundary Based Registration.
% This generates Boundaries_RBR.mat

Subjects = {'sub-07'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)

    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    configuration.i_ReferenceVolume = 'Functional/Cropped/cr_meanfunctional.nii';
    configuration.i_CoregistrationMatrix = 'Coregistrations/CoregistrationMatrix_BBR.mat';
    configuration.i_Boundaries = 'Coregistrations/Boundaries_BBR.mat';
    configuration.o_Boundaries = 'Coregistrations/Boundaries_RBR.mat';


    realignmentConfiguration = [];
    realignmentConfiguration.ReverseContrast       = true;
    realignmentConfiguration.ContrastMethod        = 'gradient';
    realignmentConfiguration.OptimisationMethod    = 'GreveFischl';
    realignmentConfiguration.Mode                  = 'rsxt';
    realignmentConfiguration.Display               = 'on';
    realignmentConfiguration.NumberOfIterations    = 6;
    realignmentConfiguration.Accuracy              = 30;
    realignmentConfiguration.DynamicAccuracy       = true;
    realignmentConfiguration.MultipleLoops         = true;
    realignmentConfiguration.qsub                  = false;


    tvm_recursiveBoundaryRegistration(configuration, realignmentConfiguration);

    clear configuration; clear realignmentConfiguration;
end
