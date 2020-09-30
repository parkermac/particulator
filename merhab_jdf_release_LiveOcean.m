%% MERHAB Particle Release for JdF
% April 22, 2020 

% locate a model run to use as source data
modelDir = '/Users/pm8/Documents/LiveOcean_roms/output/cas6_v3_lo8b/';
year = 2019;
dtOut = 1/24; % PM this is time step of saved particulator output in days
run = modelRun_romsCascadiaLO('LiveOcean',modelDir,year,dtOut);
disp(['Program started at ' datestr(now)])
disp(['found ' num2str(run.numFrames) ' model saves from ' ...
	  datestr(run.t(1)) ' to ' datestr(run.t(end))]);
disp(['the first file is ' run.filename{1}]);
							
%% Pick initial coordinates: 
% pick initial coordinates
% space

% JdF Eddy region
% x0 = -125.8 : 0.052 : -125;
% y0 = 48.2 : 0.04 : 48.8;

% Tacoma Narrows
x0 = linspace(-122.65, -122.45, 30)
y0 = linspace(47.2, 47.35, 30)

sigma0 = [0]; % surface
% t0 = run.t(1):2:run.t(end); %Release every 2 days starting at Jan 1, release until end of year
t0 = run.t(1);
[x0,y0,sigma0,t0] = ndgrid(x0(:),y0(:),sigma0(:),t0(:)); % make a 4D grid out of those
H0 = run.interp('H',x0,y0); % get bottom depth from the model run

% keep only points below the 30 m isobath
x0 = x0(H0 > 30); 
y0 = y0(H0 > 30);
sigma0 = sigma0(H0 > 30);
t0 = t0(H0 > 30);

% time
t1 = run.t(end) .* ones(size(x0));
t1 = min(t1, t0 + 30); % track for 30 days or until the last save

% set timestep
DT_saves = run.t(2) - run.t(1);
Ninternal = 1; % internal timesteps for particle integration per interval
			   % between saved frames in the model run
disp(['integrating ' num2str(length(x0(:))) ' particles with a timestep of ' ...
	  num2str(DT_saves/Ninternal) ' days']);

% this returns an object specifying the setup of a particle release,
% summarizing all the choices above
rel = par_release('x0',x0,'y0',y0,'sigma0',sigma0,'t0',t0,'t1',t1,...
				  'Ninternal',Ninternal,...
				  'tracers',{'salt','temp'},'verbose',1,...
				  'verticalMode','sigmaLevel','verticalLevel',0);
rel.verbose = 1; % extra diagnostic info please

% track for comparison
P = par_concatSteps(par_integrate(rel,run));


% clear DT_saves Ninternal x in y x0 y0 H0 t1 t0 sigma0 modelDir steps ...
%     x0_hb y0_hb t0_hb t1_hb H0_hb sigma0_hb x0_off y0_off H0_off t1_off t0_off sigma0_off
% cd /data1/hstone/ % For fjord
%save ../particulator_output/test2.mat -v7.3
save('../particulator_output/test_tn.mat', '-struct', 'P');
disp(['Program completed at ' datestr(now)])
