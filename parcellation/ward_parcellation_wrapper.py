import os, time
import nilearn
import numpy as np
from nilearn import plotting
from nilearn.image import get_data
from nilearn.regions import Parcellations
import re

#%%

outdir = '/home/klug/working_data/ed_transfer_rs/'
main_path = '/home/klug/working_data/ed_transfer_rs/RS'

# Subject directory pattern in main dir (ex: S01_RS2)
subject_dir_pattern = re.compile("^S[0-9][0-9]_RS[0-9]$")
subject_sub_path = 'BOLD/realigned_Yeo/coreg/norm/'

n_clusters = 100

dataset = []
failed_subjects = []

#%%


subject_dirs = [d for d in os.listdir(main_path)
                if os.path.isdir(os.path.join(main_path, d)) and subject_dir_pattern.match(d)]
subject_dirs.sort()
subject_dirs = [os.path.join(main_path, d) for d in subject_dirs]

#%%

for subject_dir in subject_dirs:
    subject_sub_dir = os.path.join(subject_dir, subject_sub_path)
    if not os.path.exists(subject_sub_dir):
        failed_subjects.append(os.path.basename(subject_dir))
        continue
    subject_files = [os.path.join(subject_sub_dir, f) for f in os.listdir(subject_sub_dir) if os.path.isfile(os.path.join(subject_sub_dir, f))]
    subj_img_4d = nilearn.image.load_img(subject_files)
    # all subjects should have 480 time points
    assert subj_img_4d.shape[-1] == 480
    dataset.append(subj_img_4d)

## Parcellation


# Computing ward for the first time, will be long... This can be seen by
# measuring using time
start = time.time()

# Agglomerative Clustering: ward

# We build parameters of our own for this object. Parameters related to
# masking, caching and defining number of clusters and specific parcellations
# method.
ward = Parcellations(method='ward', n_parcels=n_clusters,
                     standardize=False, smoothing_fwhm=2.,
                     memory='nilearn_cache', memory_level=1,
                     verbose=1)
# Call fit on functional dataset: single subject (less samples).
ward.fit(dataset)
print("Ward agglomeration 1000 clusters: %.2fs" % (time.time() - start))

#%%

ward_labels_img = ward.labels_img_

# # Now, ward_labels_img are Nifti1Image object, it can be saved to file
# # with the following code:
ward_labels_img.to_filename(os.path.join(outdir, f'ward_parcellation_k{n_clusters}.nii.gz'))
