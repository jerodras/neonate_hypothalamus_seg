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

Downloading a sample dataset: 
