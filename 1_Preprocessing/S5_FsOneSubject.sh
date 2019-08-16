SID="sub-07"
export SUBJECTS_DIR="/Users/OliverW/Desktop/Project/Subjects/$SID"
cd $SUBJECTS_DIR
T1="${SUBJECTS_DIR}/Niftis/anatomical/T1_fast_restore.nii"
#T2="${SUBJECTS_DIR}/Functional/mean*"

# Standard call using 3 cores
#recon-all -all -s ${SID}_Freesurfer -i $T1 -parallel -openmp 3
#recon-all -autorecon1 -s Freesurfer -i $T1 -parallel -openmp 4

# Uncomment for checking skull stripping
#recon-all -autorecon1 -multistrip -s ${SID}_FsSkull -i $T1 -parallel -openmp 4

# Uncomment for -gcut option
#recon-all -skullstrip -clean-bm -gcut -s ${SID}_FsSkull -parallel -openmp 3

# Uncomment to continue after autorecon1 
#recon-all -autorecon2 -autorecon3 -s Freesurfer -parallel -openmp 4

# Uncomment for regenerating pial surface after edits
recon-all -autorecon-pial -s Freesurfer -parallel -openmp 4

# Uncomment for recon-all using T2 weighted volume for better pial surfaces
#recon-all -all -i $T1 -T2 $T2 -T2pial -s T2_Freesurfer -parallel -openmp 4
