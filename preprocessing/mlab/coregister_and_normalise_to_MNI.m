%% fMRI Pre-processing wrapper script
% This script preprocesses BOLD and T1 MRI images 
% (BOLD files should already be realigned between themselves)
% 1. Coregister T1 to reference and apply to BOLD  
% 2. Normalise  T1 to reference and apply to BOLD

% It follows a particular directory structure which must
% be adhered to.
%

%% Clear variables and command window
clear all , clc
%% Specify paths
% Experiment folder
data_path = '/home/klug/working_data/ed_transfer_rs/RS/';
spm_path = '/home/klug/spm12';
reference_path = '/home/klug/working_data/ed_transfer_rs/MNI152_T1_2mm.nii';

T1_regex = '^s.*\.nii$';
functional_regex = '^rf.*\.nii$';

coreg_T1_regex = '^coreg_s.*\.nii$';
coreg_functional_regex = '^coreg_rf.*\.nii$';


script_path = mfilename('fullpath');
script_folder = script_path(1 : end - size(mfilename, 2));
addpath(genpath(script_folder));
% addpath(genpath(spm_path));

if ~(exist(data_path))
    fprintf('Data directory does not exist. Please enter a valid directory.')
end

addpath(reference_path, data_path)

d = dir(data_path);
isub = [d(:).isdir]; %# returns logical vector
subjects = {d(isub).name}';
subjects(ismember(subjects,{'.','..', 'CONN'})) = [];

for i = 1: numel ( subjects )
    fprintf('%i/%i (%i%%) \n', i, size(subjects, 1), 100 * i / size(subjects, 1));
    subj_dir = fullfile(data_path,subjects{i});
    
    fprintf('Registering functional to template for subject "%s" \n' ,...
        subjects{i});
    
    T1_file = cellstr(spm_select('FPlist',fullfile(subj_dir,'/MPRAGE'), T1_regex));
    functional_files = cellstr(spm_select('FPlist',fullfile(subj_dir,'/BOLD','/realigned_Yeo'), functional_regex)); 
    
    mkdir(fullfile(subj_dir,'/MPRAGE/coreg'))
    mkdir(fullfile(subj_dir,'/BOLD/realigned_Yeo/coreg'))
    
    coregistration_to_MNI = coregister_job({reference_path}, T1_file, functional_files);

    spm('defaults', 'FMRI');
    spm_jobman('run', coregistration_to_MNI);

    coreg_T1_file = cellstr(spm_select('FPlist',fullfile(subj_dir,'/MPRAGE/coreg'), coreg_T1_regex));
    coreg_functional_files = cellstr(spm_select('FPlist',fullfile(subj_dir,'/BOLD','/realigned_Yeo', '/coreg'), coreg_functional_regex)); 

    mkdir(fullfile(subj_dir,'/MPRAGE/coreg/norm'))
    mkdir(fullfile(subj_dir,'/BOLD/realigned_Yeo/coreg/norm'))
    
    fprintf('Normalising functional to template for subject "%s" \n' ,...
        subjects{i});
    
    normalisation_to_MNI = normalisation_job({reference_path}, coreg_T1_file, coreg_functional_files);
    spm_jobman('run', normalisation_to_MNI);

end
