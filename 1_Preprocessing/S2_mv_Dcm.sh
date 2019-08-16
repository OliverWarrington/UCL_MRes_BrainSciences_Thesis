#!/bin/bash -e

cd "/Volumes/OliverHardD/Oxford_data"
count=8

for i in F*; do
	
	if [ $i = *001 ] || [ $i = *002 ] || [ $i = *003 ] || \
		[ $i = *004 ] || [ $i = *005 ] || [ $i = *006 ] || \
		[ $i = *007 ] || [ $i = *008 ] || [ $i = *009 ] || \
		[ $i = *010 ] || [ $i = *011 ]; then 
		echo "Skipping $i"
		continue
	fi

	cd "$i"

	for j in *; do

		cd $j
		
		echo $(pwd)
		cp * /Users/OliverW/Desktop/Project/Subjects/sub-0$count/Dicoms

		cd ..

	done

	echo "Sub-$count, done"
	((count++))

	cd "/Volumes/OliverHardD/Oxford_data"
done
