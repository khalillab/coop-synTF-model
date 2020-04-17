clear all

% Matlab R2016b
% Interpolate 2 input surfaces generated by thermodynamic model

%% Initialize
OutputName = '181119_2in_interp';

load 2D_Surfaces/181119_2in_thermo_all.mat params params_meas ...
        surf_stor  TF1range TF2range

% TF Range
L = 50;         % Number of elements along surface
Input = combvec(TF1range,TF2range);
TF1 = Input(1,:)';
TF2 = Input(2,:)';

% Reshape into a grid matrix
TF1 = reshape(TF1, [L L]);
TF2 = reshape(TF2, [L L]);

% Storage Vector
out_stor = cell(1,length(params));
poly_stor = cell(1,length(params));
func_stor = cell(1,length(params));

%% 2D interpolation of thermodynamic outputs

for i=1:length(params)
    
    % Reshape output
    Output = reshape(surf_stor(:,i),[L L]);
    
    % 2D Interpolate
    F = griddedInterpolant(TF1,TF2,Output,'linear');
    
    % Store function
    func_stor{i} = F;
    
    % Store output
    out_stor{i} = Output;
    
    % Evaluate Interpolant
    poly_stor{i} = F(TF1,TF2);

end


%% Plot an example surface and its interpollated version

L = 500;
TF1range = logspace(-3,-1,L);
TF2range = logspace(-5,-3,L);
Input = combvec(TF1range,TF2range);
TF1 = Input(1,:)';
TF2 = Input(2,:)';
TF1 = reshape(TF1, [L L]);
TF2 = reshape(TF2, [L L]);

i = 1;
F = func_stor{i}

figure
    subplot(1,2,1)
    imagesc(log10(out_stor{i}))
    subplot(1,2,2)
    imagesc(log10(F(TF1,TF2)))


%% Save Data
OutputName = [OutputName '.mat'];
save(OutputName,'params','func_stor','params_meas')