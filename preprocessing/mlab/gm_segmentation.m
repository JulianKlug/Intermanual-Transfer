%% fMRI Grey matter segmentation wrapper script
% This script segments GM in from T1 MRI images and applies it to fMRI 
% (BOLD files should already be in same space as T1 (realigned + normalised))
% It follows a particular directory structure which must
% be adhered to.
%

%% Clear variables and command window
clear all , clc
%% Specify paths
% Experiment folder
data_path = '/home/klug/working_data/ed_transfer_rs/RS/';
spm_path = '/home/klug/spm12';

gm_prob_threshold = 0.5;

destination_sub_path = '/BOLD/realigned_Yeo/coreg_norm_seg';

T1_sub_path = '/MPRAGE/coreg/norm/';
T1_regex = '^norm_coreg_s.*\.nii$';
seg_T1_regex = '^c1norm_coreg_s.*\.nii$';
functional_sub_path = '/BOLD/realigned_Yeo/coreg/norm/';
functional_regex = '^norm_coreg_rf.*\.nii$';

script_path = mfilename('fullpath');
script_folder = script_path(1 : end - size(mfilename, 2));
addpath(genpath(script_folder));
addpath(genpath(spm_path));

if ~(exist(data_path))
    fprintf('Data directory does not exist. Please enter a valid directory.')
end

addpath(data_path)


d = dir(data_path);
isub = [d(:).isdir]; %# returns logical vector
subjects = {d(isub).name}';
subjects(ismember(subjects,{'.','..', 'CONN'})) = [];

for i = 1: numel ( subjects )
    fprintf('%i/%i (%i%%) \n', i, size(subjects, 1), 100 * i / size(subjects, 1));
    subj_dir = fullfile(data_path,subjects{i});
    
    fprintf('Segmenting grey matter for subject "%s" \n' ,...
        subjects{i});
    
    T1_file = cellstr(spm_select('FPlist',fullfile(subj_dir, T1_sub_path), T1_regex));
    functional_files = cellstr(spm_select('FPlist',fullfile(subj_dir, functional_sub_path), functional_regex)); 
       
    segment_anatomical = segment_job(T1_file, spm_path);
    spm('defaults', 'FMRI');
    spm_jobman('run', segment_anatomical);
     
    mkdir(fullfile(subj_dir, destination_sub_path))

    for func_idx=1:length(functional_files)
        [fPath, fName, fExt] = fileparts(functional_files{func_idx});
        masked_image_path = fullfile(subj_dir, destination_sub_path, join(['seg_', fName, fExt]));
        segmented_gm_file = spm_select('FPlist',fullfile(subj_dir, T1_sub_path), seg_T1_regex);
        apply_mask(functional_files{func_idx}, segmented_gm_file, gm_prob_threshold, masked_image_path)
    end

end
