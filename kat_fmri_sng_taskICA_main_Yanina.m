%% Code to run group ICA on task-based/resting state fMRI using GIFT
%% modified for the FAB project
% Dependencies:
% available at https://github.com/kamentsvetanov/external/tree/master/mat
% spm12
% gica 
% matlabcentral
%genpath(addpath('spm'));
addpath(genpath('C:\Users\segaertk-admin\Documents\NI_software\spm12'))
addpath(genpath('C:\Users\segaertk-admin\Documents\NI_software\gica'));
addpath(genpath('C:\Users\segaertk-admin\Documents\NI_software\matlabcentral')); % Contains rdir

%% add EM fMRI filepaths to T table
clear
% My code is developed around the following two variables (S and T)
% S - a structure containing study/project variables including paths, acquisition details and paramters for different processing steps (saved in substructures e.g. S.ica contains all about ICA)
% T - a table containing subject specific information e.g. Subject ID, age,cognitive mesures, to subject-specific filepaths.
%create a mat file from an excel file with participant info
excelFilePath = 'C:/Users/segaertk-admin/Documents/ToT/taskICA_part1_Yanina/participants'
dataTable = readtable(excelFilePath);
matFilePath = 'C:/Users/segaertk-admin/Documents/ToT/taskICA_part1_Yanina/ica_setup_20240102.mat';
save(matFilePath, 'dataTable');

T = load('C:/Users/segaertk-admin/Documents/ToT/taskICA_part1_Yanina/ica_setup_20240102.mat'); % Build your own structure S and table T similar to those in ica_setup_20231205.mat 

% removed the part adding filepaths of processed EPI data

% Exclude subjects for which the ICA fails
% excl_subj = {'CC510480',... 
%             };
% id        = strmatch(excl_subj,T.SubCCIDc);
% T(id,:)   = [];

% ICA Setup
 % ICA Setup
    ICA                   = [];
    ICA.do_mdl            = 0; % 1 - Estimate number of PCs using MDL criterion estimation, otherwise set to 0
    ICA.ncomps            = [5];%,30,40,50,75,100];Number of ICA components requested (if do_mdl=1 this is overwritten) 
    ICA.prefix            = {'gica_tot'};%;{'CC700', 'CC280', 'CC700_CC280'}; % Give a prefix to the name of the analysis
    ICA.giftprefix        = 'tot'; % Type of ICA depending on the data input. For 3D data, e.g. structural data use 'sbm'
    ICA.scan_vec          = 1:500;% Total number of volumes  
    ICA.nscans            = numel(ICA.scan_vec);
    ICA.filepaths         =  [strcat('', dataTable.f_tot_ses1_run1 , ''',''' , dataTable.f_tot_ses1_run2, ''',''' , dataTable.f_tot_ses1_run3 , ''',''' , dataTable.f_tot_ses1_run4 , ''',''' , dataTable.f_tot_ses2_run1, ''',''' , dataTable.f_tot_ses2_run2, ''',''' , dataTable.f_tot_ses2_run3,  ''',''' , dataTable.f_tot_ses2_run4)]; % A cell array of filepaths to brain images. For multiples runs/sessions use multiple columns
    ICA.nsubjects         = size(T,1); % Number of subjects 
    ICA.SubID             = dataTable.SubID; % Subject ID, good to cross-reference at later point
    ICA.do_parallel       = 1; % 1-do parallel | 0 - do serial
    ICA.num_workers       = 128;
    ICA.do_icasso         = 0; % Change at a later stage to 1 to ensure the components are stable
    ICA.num_icasso_runs   = 128; % Number of ICASSO repetitions
    ICA.root_dir          = 'C:\\Users\\segaertk-admin\\Documents\\ToT\\taskICA_part1_Yanina\\output'; % Name of output folder
    %ICA.groupsInfo.name   = 'Age'; % (optional) Could use additional variable to correlate Loading with
    %ICA.groupsInfo.val    = T.Age'; % (optional) Varible to be correlated with subject loading values

% Path and name of gift batch template file
S.paths.scripts = 'C:\Users\segaertk-admin\Documents\ToT\taskICA_part1_Yanina';
    ICA.gica_template_fname = fullfile(S.paths.scripts, 'GIFT','kat_fmri_rest_gift_batch_template.m'); 

    % Filepaths to Input data for all subjects
%     ICA.fepi = [strcat('''', ICA.filepaths ,'''')];
%     ICA.fepi = ['char(' cell2mat(strcat(ICA.fepi', ','))];
%     ICA.fepi(end) = [')'];
%     ICA.f_mask = [strcat('''', f_mask ,'''')] ;
    global GICA_PARAM_FILE;

for ii = 1:length(ICA.ncomps)
    ICA.ncomp     = ICA.ncomps(ii);  
    ICA.ncomp_pca = round(ICA.ncomp*1.5); % Number of Principle Components = number of ICs with a factor of 1.5
    for jj = 1:numel(ICA.prefix)
        if ICA.do_mdl == 1
             ICA.out_dir = fullfile(ICA.root_dir, sprintf('%s_mdl_n%0.3d_%s', ICA.prefix{jj},ICA.nsubjects,datestr(now,'yyyymmdd')));
             ICA.gica_fname = fullfile(S.paths.scripts,sprintf('GIFT/%s_mdl_n%0.3d_gift_batch.m',ICA.prefix{jj},ICA.nsubjects));
        else
            ICA.out_dir    = fullfile(ICA.root_dir, sprintf('%s_IC%0.3d_n%0.3d_%s', ICA.prefix{jj}, ICA.ncomp,ICA.nsubjects,datestr(now,'yyyymmdd')));
            ICA.gica_fname = fullfile(S.paths.scripts,sprintf('GIFT/%s_IC%0.3d_n%0.3d_gift_batch.m',ICA.prefix{jj},ICA.ncomp,ICA.nsubjects));
        end

        % Delete batch file it it exists
        if exist(ICA.gica_fname) == 2
            delete(ICA.gica_fname);
            pause(2);
        end

        kat_fmri_rest_gift_run(ICA);%fepi, fspm, out_dir, gica_template_fname, gica_fname, ncomp,do_parallel,num_workers,length(scan_vec));        

        ICA.param_file = fullfile(ICA.out_dir, sprintf('%s_ica_parameter_info.mat',ICA.giftprefix));
        ICA.icasso_file = fullfile(ICA.out_dir, sprintf('%s_icasso_results.mat',ICA.giftprefix));
            
        [ICA.falff S.ica.dynrange] = kat_fmri_gift_spectra(ICA.param_file); % Estimate spectral component/mean fALFF for each component
        save(fullfile(ICA.out_dir,sprintf('ica_setup_%s.mat',datestr(now,'yyyymmdd'))),'S','T','ICA');                              
    end
end
