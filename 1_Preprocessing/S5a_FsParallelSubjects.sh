#!/bin/bash -e

################################################
# Set up Freesurfer environment
################################################

export SUBJECTS_DIR="/Users/OliverW/Desktop/Project/Subjects/"
cd $SUBJECTS_DIR

Subjects=("sub-04" "sub-05" "sub-06" "sub-07" "sub-08" "sub-09")

echo "Running Freesurfer parallel for "${Subjects[@]}

################################################
# Create list of duplicated MP2RAGE for parallel
################################################

mkdir ${SUBJECTS_DIR}Temp_Niftis/
for i in ${Subjects[@]};
do

    cd $SUBJECTS_DIR/$i/Niftis/Anatomical/

    cp 'T1.nii' $SUBJECTS_DIR/Temp_Niftis/$i.nii

done

################################################
# Run Freesurfer in parallel (Max jobs = 4).
################################################

cd ${SUBJECTS_DIR}Temp_Niftis/
ls *.nii | sed 's/.nii//' | parallel --jobs 3 recon-all -autorecon1 -s {}_Freesurfer -i {}.nii

# Move Subject Freesurfer folders to their individual folder.
for i in ${Subjects[@]};
do

    mv "${SUBJECTS_DIR}${i}_Freesurfer" "${SUBJECTS_DIR}${i}/Freesurfer"

done

# Cleanup temporary files.
rm -r ${SUBJECTS_DIR}Temp_Niftis/
