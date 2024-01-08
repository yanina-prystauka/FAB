%---------------------------%
% GICA analysis of fMRI SNG %
% Kamen Tvetanov            %
% with thanks to David Samu %
% 14/07/2015                %
%---------------------------%


% Enter the values for the variables required for the ICA analysis.
% Variables are on the left and the values are on the right.
% Characters must be enterd in single quotes.
%
% After entering the parameters, use icatb_batch_file_run(gift_batch); 


%% Modality. Options are fMRI and EEG
modalityType = 'fMRI';

%% Type of analysis
% Options are 1, 2 and 3.
% 1 - Regular Group ICA
% 2 - Group ICA using icasso
% 3 - Group ICA using MST
which_analysis = 1;

%% ICASSO options.
% This variable will be used only when which_analysis variable is set to 2.

icasso_opts.sel_mode = 'randinit';  % Options are 'randinit', 'bootstrap' and 'both'
icasso_opts.num_ica_runs = 128;      % Number of times ICA will be run

% Most stable run estimate is based on these settings. 
%icasso_opts.min_cluster_size = 2; % Minimum cluster size
%icasso_opts.max_cluster_size = 15; % Max cluster size. Max is the no. of components

%% Group ica type
% Options are spatial or temporal for fMRI modality. By default, spatial
% ica is run if not specified.
group_ica_type = 'spatial';

%% Parallel info
% enter mode serial or parallel. If parallel, enter number of
% sessions/workers to do job in parallel
parallel_info.mode = <DO_PARALLEL>; % 
parallel_info.num_workers = <NUM_WORKERS>;


%% Group PCA performance settings. Best setting for each option will be selected based on variable MAX_AVAILABLE_RAM in icatb_defaults.m. 
% If you have selected option 3 (user specified settings) you need to manually set the PCA options. 
%
% Options are:
% 1 - Maximize Performance
% 2 - Less Memory Usage
% 3 - User Specified Settings
perfType = 1;


%% Design matrix selection 
% Design matrix (SPM.mat) is used for sorting the components
% temporally (time courses) during display. Design matrix will not be used during the
% analysis stage except for SEMI-BLIND ICA.
% options are ('no', 'same_sub_same_sess', 'same_sub_diff_sess', 'diff_sub_diff_sess')
% 1. 'no' - means no design matrix.
% 2. 'same_sub_same_sess' - same design over subjects and sessions
% 3. 'same_sub_diff_sess' - same design matrix for subjects but different
% over sessions
% 4. 'diff_sub_diff_sess' - means one design matrix per subject.

keyword_designMatrix = 'no';

% Specify location of design matrix here if you have selected 'same_sub_same_sess' or
% 'same_sub_diff_sess' option for keyword_designMatrix variable
OnedesignMat = '';

%% There are three ways to enter the subject data
% options are 1, 2, 3 or 4
dataSelectionMethod = 4;


%% Method 4
% Input data file pattern for data-sets must be in a cell array. The no. of rows of cell array correspond to no. of subjects
% and columns correspond to sessions.

% use the query function to specify data files for analysis
input_data_file_patterns = <INPUT_FILES>;

% Input for design matrices will be used only if you have a design matrix
% for each subject i.e., if you have selected 'diff_sub_diff_sess' for
% variable keyword_designMatrix.
% input_design_matrices = <SPM_FILES>;

% Enter no. of dummy scans to exclude from the group ICA analysis. If you have no dummy scans leave it as 0.
dummy_scans = 0;

%%%%%%%% End for Method 4 %%%%%%%%%%%%

%% Enter directory to put results of analysis
%outputDir = <OUT_DIR>;
%disp(outputDir)


%% Enter Name (Prefix) Of Output Files
prefix = <PREFIX>;


%% Enter location (full file path) of the image file to use as mask
% or use Default mask which is []
maskFile = <MASK_FILE>;
% maskFile = '/imaging/camcan/sandbox/kt03/fmri/masks/Brain_mask_dartelmni_91x109x91.nii';
% maskFile = '/imaging/camcan/sandbox/ds02/other/brain_coverage/results/CC700_resting_coverage_masked_binary.nii';
% maskFile = '/imaging/camcan/sandbox/ds02/other/brain_coverage/results/CC280_SNG2_coverage_masked_binary.nii';



%% Group PCA Type. Used for analysis on multiple subjects and sessions.
% Options are 'subject specific' and 'grand mean'. 
%   a. Subject specific - Individual PCA is done on each data-set before group
%   PCA is done.
%   b. Grand Mean - PCA is done on the mean over all data-sets. Each data-set is
%   projected on to the eigen space of the mean before doing group PCA.
%
% NOTE: Grand mean implemented is from FSL Melodic. Make sure that there are
% equal no. of timepoints between data-sets.
%
group_pca_type = 'subject specific';


%% Back reconstruction type. Options are str and gica
backReconType = 'gica3';


%% Data Pre-processing options
% 1 - Remove mean per time point
% 2 - Remove mean per voxel
% 3 - Intensity normalization
% 4 - Variance normalization
preproc_type = 2;


%% PCA Type. Also see options associated with the selected pca option.
% Standard PCA and SVD PCA options are commented.
% PCA options are commented.
% Options are 1, 2 and 3
% 1 - Standard 
% 2 - Expectation Maximization
% 3 - SVD
% 4 - MPOWIT
% 5 - STP
pcaType = 1;


%% PCA options (Standard)

% a. Options are yes or no
% 1a. yes - Datasets are stacked. This option uses lot of memory depending
% on datasets, voxels and components.
% 2a. no - A pair of datasets are loaded at a time. This option uses least
% amount of memory and can run very slower if you have very large datasets.
pca_opts.stack_data = 'yes';

% b. Options are full or packed.
% 1b. full - Full storage of covariance matrix is stored in memory.
% 2b. packed - Lower triangular portion of covariance matrix is only stored in memory.
pca_opts.storage = 'full';

% c. Options are double or single.
% 1c. double - Double precision is used
% 2c. single - Floating point precision is used.
pca_opts.precision = 'single'; % 'single' | 'double'


% d. Type of eigen solver. Options are selective or all
% 1d. selective - Selective eigen solver is used. If there are convergence
% issues, use option all.
% 2d. all - All eigen values are computed. This might run very slow if you
% are using packed storage. Use this only when selective option doesn't
% converge.
pca_opts.eig_solver = 'selective';


%% PCA Options (Expectation Maximization)
% a. Options are yes or no
% 1a. yes - Datasets are stacked. This option uses lot of memory depending
% on datasets, voxels and components.
% 2a. no - A pair of datasets are loaded at a time. This option uses least
% amount of memory and can run very slower if you have very large datasets.
% pca_opts.stack_data = 'yes';

% b. Options are double or single.
% 1b. double - Double precision is used
% 2b. single - Floating point precision is used.
% pca_opts.precision = 'double';

% c. Stopping tolerance 
% pca_opts.tolerance = 1e-4;

% d. Maximum no. of iterations
% pca_opts.max_iter = 1000;


%% PCA Options (SVD)
% a. Options are double or single.
% 1a. double - Double precision is used
% 2a. single - Floating point precision is used.
% pca_opts.precision = 'single';

% b. Type of eigen solver. Options are selective or all
% 1b. selective - svds function is used.
% 2b. all - Economy size decomposition is used.
% pca_opts.solver = 'selective';


%% Maximum reduction steps you can select is 2. Options are 1 and 2. For temporal ica, only one data reduction step is
% used.
numReductionSteps = 2;

%% Batch Estimation. If 1 is specified then estimation of 
% the components takes place and the corresponding PC numbers are associated
% Options are 1 or 0
doEstimation = <DO_MDL>; 


%% MDL Estimation options. This variable will be used only if doEstimation is set to 1.
% Options are 'mean', 'median' and 'max' for each reduction step. The length of cell is equal to
% the no. of data reductions used.
estimation_opts.PC1 = 'mean';
estimation_opts.PC2 = 'mean';
estimation_opts.PC3 = 'mean';

%% Number of PCs to reduce each subject down to at each reduction step
% The number of independent components there will be extracted is the same as 
% the number of principal components after the final data reduction step.  
numOfPC1 = <PCA_NCOMP>;
numOfPC2 = <ICA_NCOMP>;
numOfPC3 = <ICA_NCOMP>;

%% Scale the Results. Options are 0, 1, 2, 3 and 4
% 0 - Don't scale
% 1 - Scale to Percent signal change
% 2 - Scale to Z scores
% 3 - Normalize spatial maps using the maximum intensity value and multiply timecourses using the maximum intensity value
% 4 - Scale timecourses using the maximum intensity value and spatial maps using the standard deviation of timecourses
scaleType = 0;


%% 'Which ICA Algorithm Do You Want To Use';
% see icatb_icaAlgorithm for details or type icatb_icaAlgorithm at the
% command prompt.
% Note: Use only one subject and one session for Semi-blind ICA. Also specify at most two reference function names

% 1 - Infomax
% 2 - FastICA
% 3 - ERICA
% 4 - SIMBEC
% 5 - EVD
% 6 - JADE OPAC
% 7 - AMUSE
% 8 - SDD ICA
% 9 - Semi-blind ICA
% 10 - Constrained ICA (Spatial)
% 11 - Radical ICA
% 12 - Combi
% 13 - ICA-EBM
% 14 - ERBM
% 15 - IVA-GL
% 16 - MOO-ICAR

algoType = 1;


%% Specify at most two reference function names if you select Semi-blind ICA algorithm.
% Reference function names can be acessed by loading SPM.mat in MATLAB and accessing 
% structure SPM.xX.name.
%refFunNames = {'Sn(1) synsub*bf(1)', 'Sn(1) syndom*bf(1)', 'Sn(1) synsub_err*bf(1)', 'Sn(1) semsub*bf(1)', 'Sn(1) semdom*bf(1)', 'Sn(1) semsub_err*bf(1)'};


%% Specify spatial reference files for multi-fixed ICA
% refFiles = {which('ref_default_mode.nii','), which('ref_left_visuomotor.nii','), which('ref_right_visuomotor.nii',')};


%% ICA Options - Name by value pairs in a cell array. Options will vary depending on the algorithm. See icatb_icaOptions for more details. Some options are shown below.
% Infomax -  {'posact', 'off', 'sphering', 'on', 'bias', 'on', 'extended', 0}
% FastICA - {'approach', 'symm', 'g', 'tanh', 'stabilization', 'on'}
%icaOptions = {'posact', 'off', 'sphering', 'on', 'bias', 'on', 'extended', 0};

