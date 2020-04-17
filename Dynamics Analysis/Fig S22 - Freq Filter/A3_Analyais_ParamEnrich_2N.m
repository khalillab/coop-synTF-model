clear all, close all

%% Load Data

load 181209_Freq_2Node.mat; OutputName = '2N';

params = params_meas;
filter_cutoff = 0.2;        % Cutoff for 'good' freq filter

remove_nonclamped = find((params_meas(2,:)~=0));
params_meas = params_meas(:,remove_nonclamped);


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

% Good filters
ind_good = find((gain_norm(end,:)==1)&(gain_norm(1,:)<filter_cutoff));
perc_good = length(ind_good)/length(params)


%% Plot Parameter Enrichment
% Colors for plots
colors = [[32 120 184]; ...     % Kt1
    [230 47 45]; ...            % Kp1
    [70 70 70]]/255;            % n1


x = params(:,ind_good);
ranges = {};
for i=1:3
    tab = tabulate(params_meas(i,:));
    ranges{i} = tab(:,1);
end


figure
% Kt,Kp
for i=[1:2]
    
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


% n
for i=[3]
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

%% Save Image
r = 150; % pixels per inch
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 1050 200]/r);
print(gcf,'-dpdf',sprintf('-r%d',r), ['Figures/ParamEnrich_Freq_' OutputName '.pdf']);