import os
import nibabel as nib

def binarize_mask(mask_path):
    img = nib.load(mask_path)
    data = img.get_fdata()

    data[data > 0] = 1
    bin_img = nib.Nifti1Image(data, img.affine)
    nib.save(bin_img, os.path.join(os.path.dirname(mask_path), f'bin_{os.path.basename(mask_path)}'))

def restrict_to_yeo(parcellation_path, yeo_path):
    yeo_img = nib.load(yeo_path)
    yeo_data = yeo_img.get_fdata()

    parcellation_img = nib.load(parcellation_path)
    parcellation_data = parcellation_img.get_fdata()

    restricted_parcellation = parcellation_data * (yeo_data > 0)
    return restricted_parcellation


# binarize_mask('/Users/jk1/temp/fmri_test/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz')
restrict_to_yeo('/Users/jk1/temp/fmri_test/ward_parcellation.nii.gz', '/Users/jk1/temp/fmri_test/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz')