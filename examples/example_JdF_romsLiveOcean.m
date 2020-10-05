%% Surface trapped particle release near the JdF Eddy
% 2020.09.30 Parker MacCready (based largely on Code from Hally Stone)

% locate a model run to use as source data
modelDir = '/Users/pm8/Documents/LiveOcean_roms/output/cas6_v3_lo8b/';
datenum1 = datenum(2019,07,04);
datenum2 = datenum(2019,07,05);
addpath('../');
run = modelRun_romsLiveOcean(modelDir, datenum1, datenum2);
disp(['Program started at ' datestr(now)])
disp(['found ' num2str(run.numFrames) ' model saves from ' ...
	  datestr(run.t(1)) ' to ' datestr(run.t(end))]);
disp(['the first file is ' run.filename{1}]);
							
%% Pick initial coordinates: 
% pick initial coordinates
% space

% JdF Eddy region (matches eddy0 experiment in tracker2.py)
x0 = linspace(-125.6, -125.2, 20);
y0 = linspace(48.4, 48.6, 20);

sigma0 = [0]; % surface
t0 = run.t(1);
[x0,y0,sigma0] = ndgrid(x0(:),y0(:),sigma0(:)); % make an ND grid out of those
H0 = run.interp('H',x0,y0); % get bottom depth from the model run

% keep only points below the 30 m isobath
x0 = x0(H0 > 30); 
y0 = y0(H0 > 30);
sigma0 = sigma0(H0 > 30);

% time
t1 = run.t(end) .* ones(size(x0));

% set timestep
DT_saves = run.t(2) - run.t(1);
Ninternal = 12; % internal timesteps for particle integration per interval
			   % between saved frames in the model run
disp(['integrating ' num2str(length(x0(:))) ' particles with a timestep of ' ...
	  num2str(DT_saves/Ninternal) ' days']);

% this returns an object specifying the setup of a particle release,
% summarizing all the choices above
rel = par_release('x0',x0,'y0',y0,'sigma0',sigma0,'t0',t0,'t1',t1,...
				  'Ninternal',Ninternal,...
				  'tracers',{'salt','temp'},...
                  'verbose',1,...
				  'verticalMode','3D',... % or 'sigmaLevel'
                  'verticalLevel',0);
rel.verbose = 1; % extra diagnostic info please

P = par_concatSteps(par_integrate(rel,run));

save('../../particulator_output/eddy0.mat', '-struct', 'P');
disp(['Program completed at ' datestr(now)])
