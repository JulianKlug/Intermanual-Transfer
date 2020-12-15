%%% Preprocess functional matrices
% - Matrices should not be hidden in struct
% - Matrices should be timepoints*regions

clear; clc;

in_dir = '/Users/jk1/temp/fmri_test/data/HMM_test/BNA_mat';
out_dir = '/Users/jk1/temp/fmri_test/data/HMM_test/BNA_exp';
HMM_toolbox = '/Users/jk1/matlab/toolboxes/HMM-MAR';
prepro_subpath = '/utils/preproc/';
addpath(genpath(fullfile(HMM_toolbox, prepro_subpath)))

n_session_time_points = 475;
matrix_name_regex = '^s.*\.mat$';
out_matrix_name = 'combined_sessions_TCA';

matrix_files = cellstr(spm_select('FPlist',in_dir, matrix_name_regex)); 
n_subjects = length(matrix_files);
T = repmat(n_session_time_points,1,n_subjects);
fprintf('%i subject sessions found.\n' ,...
        n_subjects);

X = [];
regions_var_zero = [];
for matrix_idx=1:n_subjects
    matrix = load(matrix_files{matrix_idx});
    matrix_name = char(fieldnames(matrix));
    expanded_matrix = getfield(matrix,matrix_name);
    subj_data = expanded_matrix{1,1};
    subj_data = subj_data'; % matrix should be timepoints*regions
    region_wise_variance = std(subj_data);
    if any(region_wise_variance == 0)
        subj_var_zero_regions = find(std(subj_data) == 0);
        fprintf('Regions with zero variance for subject "%s": "%d" \n' ,...
        matrix_name, subj_var_zero_regions);
    end
    regions_var_zero = [regions_var_zero, subj_var_zero_regions];
    X = [X; subj_data];
end
regions_var_zero = unique(regions_var_zero);
fprintf('Dropped regions (zero variance):');
disp(regions_var_zero);
region_mapping_table = array2table(X);
X(:, regions_var_zero) = [];
region_mapping_table(:, regions_var_zero) = [];
region_mapping = region_mapping_table.Properties.VariableNames;

[cleanX, cleanT] = cleandata4hmm(X, T);
assert(isequal(cleanX,X) && isequal(cleanT,T), 'Data matrix does not pass data cleaning.');
save(fullfile(out_dir, out_matrix_name), 'X');
save(fullfile(out_dir, 'index_to_region_mapping'), 'region_mapping');

clear; 