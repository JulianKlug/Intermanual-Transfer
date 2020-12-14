function apply_mask(file_to_mask, mask_file, threshold, output_file_path)
%APPLY_MASK Apply a mask to an image
% ARGUMENTS : 
% file_to_mask : path to target image to be masked
% mask_file: path to mask file
% threshold: threshold to used to create a binary mask on mask file. If
% already binary use 0
% output_file_path: path to final masked image

target_file = spm_vol(file_to_mask);
target = spm_read_vols(target_file);
mask = spm_read_vols(spm_vol(mask_file));

bin_mask = mask > threshold;

segmented_target = bin_mask .* target;

V = target_file;
V.fname = output_file_path;
V.private.dat.fname = V.fname;
spm_write_vol(V,segmented_target);

end

