#!/bin/bash

Subjects=('sub-07') 
PrDir="/Users/OliverW/Desktop/Project/Subjects"

for SID in ${Subjects[@]}; do

	cd ${PrDir}/${SID}/Niftis/
	#Files=$(ls -l | grep -v ^l | wc -l)
	Files=$(ls)
	count=0

	for file in ${Files[@]}; do

		if [ $count == 0 ]; then
			((count++))
			continue
		elif [ $file == *Loc* ]; then
			cd ${PrDir}/${SID}/Niftis/$file/Realigned
			mv 4D* ${PrDir}/${SID}/Functional/4D_Localiser.nii
			cp mean* ${PrDir}/${SID}/Functional/meanfunctional.nii
		else
			cd ${PrDir}/${SID}/Niftis/$file/Realigned
			mv 4D* ${PrDir}/${SID}/Functional/4D_Run${count}.nii
			((count++))
		fi

	done

done
