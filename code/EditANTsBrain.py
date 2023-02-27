#Import packages
import cv2
import numpy as np
import nibabel as nib
import matplotlib.pyplot as plt

#Load in the image, identify superior slice with mask, and slice 100mm inferior to that
ants_mask=nib.load('t1name_here_T1wT2w_mask.nii.gz')
a = np.array(ants_mask.dataobj)
tmp=a.mean(axis=0)
tmp=tmp.mean(axis=0)
tmpnz=np.array(tmp.ravel().nonzero())
topslice=tmpnz.max(1)
pz = ants_mask.header.get_zooms()
bottomslice=topslice-np.round(100/pz[2])
bottomslice=max(bottomslice,0)
a[:,:,0:int(bottomslice)]=0

#Fill holes slicewise (minor correction in far superior region near brain-cerebellum interface
a_closed=a.copy()
for x in range(int(bottomslice), int(topslice)):
  im_slice=a[:,:,int(x)]
  th, im_th = cv2.threshold(im_slice, 0, 255, cv2.THRESH_BINARY);
  im_floodfill = im_th.copy()
  h, w = im_th.shape[:2]
  mask = np.zeros((h+2, w+2), np.uint8)
  cv2.floodFill(im_floodfill, mask, (0,0), 255);
  im_diff=im_th-im_floodfill
  th, im_out = cv2.threshold(im_diff, -1, 1, cv2.THRESH_BINARY);
  a_closed[:,:,int(x)]=im_out

#Save the image
img = nib.Nifti1Image(a_closed, np.eye(4))
nib.save(img, 't1name_here_T1wT2w_mask_edit.nii.gz')  
