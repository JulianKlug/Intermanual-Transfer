% matlabbatch = normalisation_job(reference, main_image, images_to_co_normalise)% ARGUMENTS : 
% reference : image to normalise to
% main_image : image to normalise
% images_to_co_normalise : cell array of images to apply the same co-normalisation

% The function takes a reference file and a main_image file and passes them to
% matlabbatch for normalisation

function matlabbatch = normalisation_job(reference, main_image, images_to_co_normalise)

images_to_resample = main_image;
for idx = 1:numel(images_to_co_normalise)
    images_to_resample{end +1, 1} = images_to_co_normalise{idx};
end

matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = main_image; 
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = images_to_resample;

matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = reference;
% matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/Users/jk1/matlab/toolboxes/spm12/tpm/TPM.nii'};
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                             78 76 85];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = '/norm/norm_';
