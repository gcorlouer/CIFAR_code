tsdim = 10; morder =5; specrad = 0.5; nobs = 1000;
connect_matrix = [0 1; 1 0];
[tsdata,var_coef,corr_res] =var_sim(connect_matrix, morder, specrad, nobs);
cd(home_dir)
fpath = fullfile(home_dir, 'TimeSeries_analysis','tsdata.mat');
save(fpath)
X = load(fpath)