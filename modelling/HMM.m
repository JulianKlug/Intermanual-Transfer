% Code used in Vidaurre et al. (2017) PNAS
%
% Detailed documentation and further examples can be found in:
% https://github.com/OHBA-analysis/HMM-MAR
% This pipeline must be adapted to your particular configuration of files. 
%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP THE MATLAB PATHS AND FILE NAMES
HMM_toolbox_dir = '/Users/jk1/matlab/toolboxes/HMM-MAR';
addpath(genpath(HMM_toolbox_dir))

K = 12; % no. states
repetitions = 1; %3; % to run it multiple times (keeping all the results)
DirData = '/Users/jk1/temp/fmri_test/data/HMM_test/BNA_exp/';
DirOut = '/Users/jk1/temp/fmri_test/data/HMM_test/BNA_out/';
data_matrix_name = 'combined_sessions_TCA.mat';

TR = 0.72;  
use_stochastic = 0; % set to 1 if you have loads of data

N = 3; % no. subjects
n_session_time_points = 475;
n_sessions_per_subj = 1; % as we regard every session as a distinct subject

T = repmat(n_session_time_points,1,N);
% the .mat file contains the data (ICA components) for all subjects, 
% in a matrix X of dimension (n_session_time_points time points by number of ICA components). 
% T{j} contains the lengths of each session (in time points)
 
data = load(fullfile(DirData, data_matrix_name));

options = struct();
options.K = K; % number of states 
options.order = 0; % no autoregressive components
options.zeromean = 0; % model the mean
options.covtype = 'full'; % full covariance matrix
options.Fs = 1/TR; 
options.verbose = 1;
options.standardise = 1;
options.inittype = 'HMM-MAR';
options.cyc = 500;
options.initcyc = 10;
options.initrep = 3;
options.useParallel = 1; % needs the MATLAB Parallel Computing toolbox  

% stochastic options
if use_stochastic
    options.BIGNbatch = round(N/30);
    options.BIGtol = 1e-7;
    options.BIGcyc = 500;
    options.BIGundertol_tostop = 5;
    options.BIGforgetrate = 0.7;
    options.BIGbase_weights = 0.9;
end

We run the HMM multiple times
for r = 1:repetitions
    [hmm, Gamma, ~, vpath] = hmmmar(data,T,options);
    save([DirOut 'HMMrun_rep' num2str(r) '.mat'],'Gamma','vpath','hmm')
    disp(['RUN ' num2str(r)])
end

%% Pull out metastates

for r = 1:repetitions
    figure(r)
    load([DirOut 'HMMrun_rep' num2str(r) '.mat'],'Gamma','hmm')
    subplot(1,2,1) % Figure 2B
    GammaSessMean = squeeze(mean(reshape(Gamma,[n_session_time_points n_sessions_per_subj N K]),1));    
    GammaSubMean = squeeze(mean(GammaSessMean,1));
    [~,pca1] = pca(GammaSubMean','NumComponents',1);
    [~,ord] = sort(pca1); 
    imagesc(corr(GammaSubMean(:,ord))); colorbar
    subplot(1,2,2) % Figure 2A
    P = hmm.P;
    for j=1:K, P(j,j) = 0; P(j,:) = P(j,:) / sum(P(j,:));  end
    imagesc(P(ord,ord),[0 0.25]); colorbar
    axis square
    hold on
    for j=0:13
        plot([0 13] - 0.5,[j j] + 0.5,'k','LineWidth',2)
        plot([j j] + 0.5,[0 13] - 0.5,'k','LineWidth',2)
    end
    hold off
end