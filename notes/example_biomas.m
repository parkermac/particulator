modelDir = '/Volumes/littlegray/biomas2009/';
gridDir = '/Users/neil/Dropbox/cmg_tools/particulator/data/biomas/';
run = modelRun_biomas(modelDir,2009,gridDir);
							% _run_ identifies a model run to use as source data

x0 = run.grid.x(run.grid.mask==1);	% pick initial coordinates
y0 = run.grid.y(run.grid.mask==1);
sigma0 = zeros(size(x0));
t0 = run.t(1) .* ones(size(x0));
t1 = t0 + 3/24;
rel = par_release('x0',x0,'y0',y0,'sigma0',sigma0,'t0',t0,'t1',t1,...
				  'Ninternal',4,'tracers',{'ice','temp','diatom'});
							% _rel_ = the setup of a particle release
rel.verbose = 1;
rel.diffusive = 0;

steps = par_integrate(rel,run);
							% _steps_ = the actual Lagrangian integration
							
P = par_concatSteps(steps); % concatenates _steps_ variable by variable into
							% a single structure P that's easier to analyze