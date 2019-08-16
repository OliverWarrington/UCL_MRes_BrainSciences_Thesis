% Align the Freesurfer surface to the functional data.
% This generates Boundaries.mat and CoregistrationMatrix.mat.
clear all

Subjects = {'sub-07'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)

    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    configuration.i_FreeSurferFolder = 'Freesurfer/';
    configuration.i_ReferenceVolume = 'Functional/Cropped/cr_meanfunctional.nii';
    configuration.o_CoregistrationMatrix = 'Coregistrations/CoregistrationMatrix.mat';
    configuration.o_Boundaries = 'Coregistrations/Boundaries.mat';


    realignmentConfiguration = [];
    realignmentConfiguration.sep = [2, 1];
    realignmentConfiguration.cost_fun = 'nmi';
    realignmentConfiguration.tol = [0.02 0.02 0.02 0.001 0.001 0.001];
    realignmentConfiguration.fwhm = [7 7];
    realignmentConfiguration.graphics = 0;
    realignmentConfiguration.params = [0 0 0 0 0 0]; 

    tvm_registerVolumes(configuration, realignmentConfiguration);

    clear configuration; clear realignmentConfiguration;
end
