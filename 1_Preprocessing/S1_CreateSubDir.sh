#!/bin/bash -e

# Create subjects directory
cd '/Users/OliverW/Desktop/Project/Subjects'

Subjects=('sub-11' 'sub-12' 'sub-13' 'sub-14')

for SID in ${Subjects[@]}; do

mkdir './'$SID
mkdir './'$SID'/beh'
mkdir './'$SID'/Dicoms'
mkdir './'$SID'/Niftis'
mkdir './'$SID'/Functional'
mkdir './'$SID'/FirstLevel'
mkdir './'$SID'/Coregistrations'
mkdir './'$SID'/Masks'
mkdir './'$SID'/LevelSets'
mkdir './'$SID'/DesignMatrices'
mkdir './'$SID'/Timecourses'

done
