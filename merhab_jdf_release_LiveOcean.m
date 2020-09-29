%% MERHAB Particle Release for JdF
% April 22, 2020 

% locate a model run to use as source data
modelDir = '/pmr2/parker/archive/LiveOcean_roms/output/cascadia1_base_lobio5/'; % For fjord
% modelDir = '/Volumes/demeter/LiveOcean/';
% addpath('/Users/hbstone/Documents/GitHub/particulator')
year = 2017;
dtOut = 1;
run = modelRun_romsCascadiaLO('LiveOcean',modelDir,year,dtOut);
disp(['Program started at ' datestr(now)])
disp(['found ' num2str(run.numFrames) ' model saves from ' ...
	  datestr(run.t(1)) ' to ' datestr(run.t(end))]);
disp(['the first file is ' run.filename{1}]);
							
%% JDF Eddy: 
% pick initial coordinates
% space
x0_jdf = -125.8 : 0.052 : -125;
y0_jdf = 48.2 : 0.04 : 48.8; % grid in the JdF Eddy region
sigma0_jdf = [0]; % surface
t0_jdf = run.t(1):2:run.t(end); % Release every 2 days starting at Jan 1, release until end of year
[x0_jdf,y0_jdf,sigma0_jdf,t0_jdf] = ndgrid(x0_jdf(:),y0_jdf(:),sigma0_jdf(:),t0_jdf(:)); % make a 4D grid out of those
H0_jdf = run.interp('H',x0_jdf,y0_jdf); % get bottom depth from the model run

% keep only points below the 30 m isobath
x0_jdf = x0_jdf(H0_jdf > 30); 
y0_jdf = y0_jdf(H0_jdf > 30);
sigma0_jdf = sigma0_jdf(H0_jdf > 30);
t0_jdf = t0_jdf(H0_jdf > 30);

% time
t1_jdf = run.t(end) .* ones(size(x0_jdf));
t1_jdf = min(t1_jdf, t0_jdf + 30); % track for 30 days or until the last save

% set timestep
DT_saves = run.t(2) - run.t(1);
Ninternal = 1; % internal timesteps for particle integration per interval
			   % between saved frames in the model run
disp(['integrating ' num2str(length(x0_jdf(:))) ' particles with a timestep of ' ...
	  num2str(DT_saves/Ninternal) ' days']);

% this returns an object specifying the setup of a particle release,
% summarizing all the choices above
rel_jdf = par_release('x0',x0_jdf,'y0',y0_jdf,'sigma0',sigma0_jdf,'t0',t0_jdf,'t1',t1_jdf,...
				  'Ninternal',Ninternal,...
				  'tracers',{'salt','temp'},'verbose',1,...
				  'verticalMode','sigmaLevel','verticalLevel',0);
rel_jdf.verbose = 1; % extra diagnostic info please

% track for comparison
P_jdf = par_concatSteps(par_integrate(rel_jdf,run));


clear DT_saves Ninternal x in y x0_jdf y0_jdf H0_jdf t1_jdf t0_jdf sigma0_jdf modelDir steps ...
    x0_hb y0_hb t0_hb t1_hb H0_hb sigma0_hb x0_off y0_off H0_off t1_off t0_off sigma0_off
cd /data1/hstone/ % For fjord
save merhab_jdf_2017_cas6.mat -v7.3
disp(['Program completed at ' datestr(now)])
