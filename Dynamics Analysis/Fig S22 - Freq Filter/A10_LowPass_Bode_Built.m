clear all

%% Initialize Time Series
L = 20;
time_range = logspace(log10(90),log10(3600),L);
mult = round(time_range/45);
time_range = 45*mult;
freq_range = time_range.^-1;

% Create time courses
tmax = 200*15;
inc  = 201;
time = linspace(0,tmax,inc);
dc = 1/3;
t_on = time_range*dc;

% DOX Titration
DOX_stor = [];
for j=1:L
    A = [];
    for i=1:100
        A = [A ones(1,t_on(j)/15) zeros(1,t_on(j)*2/15)];
    end
    DOX_stor(j,:) = A(1:inc);
end
clear A
clear i
clear j

% % Plot DOX titration
% figure, imagesc(DOX_stor)


%% Load Kinetic Parameters

load KineticFits2/181208_Fit6_5.mat kdeg_GFP kdeg_TF1 kdeg_TF2 ...
	T1hi T1_fold T1low T2low k1 kb_gabor kb_cyc1_2n k2_3N k3

k2_4n = k2_3N;      % 2nd node production rate with 4 operators (from fit)
k3_4n = k3;         % 3nd node production rate with 4 operators (from fit)

clear k2_3N k3

%% Load Thermodynamic Model and Parameter Space

load ThermoModel/181119_CFFL_Type1.mat params params_meas ...
    ind1_stor ind2_stor

load ThermoModel/181119_43_8_interp.mat func_stor
func1_stor = func_stor;
clear func_stor

load ThermoModel/181119_2in_interp.mat func_stor
func2_stor = func_stor;
clear func_stor


%% Parameter Index
ind = find((params_meas(1,:)==0.224)&(params_meas(2,:)==1.97)&(params_meas(3,:)==4)&...
        (params_meas(4,:)==0.143)&(params_meas(5,:)==1.97)&(params_meas(6,:)==0.015)&...
        (params_meas(7,:)==1.97)&(params_meas(8,:)==2)&(params_meas(9,:)==2))


%% RUN TCs

% Run through parameters
i=ind

    % Thermo Model
    func1 = func1_stor{ind1_stor(i)};
    func2 = func2_stor{ind2_stor(i)};
    
    % Rate Scaling based on number of operators
    n  = params(3,i);
    k2 = scaling(k2_4n,4,n);
    k3 = scaling(k3_4n,4,n);

    % Calculate B-Node Parameters
    Therm1Low = func1(T1low*10^-6);
    kb_cyc1_3N = kdeg_TF2*T2low;
    T2low_start = (kb_cyc1_3N + k2*Therm1Low)/kdeg_TF2;

    % Calculate C-Node Parameters
    Therm2Low = func2(T1low*10^-6,T2low_start*10^-6);
    kb_cyc2_3N = kdeg_GFP*100;
    basal = (kb_cyc2_3N + k3*Therm2Low)/kdeg_GFP;      
    
    % Storage vectors
    stor_GFP = zeros(inc,L);
    GFP_temp = zeros(inc,1);
    gain_stor = zeros(L,1);
    TF2_temp = zeros(L,1);
    
    tic
    for j=1:L
        % DOX
        DOX = DOX_stor(j,:);

        % Run ODEs
        initialC = [T1low, T2low_start, basal];
        [T,X] = ode23s(@(t,y)CFFL_Type1(t,y,time,DOX,k1,k2,k3,kdeg_TF1,kdeg_TF2,kdeg_GFP,kb_gabor,kb_cyc1_3N,kb_cyc2_3N,func1,func2), time, initialC);
        
        % Store GFP trace and max GFP
        GFP_temp = X(:,3);
        stor_GFP(:,j) = GFP_temp;
        gain_stor(j) = max(GFP_temp);
        TF2_temp(j) = max(X(:,2));
    end
    toc
    
	tElapsed(i) = toc;
       
    

%% Plot BODE (S23) - hr-1
figure
semilogx(freq_range*60,gain_stor/max(gain_stor))
set(gca,'FontSize',24)
xlim([min(freq_range*60) max(freq_range*60)])
ylim([0 1.1])
saveas(gcf,['Figures/S23_Bode_Low_pass_hr'],'pdf')


%% Extra

params_meas(:,ind)

gain_stor_norm = gain_stor/max(gain_stor);
[min(gain_stor_norm) gain_stor_norm(1)]