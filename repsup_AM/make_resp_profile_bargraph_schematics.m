 %%% create schematic bargraphs illustrating the possible syl-2 response magnitude relationships across the 3 trial conditions
 % schematics partly modeled after fig 2 from Peeva et al. 2010 - doi.org/10.1016/j.neuroimage.2009.12.065
 %
 % AM 

% barcolors = [0.3, 0.3, 0.3] * [1; 1; 1]; 
barcolors = [0.8, 0.5, 0.2] .* [1; 1; 1]; % different shades of gray

barlinewidth = 2; 
xticklocs = [0.2 2 3.6];
xticklab_angle = 60; 

% cons = {'IDEN-FLIP','IDEN-DIF','FLIP-DIF'}; 
cons = {'I-F','I-D','F-D'}; 
% cons = {'IDEN','FLIP','DIF'}; % behavioral conditions

% leglabs = {'IDEN-FLIP','IDEN-DIF','FLIP-DIF'}; 

mags = [-1 0 1]; 
% mags = [1 2 3]; % syllable 2 response magnitudes

ncons = length(cons); 
nmags = length(mags); 

mag_combos = generate_combinations(1:ncons, mags);
ncombos = length(mag_combos);



%% make plot

close all

% Get screen size
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

% Calculate figure size
figureWidth = screenWidth;
figureHeight = 0.08 * figureWidth;

% Create figure with specified dimensions
hfig = figure('Position', [0, 50, figureWidth, figureHeight], 'Color','w');

% Create tiled layout
tiledlayout(1, ncombos, 'Padding','compact');

% Plot each combination
for icombo = 1:ncombos
    nexttile;

    hbar = bar(mag_combos(icombo,:), 'FaceColor','flat');
        % hbar.FaceColor = barcolor;
        hbar.LineWidth = barlinewidth; 
        hbar.BarWidth = 1; 
        hbar.CData = barcolors'; 

    ylim(1.2 * [min(mags), max(mags)])

    hax = gca;
        hax.XTickLabels = cons; 
        hax.YTick = [];
        hax.XTick = xticklocs;
        hax.XTickLabelRotation = xticklab_angle; 

    % for ibar = 1:ncons
    %     hax.Children(ibar).FaceColor = barcolors(ibar,:)'
    % end

    box off

    if icombo == 1
        hax.YTick = 0;
        hylab = ylabel({'Syllable 2 HG', 'resp. magnitude'});
    end
end

% hleg = legend(leglabs);




%%
function combinations = generate_combinations(slots, magnitudes)
    num_slots = numel(slots);
    num_magnitudes = numel(magnitudes);
    total_combinations = num_magnitudes ^ num_slots;
    
    combinations = zeros(total_combinations, num_slots);
    
    for i = 1:total_combinations
        temp = dec2base(i - 1, num_magnitudes, num_slots) - '0' + 1;
        combinations(i, :) = magnitudes(temp);
    end
end


