%%% Preprocess functional matrices
% - Matrices should not be hidden in struct
% - Matrices should be timepoints*regions

clear; clc;

in_dir = '/Users/jk1/temp/fmri_test/data/HMM_test/BNA_mat';
out_dir = '/Users/jk1/temp/fmri_test/data/HMM_test/BNA_exp';
HMM_toolbox = '/Users/jk1/matlab/toolboxes/HMM-MAR';
prepro_subpath = '/utils/preproc/';
addpath(genpath(fullfile(HMM_toolbox, prepro_subpath)))

T = [475];
matrix_name_regex = '^s.*\.mat$';
matrix_files = cellstr(spm_select('FPlist',in_dir, matrix_name_regex)); 

for matrix_idx=1:length(matrix_files)
    matrix = load(matrix_files{matrix_idx});
    matrix_name = char(fieldnames(matrix));
    expanded_matrix = getfield(matrix,matrix_name);
    X = expanded_matrix{1,1};
    X = X'; % matrix should be timepoints*regions
    
    [temp, t] = cleandata4hmm(X, T);
    save(fullfile(out_dir, matrix_name), 'X')
end

clear; 