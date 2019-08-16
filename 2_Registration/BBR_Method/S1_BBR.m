

Subjects = {'P1' 'S03'};
Pr_dir = '/Users/OliverW/Desktop/Project/CoregTest/';
for SID =1:length(Subjects)
    
    configuration = [];
    configuration.i_SubjectDirectory = [Pr_dir, Subjects{SID}, '/'];
    configuration.i_RegistrationVolume = 'meanfunctional.nii';
    configuration.i_FreeSurferFolder = 'Freesurfer/';
    configuration.i_SpmInitialisation = false; % Mail archives said not needed anymore (mri_coreg is used in bbregister instead)
    configuration.i_FslInitialisation = false;
    configuration.i_Contrast = 'T2';
    configuration.i_DegreesOfFreedom = 6;
%     configuration.i_InititialMatrix = 'Coregistrations/init.dat';

    configuration.o_Boundaries = 'Coregistrations/BBR/Boundaries_BBR.mat';
    configuration.o_RegisterDat = 'Coregistrations/BBR/register.dat';
    configuration.o_CoregistrationMatrix = 'Coregistrations/BBR/CoregistrationMatrix_BBR.mat';

    tvm_useBbregister(configuration);
    
    clear configuration
    
end

