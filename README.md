# neonate_hypothalamus_seg
An automatic pipeline for segmentation of the newborn hypothalamus.

The following materials are provided to guide the reader through the installation and use of a fully automated registration-based pipeline for the segmentation of the newborn hypothalamus. The code provided here is intended to be used with T1w/T2w image pairs using BIDs formatting. The output is designed to be compatible with the hypothalamic sub-unit segmentations provided by FreeSurfer's *mri_segment_hypothalamic_subunits* tool.

# Dependencies

* The code is written as a bash shell script with dependence on the following tools/software:

  * [fsl](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation) (fslreorient2std, fslcpgeom, fslmaths, flirt are used)

  * [python](https://www.python.org/downloads/) (This code was specifically written using python 3.9.7 via [miniconda](https://docs.conda.io/en/main/miniconda.html))

  * [ANTs](http://stnava.github.io/ANTs/) (*antsRegistrationSyN.sh* used for registration and *antsApplyTransforms* used for applyng the warps to the labels)

* Within Python, the following modules are used and should be installed (*e.g.,* `pip install antspynet`):

  * [tensorflow_probability](https://www.tensorflow.org/probability/install)

  * [antspynet](https://pypi.org/project/antspynet/)

  * [ants](https://pypi.org/project/ants/)

  * [cv2](https://pypi.org/project/opencv-python/)

  * [numpy](https://pypi.org/project/numpy/)

  * [nibabel](https://pypi.org/project/nibabel/)

  * [matplotlib](https://pypi.org/project/matplotlib/)

* Atlases for registration:

  * [UNC 4d atlas](https://www.nitrc.org/projects/uncbcp_4d_atlas/)

# Installation

Dependencies: Installation of the above dependencies should first be completed and all of the above tools verified to work  in a terminal (*e.g.,* Mac's terminal).

Download: Download the directory hosted here that uses the project name neonate_hypothalamus_seg (you will change this to suit your project). 

Downloading and moving the atlas files into the directory structure: The primary function of this code base is to simply register the participant to the age-appropriate UNC Atlas template. Once this is complete, pre-registered warps from the template space to the adult template are concatenated and the freesurfer defined subunits labels in adult space are registered back into the infant space using ANTs. In order to do this, the reference images must be in a place where the code expects them. IMPORTANT: Because these are external (UNC 4d atlas) they must be first downloaded (per above) and copied or moved into the appropriate directory structure ~/*base_directory*/*project_name*/code/templates. In the end, for example, the following should be in your directory tree: ~/*base_directory*/*project_name*/code/templates/BCP-01M-T1.nii.gz.

Downloading a sample dataset: This pipeline has been internally tested on multiple acquisition styles and datasets that are available to researchers for secondary analysis, including: [developing Human Connectome Project](http://www.developingconnectome.org/data-release/data-release-user-guide/), and the [UMN/UNC Baby Connectome Project](https://nda.nih.gov/edit_collection.html?id=2848). However, the original publication of this method was developed using data publicly available from a study of [Intergenerational Effects of Maternal Childhood Trauma on the Fetal Brain](https://nda.nih.gov/edit_collection.html?id=2308) and is used here as an example. Note that this data should be arranged in a [BIDS](https://bids-specification.readthedocs.io/en/stable/) data structure (see below).

# Usage

After downloading, converting raw data files to BIDs format, and installing the above materials, one should have a directory that looks like the below. This directory structure contains all of the necessary files for performing the segmentation. The README.txt is BIDS required and can contain notes about your sample (removed subjects etc). The code folder includes the python code for extracting the brain (ANTS_brain_extract_single.py, antspynet based), refining the brain mask by removing islands (EditANTsBrain.py), and finally the necessary registrations for hypothalamic sub-nuclei are carried out in a batch script (batchProcHTH.sh). All of the templates and registrations are contained within the subfolder "templates".

```bash
├── README.txt
├── code
│   ├── ANTS_brain_extract_single.py
│   ├── EditANTsBrain.py
│   ├── HTH_indices.txt
│   ├── batchProcHTH.sh
│   └── templates
│       ├── BCP-00M-T1.nii.gz
│       ├── BCP-01M-T1.nii.gz
│       ├── BCP-02M-T1.nii.gz
│       ├── BCP-03M-T1.nii.gz
│       ├── BCP-04M-T1.nii.gz
│       ├── MNI152_T1_1mm_seg.nii.gz
│       ├── MNI152_T1_1mm_seg_bin.nii.gz
│       ├── MNI_in_BCP-00M-T10GenericAffine.mat
│       ├── MNI_in_BCP-00M-T11InverseWarp.nii.gz
│       ├── MNI_in_BCP-00M-T11Warp.nii.gz
│       ├── MNI_in_BCP-00M-T1InverseWarped.nii.gz
│       ├── MNI_in_BCP-00M-T1Warped.nii.gz
│       ├── MNI_in_BCP-01M-T10GenericAffine.mat
│       ├── MNI_in_BCP-01M-T11InverseWarp.nii.gz
│       ├── MNI_in_BCP-01M-T11Warp.nii.gz
│       ├── MNI_in_BCP-01M-T1InverseWarped.nii.gz
│       ├── MNI_in_BCP-01M-T1Warped.nii.gz
│       ├── MNI_in_BCP-02M-T10GenericAffine.mat
│       ├── MNI_in_BCP-02M-T11InverseWarp.nii.gz
│       ├── MNI_in_BCP-02M-T11Warp.nii.gz
│       ├── MNI_in_BCP-02M-T1InverseWarped.nii.gz
│       ├── MNI_in_BCP-02M-T1Warped.nii.gz
│       ├── MNI_in_BCP-03M-T10GenericAffine.mat
│       ├── MNI_in_BCP-03M-T11InverseWarp.nii.gz
│       ├── MNI_in_BCP-03M-T11Warp.nii.gz
│       ├── MNI_in_BCP-03M-T1InverseWarped.nii.gz
│       ├── MNI_in_BCP-03M-T1Warped.nii.gz
│       ├── MNI_in_BCP-04M-T10GenericAffine.mat
│       ├── MNI_in_BCP-04M-T11InverseWarp.nii.gz
│       ├── MNI_in_BCP-04M-T11Warp.nii.gz
│       ├── MNI_in_BCP-04M-T1InverseWarped.nii.gz
│       └── MNI_in_BCP-04M-T1Warped.nii.gz
└── sub-ct00023
    └── ses-visit1
        └── anat
            ├── sub-ct00023_ses-visit1_run-02_T1w.json
            ├── sub-ct00023_ses-visit1_run-02_T1w.nii.gz
            ├── sub-ct00023_ses-visit1_run-02_T2w.json
            └── sub-ct00023_ses-visit1_run-02_T2w.nii.gz
```

The script is ran using the *batchProcHTH.sh* command and will iteratively loop through each unique participant in the base directory at a default age of one month. The following is output from the pipeline and contains the segmentation ~/*base_directory*/*project_name*/derivatives/sub-*subject_name*/ses-*session*/anat/sub-*subject_name_ses-session*T1w_hth_seg.nii.gz. In addition, midpoint files include registrations, warps, and masks. Examples are provided below. 

```bash
derivatives/
└── hth_seg
    └── sub-ct00023
        └── ses-visit1
            └── anat
                ├── sub-ct00023_ses-visit1_run-02_T1w_hth_seg.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro_T1wT2w_mask.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro_T1wT2w_mask_edit.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro_brain.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro_brain_2_BCP0GenericAffine.mat
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro_brain_2_BCP1InverseWarp.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro_brain_2_BCP1Warp.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro_brain_2_BCPInverseWarped.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T1w_ro_brain_2_BCPWarped.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T2w_ro.nii.gz
                ├── sub-ct00023_ses-visit1_run-02_T2w_ro_2_T1w.mat
                └── sub-ct00023_ses-visit1_run-02_T2w_ro_in_T1w.nii.gz
```

# Example Output

