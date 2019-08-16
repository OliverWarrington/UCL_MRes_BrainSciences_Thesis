% Create Freesurfer registration .dat file from coregistration matrix
clear all

Subjects = {'sub-07'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

for SID = 1:length(Subjects)
    
    configuration = [];
    configuration.i_SubjectDirectory = [PrDir, Subjects{SID}, '/'];
    configuration.i_FreeSurferFolder = 'Freesurfer';
    configuration.i_RegistrationVolume = 'Functional/Cropped/cr_meanfunctional.nii';
    configuration.i_CoregistrationMatrix = 'Coregistrations/CoregistrationMatrix_BBR.mat';
    configuration.o_RegisterDat = 'Coregistrations/register.dat';
    
    petkok_createRegisterDat(configuration);
    clear configuration;
end
