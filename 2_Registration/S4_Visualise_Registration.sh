#!/bin/bash

# Visualise results of registering surface to functional data

SID='sub-03' # Subject to process

export SUBJECTS_DIR=~/Desktop/Project/Subjects/$SID/
referenceVolume=${SUBJECTS_DIR}Functional/Cropped/cr_meanfunctional.nii
registerDat=${SUBJECTS_DIR}Coregistrations/register.dat

#tkregister2 --s 'Freesurfer' --mov $referenceVolume --reg $registerDat --surf white

#tkregister2 --s 'Freesurfer' --mov $referenceVolume --reg $registerDat

tkregister2 --targ ${SUBJECTS_DIR}/Freesurfer/mri/brain.nii --mov $referenceVolume --reg $registerDat --surf pial
