clear all, close all

%% Load Data

load 181209_Freq_CFFL_FB2.mat; OutputName = 'CFFL_FB2';

params_meas(13,:) = params_meas(11,:)+params_meas(12,:);
params = params_meas;
bd_threshold = 2;           % Threshold for 'good' band stop filter

%% Screen and find good low pass filters

% Initialize
gain_norm = zeros(size(gain_stor));
gain_temp = [];

% Normalize Gain
for i=1:length(params)
    gain_temp = gain_stor(:,i);
    gain_norm(:,i) = gain_temp/max(gain_temp);
end

% Screen for Filters

% Prescreen
ind_screen = find(gain_stor(end,:)>1000);
gain_stor = gain_stor(:,ind_screen);
gain_norm = gain_norm(:,ind_screen);
params = params(:,ind_screen);

% Good band-stop filter
ind_bd = [];
for i=1:length(params)
    if gain_norm(1,i)>bd_threshold*min(gain_norm(:,i))
        ind_bd = [ind_bd i];
    end
end
perc_bd = length(ind_bd)/length(params)


%% Plot Parameter Enrichment
% Colors for plots
colors = [[32 120 184]; ...     % Kt1
    [230 47 45]; ...            % Kp1
    [105 54 142]; ...           % Kt2
    [230 47 45]; ...            % Kp2
    [70 70 70]; ...             % n1
    [70 70 70]; ...             % n2
    [32 120 184]; ...           % Kt3
    [230 47 45]; ...            % Kp1
    [105 54 142]; ...           % Kt4
    [230 47 45]; ...            % Kp2
    [70 70 70]; ...             % n3
    [70 70 70]; ...             % n4
    [70 70 70]]/255;            % n_tot


x = params(:,ind_bd);

ranges = {};
for i=1:13
    tab = tabulate(params_meas(i,:));
    ranges{i} = tab(:,1);
end

figure
for i=[1:4,7:10]
    
    fullrange = ranges{i};
    fullrange(:,2) = zeros(size(fullrange));
    
    subplot(2,6,i)
    
    % Get percentage of each parameters
    tab = tabulate(x(i,:));
    for j=1:length(tab(:,1))
        ind = find(fullrange(:,1)==tab(j,1));
        fullrange(ind,2) = tab(j,3)/100;
    end
    
    % Plot
    polygon_x = [min(fullrange(:,1)); fullrange(:,1); max(fullrange(:,1))];
    polygon_y = [0; fullrange(:,2); 0];
    patch(polygon_x,polygon_y,colors(i,:),'FaceAlpha',0.4); hold on
    
    semilogx(fullrange(:,1),fullrange(:,2),'-','Color',colors(i,:),'LineWidth',1.75)
    set(gca,'XScale','log')
    ylim([0 1])
    xlim([min(fullrange(:,1)),max(fullrange(:,1))])
    
end


for i=[5:6,11:12]
    fullrange = ranges{i};
    fullrange(:,2) = zeros(size(fullrange));
    
    subplot(2,6,i)
    
    % Get percentage of each parameters
    tab = tabulate(x(i,:));
    for j=1:length(tab(:,1))
        ind = find(fullrange(:,1)==tab(j,1));
        fullrange(ind,2) = tab(j,3)/100;
    end

    % Plot
    polygon_x = [min(fullrange(:,1)); fullrange(:,1); max(fullrange(:,1))];
    polygon_y = [0; fullrange(:,2); 0];
    patch(polygon_x,polygon_y,colors(i,:),'FaceAlpha',0.4); hold on
    
    plot(fullrange(:,1),fullrange(:,2),'-','Color',colors(i,:),'LineWidth',1.75)
    ylim([0 1])
    xlim([min(fullrange(:,1)),max(fullrange(:,1))])

end


% Save Image
r = 150; % pixels per inch
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 1050 200]/r);
print(gcf,'-dpdf',sprintf('-r%d',r), ['Figures/ParamEnrich_Freq_' OutputName '.pdf']);




figure
for i=[13]
    fullrange = ranges{i};
    fullrange(:,2) = zeros(size(fullrange));
    
    subplot(2,6,1)
    
    % Get percentage of each parameters
    tab = tabulate(x(i,:));
    for j=1:length(tab(:,1))
        ind = find(fullrange(:,1)==tab(j,1));
        fullrange(ind,2) = tab(j,3)/100;
    end

    % Plot
    polygon_x = [min(fullrange(:,1)); fullrange(:,1); max(fullrange(:,1))];
    polygon_y = [0; fullrange(:,2); 0];
    patch(polygon_x,polygon_y,colors(i,:),'FaceAlpha',0.4); hold on
    
    plot(fullrange(:,1),fullrange(:,2),'-','Color',colors(i,:),'LineWidth',1.75)
    ylim([0 1])
    xlim([min(fullrange(:,1)),max(fullrange(:,1))])

end

% Save Image
r = 150; % pixels per inch
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 1050 200]/r);
print(gcf,'-dpdf',sprintf('-r%d',r), ['Figures/ParamEnrich_Freq_' OutputName '_ntot.pdf']);