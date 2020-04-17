clear all

OutputName = '181209_16h_3Node_FB2.mat';

%% Initialize Time Series
tmin = 0*15;                    % t = 0
tmax = 300*15;                  % t = max
inc = 301;                     % # of time steps

% Induction time
DOX  = [ones(1,64) zeros(1,237)];
time = linspace(tmin,tmax,inc);

%% Load Kinetic Parameters

load 181208_Fit6_5.mat kdeg_GFP kdeg_TF1 kdeg_TF2 ...
	T1hi T1_fold T1low T2low k1 kb_gabor kb_cyc1_2n k2_3N k3

k2_4n = k2_3N;      % 2nd node production rate with 4 operators (from fit)
k3_4n = k3;         % 3nd node production rate with 4 operators (from fit)

clear k2_3N k3

%% Load Thermodynamic Model and Parameter Space

load ThermoModel/181119_Thermo_FB2 params params_meas ...
    ind1_stor ind2_stor

load ThermoModel/181119_2in_interp.mat func_stor
func1_stor = func_stor;
clear func_stor

load ThermoModel/181119_42_10_interp.mat func_stor
func2_stor = func_stor;
clear func_stor

%% Initialize Storage Arrays
GFP_ON_stor = zeros(inc,length(params));
GFP_ON_norm_stor = zeros(inc,length(params));

basal_stor = zeros(1,length(params));
TF1_max = zeros(1,length(params));
TF2_min = zeros(1,length(params));
TF2_max = zeros(1,length(params));
TF2_start = zeros(1,length(params));

TF2_ON_stor = zeros(inc,length(params));


%% Loop and run Time Series

% Set-up parallelization for cluster
ncores = 12;
myCluster = parcluster('local') % cores on compute node to be "local"
if getenv('ENVIRONMENT') % true if this is a batch job
  myCluster.JobStorageLocation = getenv('TMPDIR')  % points to TMPDIR
  ncores = str2num(getenv('NSLOTS'));
end
matlabpool(myCluster, ncores)

parfor i=1:length(params)
    tic
    
    % Thermo Model
    func1 = func1_stor{ind1_stor(i)};
    func2 = func2_stor{ind2_stor(i)};
    
    % Rate Scaling based on number of operators   
    n  = params(9,i);
    k2 = scaling(k2_4n,4,n);
    k3 = scaling(k3_4n,4,n);

    % Calculate B-Node Parameters
    T2low = 1;
    Therm1Low = func1(T1low*10^-6,T2low*10^-6);
    kb_cyc1_3N = kdeg_TF2*T2low;
    T2low_start = (kb_cyc1_3N + k2*Therm1Low)/kdeg_TF2;
    
    for j=1:50
        Therm1Low = func1(T1low*10^-6,T2low_start*10^-6);
        T2low_start = (kb_cyc1_3N + k2*Therm1Low)/kdeg_TF2;
    end    

    % Calculate C-Node Parameters
    Therm2Low = func2(T2low_start*10^-6);
    kb_cyc2_3N = kdeg_GFP*100;
    basal = (kb_cyc2_3N + k3*Therm2Low)/kdeg_GFP;       
    
    % Run ODEs
    initialC = [T1low, T2low_start, basal];
    [T,X] = ode23s(@(t,y)ThreeNode_FB2(t,y,time,DOX,k1,k2,k3,kdeg_TF1,kdeg_TF2,kdeg_GFP,kb_gabor,kb_cyc1_3N,kb_cyc2_3N,func1,func2), time, initialC);
    
    % Store output
    TF1_max(i) = max(X(:,1));
    TF2_start(i) = T2low_start;
    TF2_min(i) = min(X(:,2));
    TF2_max(i) = max(X(:,2));    
    
    GFP_ON = X(:,3);    
    GFP_ON_norm = (GFP_ON-basal)/max(GFP_ON-basal);
    GFP_ON_stor(:,i) = GFP_ON; 
    GFP_ON_norm_stor(:,i) = GFP_ON_norm;    
    
    TF2_ON_stor(:,i) = X(:,2);
    
    basal_stor(i) = basal;
    
	toc
end

clear func1_stor func2_stor

L = find(GFP_ON_norm_stor<0);
length(L)

%% Save
save(OutputName);

%% Plot
figure
plot(time,GFP_ON_stor(:,1:200))

figure
plot(time,GFP_ON_norm_stor(:,1:200))

figure
plot(time,TF2_ON_stor(:,1:200))

figure
plot(time,GFP_ON_norm_stor)