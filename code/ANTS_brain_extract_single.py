import tensorflow_probability 
import antspynet
import ants

t1 = ants.image_read("t1name_here.nii.gz")
t2 = ants.image_read("t2name_here.nii.gz")

t1t2 = list()

t1t2.append(t1)
t1t2.append(t2)

t1t2_probability_mask = antspynet.brain_extraction(t1t2, modality='t1t2infant', verbose=True)

t1t2_mask = ants.threshold_image(t1t2_probability_mask, 0.5, 1, 1, 0)

ants.image_write(t1t2_mask, "./t1name_here_T1wT2w_mask.nii.gz")


