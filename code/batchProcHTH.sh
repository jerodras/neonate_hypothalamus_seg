#!/bin/bash

#Loop through subjects/visits in BIDs format
for img in `ls ../sub*/ses*/anat/*T1w.nii.gz`;do 

	hd=`pwd`

	#Should be BIDS format
	t1_basename_sub=`echo $img | awk -F "/" '{ print $2 }'`
	t1_basename_ses=`echo $img | awk -F "/" '{ print $3 }'`
	t1_basename_fname=`echo $img | awk -F "/" '{ print $5 }' | awk -F ".nii.gz" '{ print $1 }'`

	t2_basename_fname=`echo $img | awk -F "/" '{ print $5 }' | awk -F "T1w.nii.gz" '{ print $1"T2w" }'`

	#Make the target directory
	der_folder=`echo "../derivatives/hth_seg/"${t1_basename_sub}"/"${t1_basename_ses}"/anat"`
	mkdir -p $der_folder

	#Re-orient the nifti files just in case (some Siemens require this)
	echo "Re-orienting to standard"
	t1_ro_loc_basename=${t1_basename_sub}"/"${t1_basename_ses}"/anat/"${t1_basename_fname}
	t1_ro_loc=`echo "../derivatives/hth_seg/"${t1_ro_loc_basename}"_ro.nii.gz"`
	fslreorient2std "../"$t1_ro_loc_basename ${t1_ro_loc}

	t2_ro_loc_basename=${t1_basename_sub}"/"${t1_basename_ses}"/anat/"${t2_basename_fname}
	t2_ro_loc=`echo "../derivatives/hth_seg/"${t2_ro_loc_basename}"_ro.nii.gz"`
	fslreorient2std "../"$t2_ro_loc_basename ${t2_ro_loc}

	#Rigidly align T1w/T2w
	echo "Rigidly aligning T2w to T1w"
	flirt -in ${t2_ro_loc} -ref ${t1_ro_loc} -out "../derivatives/hth_seg/"${t2_ro_loc_basename}"_ro_in_T1w.nii.gz" -dof 6 -omat "../derivatives/hth_seg/"${t2_ro_loc_basename}"_ro_2_T1w.mat"
	cp ${t2_ro_loc} "../derivatives/hth_seg/"${t2_ro_loc_basename}"_ro_in_T1w.nii.gz"
        t2_ro_in_T1w_loc=`ls -1d "../derivatives/hth_seg/"${t2_ro_loc_basename}"_ro_in_T1w.nii.gz"`

	#ANTSPyNet Brain extraction, island removal, and small fill adjustment to better match UNC/UMN template
	echo "Extracting brain and removing islands"
	mkdir working
	cp $t2_ro_in_T1w_loc working
	cp $t1_ro_loc working
	cp ANTS_brain_extract_single.py working
	cd working
	t2_name=`ls *_ro_in_T1w.nii.gz | awk -F ".nii.gz" '{ print $1 }'`
	t1_name=`ls *T1w_ro.nii.gz | awk -F ".nii.gz" '{ print $1 }'`
	echo $t1_name
	echo $t2_name
	sed "s/t1name_here/${t1_name}/g" ../ANTS_brain_extract_single.py > ../tmp1.txt
	sed "s/t2name_here/${t2_name}/g" ../tmp1.txt > ../ANTS_brain_extract_execute.py
	/Users/rasmussj/opt/miniconda3/bin/python3 ../ANTS_brain_extract_execute.py
	rm ../ANTS_brain_extract_execute.py
        sed "s/t1name_here/${t1_name}/g" ../EditANTsBrain.py > ../EditANTsBrainRun.py
         /Users/rasmussj/opt/miniconda3/bin/python3 ../EditANTsBrainRun.py
        rm ../EditANTsBrainRun.py
         fslcpgeom ${t1_name}_T1wT2w_mask.nii.gz ${t1_name}_T1wT2w_mask_edit.nii.gz
	cp *mask*gz ../${der_folder}
	cd ..
	rm -r working
	rm tmp1.txt

	#Do the ANTS regstration to BCP template
	#HARD CODING HERE AS SHORT TERM KLUDGE BUT SHOULD BE INPUT
	mo_age="1"
	t1_mask_loc=`ls -1d ${der_folder}/*_T1wT2w_mask_edit.nii.gz`
	fslmaths $t1_ro_loc -mul ${t1_mask_loc} "../derivatives/hth_seg/"${t1_ro_loc_basename}"_ro_brain.nii.gz"
	t1_ro_loc_brain=`ls -1d "../derivatives/hth_seg/"${t1_ro_loc_basename}"_ro_brain.nii.gz"`
	t1_ants_t1_2_bcp=`echo "../derivatives/hth_seg/"${t1_ro_loc_basename}"_ro_brain_2_BCP"`
	antsRegistrationSyN.sh -d 3 -f templates/BCP-0${mo_age}M-T1.nii.gz -m ${t1_ro_loc_brain} -o ${t1_ants_t1_2_bcp} -n 24

	#Put the Atlas into native space, extract the binary mask
	moving_file="templates/MNI152_T1_1mm_seg.nii.gz"
	ref_file=`echo $t1_ro_loc`
	out_file=`echo "../derivatives/hth_seg/"${t1_ro_loc_basename}"_hth_seg.nii.gz"`
	MNI2BCP_warp=`ls templates/MNI_in_BCP-0${mo_age}M-T11Warp.nii.gz`
	MNI2BCP_mat=`ls templates/MNI_in_BCP-0${mo_age}M-T10GenericAffine.mat`
	BCP2T1_mat=`ls ${t1_ants_t1_2_bcp}0GenericAffine.mat`
	BCP2T1_invwarp=`ls ${t1_ants_t1_2_bcp}1InverseWarp.nii.gz`

	antsApplyTransforms -d 3 -i $moving_file -r $ref_file -o $out_file  -t [$BCP2T1_mat, 1] -t $BCP2T1_invwarp -t $MNI2BCP_warp -t $MNI2BCP_mat -n GenericLabel[Linear]

done

