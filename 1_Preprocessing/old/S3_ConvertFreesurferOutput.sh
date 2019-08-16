#!/bin/bash -e

################################################
# Convert Freesurfer boundaries to Ascii.
# (Used in tvm functions but Matlab and Freesurfer
#  can be awkward)
################################################

Subjects=('S01' 'S04' 'S05')
echo "Converting Freesurfer boundaries to Ascii and brain.mgz to brain.nii"
for SID in ${Subjects[@]}; do

    Fs_dir=/Users/OliverW/Desktop/Project/Test_Subjects/$SID/Freesurfer
    
    cd ${Fs_dir}"/mri/"
    for scan in 'ribbon' 'orig' 'ribbon' 'nu' 'brain'; do

        mri_convert --out_orientation RAS ./$scan.mgz ./$scan.nii
        
    done
    
    cd ${Fs_dir}"/mri/"
    for h in "r l"; do
        
        mris_convert "${h}h.white" "${h}h.white.asc"
        mris_convert "${h}h.pial" "${h}h.pial.asc"
        
    done
    
done
