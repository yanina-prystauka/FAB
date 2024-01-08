function kat_fmri_rest_gift_run(X)% subjects, spmfiles, out_dir, gica_template_fname, gica_fname, ncomp, do_parallel, num_workers, nscans )
%RUN_GIFT Replaces parameters in GIFT batch script given to function, and
%runs group ICA analysis


%-Delete existing directory and make a new one
%---------------------------------------------
try
    rmdir(X.out_dir,'s');
end
mkdir(X.out_dir);
cd(X.out_dir);


% Read in batch template file
gift_batch_script = fileread(X.gica_template_fname);


try f_mask = [strcat('''', X.f_mask ,'''')]; catch f_mask ='[]'; end


% Type of analysis; Options are 1, 2 and 3.
% 1 - Regular Group ICA
% 2 - Group ICA using icasso
% 3 - Group ICA using MST
if X.do_icasso
    X.which_analysis = 2;
else
    X.which_analysis = 1;
end

% Parallel computing
if X.do_parallel
    mode_comp = 'parallel'; % 'serial' | 'parallel'
else
    mode_comp = 'serial';
end

gift_batch_script = regexprep(gift_batch_script, '<WHICH_ANALYSIS>', num2str(X.which_analysis));
gift_batch_script = regexprep(gift_batch_script, '<DO_PARALLEL>', strcat('''', mode_comp,''''));
gift_batch_script = regexprep(gift_batch_script, '<NUM_WORKERS>', num2str(X.num_workers));
gift_batch_script = regexprep(gift_batch_script, '<NUM_ICASSO_RUNS>', num2str(X.num_icasso_runs));


% Set input file list
X.fepi = [strcat('''', X.filepaths ,'''')];
% X.fepi = ['char(' cell2mat(strcat(X.fepi', ';'))];
% X.fepi(end) = [')'];
% fl_str = X.fepi;%strcat('{', strjoin(X.fepi', ';\n'), '}');
fl_str = strcat('{', strjoin(X.fepi', ';\n'), '}');
% sl_str = strcat('{', strjoin(X.fspm', ';\n'), '}');
gift_batch_script = regexprep(gift_batch_script, '<INPUT_FILES>', fl_str);
gift_batch_script = regexprep(gift_batch_script, '<MASK_FILE>', f_mask);
% gift_batch_script = regexprep(gift_batch_script, '<SPM_FILES>', sl_str);

% Set output directory and files
gift_batch_script = regexprep(gift_batch_script, '<OUT_DIR>', strcat('''', X.out_dir, ''''));
gift_batch_script = regexprep(gift_batch_script, '<PREFIX>', strcat('''', X.giftprefix, ''''));

% Set/estimated number of components (using MDL criterion or user defined)
gift_batch_script = regexprep(gift_batch_script, '<DO_MDL>', num2str(X.do_mdl));
gift_batch_script = regexprep(gift_batch_script, '<PCA_NCOMP>', num2str(min(X.ncomp_pca,X.nscans-1)));
gift_batch_script = regexprep(gift_batch_script, '<ICA_NCOMP>', num2str(X.ncomp));


% Write out customised batch file
if exist(X.gica_fname) == 2
    delete(X.gica_fname);
    pause(2);
end
 fid = fopen( X.gica_fname, 'wt');
fprintf(fid, '%s', gift_batch_script);
fclose(fid);

% Run analysis
mkdir(X.out_dir);
cd(X.out_dir);
% wait until file writing finishes
while (~exist(X.gica_fname, 'file'))
  sleep(1); 
end
icatb_batch_file_run(X.gica_fname);

% Print Report
    global GICA_PARAM_FILE;
    X.dir_print  = fullfile(X.out_dir,'xtml_report');
    X.param_file = fullfile(X.out_dir, sprintf('%s_ica_parameter_info.mat',X.giftprefix));
    GICA_PARAM_FILE  = X.param_file;

    publish('icatb_gica_html_report', 'outputDir',    X.dir_print, ...
                                      'showCode',     false, ...
                                      'useNewFigure', false ...
                                      ...'format',       'pdf', ...
                                      ...'imageFormat',  'pdf' ...
                                      );
end

