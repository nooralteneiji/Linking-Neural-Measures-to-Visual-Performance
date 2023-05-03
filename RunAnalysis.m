%% RunAnalysisRunAnalysis
% Start from scratch
% Specify current working directory
% Organize Figures folder
% Load Data
% Sanitize data
% Set figure defaults
% Normal values
% Limits and normal values for each measure
% DESCRIPTIVE PLOTS (histograms)
% SCATTER PLOTS: comparison right vs left
% SCATTER PLOTS: comparison of visual performance measures
% BAR GRAPHS: Without grouping
% BAR GRAPHS: Grouped by eye dominance
% BAR GRAPHS: Grouped by sex
%% Start from scratch
clear all;
close all;
clc
%% Specify current working directory
% % This will be were the figure files will be saved
project_dir = pwd;
dir_name = [project_dir '/..'];
cd(dir_name); % Change the current working directory to the selected directory

%% Organize Figures folder
% Create a folder named 'Histograms' if it doesn't exist
if ~exist('Figures', 'dir')
    mkdir('Figures')
end

% Create a folder named 'Histograms' if it doesn't exist
if ~exist(fullfile('Figures','Histograms'), 'dir')
    mkdir(fullfile('Figures','Histograms'))
end

% Create a folder named 'Correlational Plots' if it doesn't exist
if ~exist(fullfile('Figures','Correlational Plots'), 'dir')
    mkdir(fullfile('Figures','Correlational Plots'))
end

% Create a folder named 'Bar Graphs' if it doesn't exist
if ~exist(fullfile('Figures','Bar Graphs'), 'dir')
    mkdir(fullfile('Figures','Bar Graphs'))
end
%% Load Data
% reads directly from google sheets (will only work if 'anyone with link' is set to 'view')
ID = '1dzEIaKoYs6FmS1TfqDSf8FjZr8UDgBM3rPh10xk2OAQ';
sheet_name = 'Data';
url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',ID, sheet_name);
data = webread(url_name);

%% Sanitize data
% If subject does not wear glasses (glasses=0), then take the uncorrected acuity value as the corrected acuity
glassesIdx = data.Glasses == 0; % get the indices of the rows where glasses = 0
data(glassesIdx, 'LeftETDRSCorrected') = data(glassesIdx, 'LeftETDRSUncorrected'); % copy values from LeftETDRSUncorrected
data(glassesIdx, 'RightETDRSCorrected') = data(glassesIdx, 'RightETDRSUncorrected'); % copy values from LeftETDRSUncorrected

% take only subjects with clean data (remove rows where clean = 0). Clean
% means that measurement does not need to be recollected
data = data(data.clean(:)==1,:);

% only the first 39 subjects have perimetry data, so create a version of
% perimetry data without NaN values 
leftPerimetry = data.LeftPerimetry;
rightPerimetry = data.RightPerimetry;
nan_idx = isnan(leftPerimetry) | isnan(rightPerimetry);
leftPerimetry(nan_idx) = []; % remove NaN values
rightPerimetry(nan_idx) = []; % remove NaN values

num_perimetry_subj = sum(~isnan(data.LeftPerimetry));% count number of subjects w/o NaN perimetry data
%% Set figure defaults
set(groot, 'defaultAxesLineWidth', 1)
set(groot, 'defaultLineLineWidth', 2);

set(groot, 'defaultBarLineWidth', 1);

set(groot, 'defaultConstantLineLineWidth', 1);
set(groot, 'defaultConstantLineFontSize', 16);

% set(groot, 'DefaultScatterMarkerSize', 24);

set(groot,'defaultLineMarker','o')
set(groot,'defaultLineMarkerSize',16)
set(groot,'defaultLineMarkerEdgeColor','w')

set(groot, 'defaultAxesFontSize',16)
set(groot, 'defaultAxesTickDir', 'out');
set(groot, 'defaultAxesTickDirMode', 'manual');

DefaultMarkerSize = 192;
DefaultMarkerLineWidth = 2;

blue = [0, 0.4470, 0.7410];
red = [0.85,0.33,0.10]; %[0.6350, 0.0780, 0.1840];

alpha = 0.4; % marker face transparency

%% Normative values
% Visual acuity
% Uncorrected
% Best Corrected Visual Acuity
% Contrast sensitivy
% normal contrast sensitivity (~1.8 across age-groups) from

% https://www.sciencedirect.com/science/article/pii/S0886335000005629
% for 20-29 yr olds
% both eyes at 1m, normal = 1.96 ± 0.05

%https://www.researchgate.net/figure/Pelli-Robson-test-measures-contrast-sensitivity-using-a-single-large-letter-size-20-60_fig2_260131039
% >2 score = poor cs
% 1.5 = visual impairment
% 1 = Disability

% Stereoacuity
% 20-60 = Fine
% 75-200 = moderate
% 400 = coarse/nil
% https://www.sciencedirect.com/science/article/pii/S0002939406005769

% Perimetry
%% Limits and normal values for each measure

% Values where you can actually obtain a score for
VA_tickpositions = [-0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1];
VA_ticklabels = {'-0.3', '-0.2', '-0.1', '0', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0', '1.1'};

contrast_tickpositions = [0.15, 0.30, 0.45, 0.60, 0.75, 0.90, 1.05, 1.20, 1.35, 1.50, 1.65, 1.80, 1.95, 2.10, 2.25];
contrast_ticklabels = {'0.15', '0.30', '0.45', '0.60', '0.75', '0.90', '1.05', '1.20', '1.35', '1.50','1.65', '1.80', '1.95', '2.10', '2.25'};

% stereoacuity_tickpositions = [20, 25, 30, 40, 60, 70, 100, 140, 200, 400];
% stereoacuity_ticklabels = {'20', '25', '30', '40', '60', '70', '100', '140', '200', '400'};

stereoacuity_tickpositions = log10([20, 25, 30, 40, 50, 70, 100, 140, 200, 400]);
% stereoactuiy_ticklabels = {'0', '1', '2', '3', '4', '5', '6'};
stereoacuity_ticklabels = {'20', '25', '30', '40', '50', '70', '100', '140', '200', '400'};

perimetry_tickpositions = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
perimetry_ticklabels = {'0.1', '0.2','0.3','0.4','0.5', '0.6', '0.7', '0.8', '0.9','1'};

% labels
UVA_label = {'Uncorrected Visual Acuity (logMAR)'};
BCVA_label = {'Best Corrected Visual Acuity (logMAR)'};
contrast_label = {'Contrast Sensitivity (logCS)'};
stereo_label = {'Stereoacuity (arcsec)'};
perimetry_label = {'Perimetry Score'};

% Normative values
VA_normal = 0;
VA_disability = 1;
contrast_normal = 2;
contrast_impairment = 1.5;
contrast_disability = 1;
stereo_normal = log10(60);
stereo_disability = log10(400);
perimetry_normal = 1;
perimetry_disability = 0.6;

VA_normal_label = {'20/20 Vision'};
VA_disability_label = {'20/200 - Legally Blind'};
contrast_normal_label = {'Normal'};
contrast_impairment_label = {'Impairment'};
contrast_disability_label = {'Disability'};
stereo_normal_label = {'Fine'};
stereo_disability_label = {'Coarse'};
perimetry_normal_label = {'Normal'};
perimetry_disability_label = {'Disability (placeholder)'};

% Limits of scores
VA_lim = [-0.3 1.1];
CS_lim = [1 2.25];
Stereo_lim = [0 6];
perimetry_lim = [0 1];

%% DESCRIPTIVE PLOTS (histograms)
% Define the cases to run
cases = ["uncorrected visual acuity", "corrected visual acuity", "contrast sensitivity", "stereoacuity", "perimetry"];
stats_tables = cell(length(cases), 1); % we will compute the stats for each case and store it here.

for case_idx = 1:length(cases)
    % Set the visual acuity data to plot (uncorrected or corrected)
    data_selected = cases(case_idx);

    % Select the appropriate data based on the case
    switch data_selected
        case "uncorrected visual acuity"
            vm = [data.LeftETDRSUncorrected data.RightETDRSUncorrected];
            binrng = -0.5:.1:1.3;
            title_str = "Distribution of Uncorrected Visual Acuity for Individual Eyes";

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
        case "corrected visual acuity"
            vm = [data.RightETDRSCorrected data.LeftETDRSCorrected];
            binrng = -0.5:.1:1.3;
            title_str = "Distribution of Best Corrected Visual Acuity for Individual Eyes";

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
        case "contrast sensitivity"
            clear counts binrng
            vm = [data.LeftPELLIR_N data.RightPELLIR_N];
            binrng =  0:0.15:2.25;
            title_str = "Distribution of Contrast Sensitivity For Individual Eyes";

            xtickpositions = contrast_tickpositions;
            xticklabels = contrast_ticklabels;
        case "perimetry"
            clear counts binrng
            vm = [data.LeftPerimetry data.RightPerimetry];
            nbins = 10;
            binrng = linspace(min(vm(:)),max(vm(:)), nbins);
            title_str = "Distribution of Perimetry Scores";

            xtickpositions = perimetry_tickpositions;
            xticklabels = perimetry_ticklabels;
    end

    % Loop through each eye and compute the histogram counts (whole script needs to be run ortherwise this line will show error)
    for k = 1:size(vm,2)
        counts(k,:) = histc(vm(:,k), binrng);
    end

    % compute stats
    % Compute the mean, median, and standard deviation of the distribution
    % Compute the mean, median, and standard deviation of the distribution
    mean_val = nanmean(vm(:));
    median_val = nanmedian(vm(:));
    std_val = nanstd(vm(:));
    
    % Compute the skewness and kurtosis of the distribution
    skew_val = skewness(vm(~isnan(vm)));
    kurt_val = kurtosis(vm(~isnan(vm)));
    
    % Create a table to summarize the statistics
    stats_table = table(mean_val, median_val, std_val, skew_val, kurt_val);
    stats_tables{case_idx} = stats_table;

    % Plot the histogram
    figure('Position', [100 100 850 650],'Visible','off'); hold on

    set(gca, 'XTick', xtickpositions, 'XTickLabel', xticklabels);

    % style plots based on the case
    switch data_selected
        case "contrast sensitivity"
            xline(contrast_normal,'--',contrast_normal_label,'HandleVisibility','off');
            xline(contrast_disability,'--',contrast_disability_label,'HandleVisibility','off');
            xlabel('Contrast Sensitivity (logCS)')
            ylabel('Count of Eyes')
            ylim([0 144])
        case "uncorrected visual acuity"
            xline(VA_normal,'--',VA_normal_label, 'HandleVisibility','off');
            xline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            set(gca, 'XDir','reverse') % Negative LogMAR values are better
            xlabel('Visual Acuity (logMAR)');
            ylim([0 55]);
        case "corrected visual acuity"
            xline(VA_normal,'--',VA_normal_label, 'HandleVisibility','off');
            xline(VA_disability ,'--',VA_disability_label, 'HandleVisibility','off');
            set(gca, 'XDir','reverse') % Negative LogMAR values are better
            xlabel('Visual Acuity (logMAR)');
            ylim([0 55]);
        case "perimetry"
            xline(perimetry_normal,'--',perimetry_normal_label, 'HandleVisibility','off');
            xline(perimetry_disability,'--',perimetry_disability_label ,'HandleVisibility','off');
            xlabel('Perimetry')
            ylabel('Count of Eyes')
            ylim([0 75])
    end

    get(groot);
    bar(binrng,counts,'stacked','BarWidth',0.9);

    title(title_str);
    ylabel('Count of Eyes');

    % legend('Left Eye','Right Eye');

    % save to histograms folder
    print(fullfile('Figures/Histograms', title_str), '-dpdf');
    print(fullfile('Figures/Histograms', title_str), '-dpng');

    % savefig(fullfile('Figures/Histograms', title_str));
end

% Stereoacuity Histogram
clear counts binrng
vm = log10([data.Randot]);
nbins = 10;
binrng = linspace(min(vm(:)),max(vm(:)), nbins);
title_str = "Distribution of Stereoacuity";
xtickpositions = stereoacuity_tickpositions;
xticklabels = stereoacuity_ticklabels;

% Loop through each eye and compute the histogram counts
for k = 1:size(vm,2)
    counts(k,:) = histc(vm(:,k), binrng);
end

% Plot the histogram
figure('Position', [100 100 650 550],'Visible','off'); hold on

set(gca, 'XTick', xtickpositions, 'XTickLabel', xticklabels);

bar(binrng,counts,'stacked');

xlabel('Stereoacuity (arcsec)')
ylabel('Count of Eyes')

xline(stereo_normal,'--',stereo_normal_label,'HandleVisibility','off') % normal contrast sensitivity
xline(stereo_disability,'--',stereo_disability_label,'HandleVisibility','off');
ylim([0 75])

set(gca, 'XDir','reverse') % smaller LogSEC values are better

print(fullfile('Figures/Histograms', title_str), '-dpdf');
print(fullfile('Figures/Histograms', title_str), '-dpng');

%savefig(fullfile('Figures/Histograms', title_str));

% compute stats
% Compute the mean, median, and standard deviation of the distribution
mean_val = mean(vm(:));
median_val = median(vm(:));
std_val = std(vm(:));

% Compute the mode of the distribution
[~, mode_val] = max(counts(:));
mode_val = binrng(mode_val);

% Compute the skewness and kurtosis of the distribution
skew_val = skewness(vm(:));
kurt_val = kurtosis(vm(:));

% Create a table to summarize the statistics
stereo_stats_table = table(mean_val, median_val, std_val, mode_val, skew_val, kurt_val);


%% SCATTER PLOTS: comparison right vs left
clear cases case_idx
cases = ["left right uncorrected visual acuity", "left right best corrected visual acuity", "left right contrast sensitivity", "left right perimetry"];

for case_idx = 1:length(cases)
    % Set the visual acuity data to plot (uncorrected or corrected)
    data_selected = cases(case_idx);

    % Select the appropriate data based on the case
    switch data_selected
        case "left right uncorrected visual acuity"
            title_str = "Relationship Between Right and Left Eye Uncorrected Visual Acuity";
            x = data.LeftETDRSUncorrected;
            y = data.RightETDRSUncorrected;

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
            ytickpositions = VA_tickpositions;
            yticklabels = VA_ticklabels;
        case "left right best corrected visual acuity"
            title_str = "Relationship Between Right and Left Eye Best Corrected Visual Acuity";            
            x = data.LeftETDRSCorrected;
            y = data.RightETDRSCorrected;

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
            ytickpositions = VA_tickpositions;
            yticklabels = VA_ticklabels;
        case "left right contrast sensitivity"
            x = data.LeftPELLIR_N;
            y = data.RightPELLIR_N;
            title_str = "Relationship Between Right and Left Eye Contrast Sensitivity";            

            xtickpositions = contrast_tickpositions;
            xticklabels = contrast_ticklabels;
            ytickpositions = contrast_tickpositions;
            yticklabels = contrast_ticklabels;
        case "left right perimetry"
            x = data.LeftPerimetry;
            y = data.RightPerimetry;
            title_str = "Relationship Between Right and Left Eye Perimetry Score";            
    end

    nan_idx = isnan(x) | isnan(y);
    x(nan_idx) = []; % remove NaN values
    y(nan_idx) = []; % remove NaN values

    [r, p] = corrcoef(x(:), y(:));
    r_squared = r(1,2);
    p_value = p(1,2);

    text_str = sprintf('R = %.3f\np-value = %.3f', r_squared, p_value);

    figure('Position', [100 100 650 650],'Visible','off'); hold on % plot

    % Fit a linear regression line to the data
    x = x;
    y = y;
    coeff = polyfit(x, y, 1);
    y_fit = polyval(coeff, x);
    hold on;
    plot(x, y_fit, 'DisplayName', 'Trend Line','color', red);

    % style plots based on the case
    switch data_selected
        case "left right uncorrected visual acuity"
            x1(1)=xline(VA_normal,'--',VA_normal_label,'HandleVisibility','off'); % normal acuity (20/20)
            x1(2)=xline(VA_disability,'--',VA_disability_label,'HandleVisibility','off');
            x1(3)=yline(VA_normal,'--',VA_normal_label,'HandleVisibility','off'); % normal acuity (20/20)
            x1(4)=yline(VA_disability,'--',VA_disability_label,'HandleVisibility','off');

            x1(1).LabelVerticalAlignment='middle';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='middle';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='center';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='center';

            xlim([-0.45 1.1])
            ylim([-0.3 1.1])

            annotation_position = [0.7, 0.1, 0.2, 0.1];

            set(gca, 'XDir','reverse') % Negative LogMAR values are better
            set(gca, 'yDir','reverse') % Negative LogMAR values are better
            xlabel('Left Eye (logMAR)')
            ylabel('Right Eye (logMAR)')

        case "left right best corrected visual acuity"
            x1(1)=xline(VA_normal,'--',VA_normal_label,'HandleVisibility','off'); % normal acuity (20/20)
            x1(2)=xline(VA_disability,'--',VA_disability_label,'HandleVisibility','off');
            x1(3)=yline(VA_normal,'--',VA_normal_label,'HandleVisibility','off'); % normal acuity (20/20)
            x1(4)=yline(VA_disability,'--',VA_disability_label,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='middle';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='middle';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='center';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='center';

            annotation_position = [0.7, 0.1, 0.2, 0.1];
            xlim([-0.4 1.04])
            ylim([-0.3 1.05])

            set(gca, 'XDir','reverse') % Negative LogMAR values are better
            set(gca, 'yDir','reverse') % Negative LogMAR values are better

            xlabel('Left Eye (logMAR)')
            ylabel('Right Eye (logMAR)')

        case "left right contrast sensitivity"
            x1(1)=xline(contrast_normal,'--',contrast_normal_label,'HandleVisibility','off');
            x1(2)=xline(contrast_impairment,'--',contrast_impairment_label,'HandleVisibility','off');
            x1(3)=yline(contrast_normal,'--',contrast_normal_label,'HandleVisibility','off');
            x1(4)=yline(contrast_impairment,'--',contrast_impairment_label,'HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='bottom';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='left';

            annotation_position = [0.68, 0.1, 0.2, 0.1];

            xlim([1.46 2])
            ylim([1.55 2.12])
            xlabel('Left Eye (logCS)')
            ylabel('Right Eye (logCS)')

         case "left right perimetry"
            annotation_position = [0.68, 0.1, 0.2, 0.1];
            xlabel('Left Eye Perimetry Score')
            ylabel('Right Eye Perimetry Score')



    end

    get(groot); % add default style

    scatter(x, y, DefaultMarkerSize, 'LineWidth', DefaultMarkerLineWidth,'MarkerFaceColor', blue,'MarkerEdgeColor', [1 1 1], 'MarkerFaceAlpha', alpha);

    title(title_str);

    annotation('textbox', annotation_position, 'String', text_str, 'FitBoxToText', 'on', 'BackgroundColor', 'w', FontSize=16, FaceAlpha=0.5);

    % save
    print(fullfile('Figures/Correlational Plots/', title_str), '-dpdf');
end
%% SCATTER PLOTS: comparison of stereoacuity vs absolute difference in acuity 
% absolute difference 
absDifference_UVA= abs(data.RightETDRSUncorrected - data.LeftETDRSUncorrected);
absDifference_BCVA= abs(data.RightETDRSCorrected - data.LeftETDRSCorrected);

cases = [ "stereoacuity vs uncorrected acuity difference", "stereoacuity vs corrected acuity difference" 
    ]; 

for case_idx = 1:length(cases)
    data_selected = cases(case_idx); % set the pairs of measures to plot
    switch data_selected % select the appropriate pairs of data based on the case
        case "stereoacuity vs uncorrected acuity difference"
            title_str = sprintf('Stereoacuity as a Function of \nDifference in Uncorrected Visual Acuity');
            x = absDifference_UVA;
            y = log10([data.Randot]);

%             xtickpositions = VA_tickpositions;
%             xticklabels = VA_ticklabels;
            ytickpositions = stereoacuity_tickpositions;
            yticklabels = stereoacuity_ticklabels;

        case "stereoacuity vs corrected acuity difference"
            title_str = sprintf('Stereoacuity as a Function of \nDifference in Best Corrected Visual Acuity');
            x = absDifference_BCVA;
            y = log10([data.Randot]);

%             xtickpositions = VA_tickpositions;
%             xticklabels = VA_ticklabels;
            ytickpositions = stereoacuity_tickpositions;
            yticklabels = stereoacuity_ticklabels;
    end 

    [r, p] = corrcoef(x(:), y(:));
    r_squared = r(1,2);
    p_value = p(1,2);
    
    text_str = sprintf('R = %.3f\np-value = %.3f', r_squared, p_value);

    % plot the scatter
    figure('Position', [100 100 650 650],'Visible','off');
    hold on;

    get(groot);
    hold on;

    % scatter(x, y,'SizeData',DefaultMarkerSize, 'LineWidth', DefaultMarkerLineWidth);

    s = scatter(x, y, DefaultMarkerSize, 'LineWidth', DefaultMarkerLineWidth, 'MarkerEdgeColor', [1 1 1], 'MarkerFaceAlpha', alpha);
    s.MarkerFaceColor = blue;   % assign the first color to the first data point

    % Fit a trendline
    coeff = polyfit(x(:), y(:), 1);
    y_fit = polyval(coeff, x(:));
    hold on;
    plot(x(:), y_fit, 'DisplayName', 'Trend Line', 'color', red);

    set(gca, 'YTick', ytickpositions, 'YTickLabel', yticklabels);
    set(gca, 'XTick', xtickpositions, 'XTickLabel', xticklabels);

    switch data_selected % lets style 
            case "stereoacuity vs uncorrected acuity difference"
            xlabel(UVA_label);
            ylabel(stereo_label);
            set(gca, 'YDir','reverse') % smaller stereoacuity scores are better

            annotation_position =     [0.7, 0.1, 0.089, 0.1];
            xlim([0 0.7])
            ylim(log10([15 425]))

        case "stereoacuity vs corrected acuity difference"
            xlabel(UVA_label);
            ylabel(stereo_label);
            set(gca, 'YDir','reverse') % smaller stereoacuity scores are better

            annotation_position = [0.7, 0.1, 0.089, 0.1];
            xlim([0 0.7])
            ylim(log10([15 425]))
    end 

    annotation('textbox', annotation_position, 'String', text_str, 'FitBoxToText', 'on', 'BackgroundColor', 'w', FontSize=16, FaceAlpha=0.5);

    title(title_str);
    %legend('Left Eye','Right Eye')

    % save to correlational plots folder
    print(fullfile('Figures/Correlational Plots/', title_str), '-dpdf');

end

%% SCATTER PLOTS: comparison of visual performance measures

clear cases case_idx data_selected plot_text
cases = [
    "contrast vs uncorrected visual acuity", "stereoacuity vs uncorrected visual acuity", "perimetry vs uncorrected visual acuity",...
    "contrast vs best corrected visual acuity", "stereoacuity vs best corrected visual acuity", "perimetry vs best corrected visual acuity",...
    "perimetry vs contrast sensitivity", "stereoacuity vs contrast sensitivity",...
    "stereoacuity vs perimetry"];
for case_idx = 1:length(cases)
    data_selected = cases(case_idx); % set the pairs of measures to plot
    switch data_selected % select the appropriate pairs of data based on the case
        % visual performance as a function of uncorrected visual acuity
        case "contrast vs uncorrected visual acuity"
            title_str = "Contrast senstivity as a Function of Uncorrected Visual Acuity";
            x = [data.LeftETDRSUncorrected data.RightETDRSUncorrected];
            y = [data.LeftPELLIR_N data.RightPELLIR_N];

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
            ytickpositions = contrast_tickpositions;
            yticklabels = contrast_ticklabels;
        case "stereoacuity vs uncorrected visual acuity"
            title_str = "Stereoacuity as a Function of Uncorrected Visual Acuity";
            x = [data.LeftETDRSUncorrected data.RightETDRSUncorrected];
            y = log10([data.Randot data.Randot]);

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
            ytickpositions = stereoacuity_tickpositions;
            yticklabels = stereoacuity_ticklabels;
        case "perimetry vs uncorrected visual acuity"
            title_str = "Perimetry Scores as a Function of Uncorrected Visual Acuity";
            x = [data.LeftETDRSUncorrected(1:num_perimetry_subj) data.RightETDRSUncorrected(1:num_perimetry_subj)];
            y = [leftPerimetry rightPerimetry];

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
            ytickpositions = perimetry_tickpositions;
            yticklabels = perimetry_ticklabels;
            % visual performance as a function of best corrected visual acuity
        case "contrast vs best corrected visual acuity"
            title_str = "Contrast Sensitivity as a Function of Best Corrected Visual Acuity";
            x = [data.LeftETDRSCorrected data.RightETDRSCorrected];
            y = [data.LeftPELLIR_N data.RightPELLIR_N];

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
            ytickpositions = contrast_tickpositions;
            yticklabels = contrast_ticklabels;
        case "stereoacuity vs best corrected visual acuity"
            title_str = "Stereoacuity as a Function of Best Corrected Visual Acuity";
            x = [data.LeftETDRSCorrected data.RightETDRSCorrected];
            y = log10([data.Randot data.Randot]);

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
            ytickpositions = stereoacuity_tickpositions;
            yticklabels = stereoacuity_ticklabels;
        case "perimetry vs best corrected visual acuity"
            title_str = "Perimetry Scores as a Function of Best Corrected Visual Acuity";
            x = [data.LeftETDRSCorrected(1:num_perimetry_subj) data.RightETDRSCorrected(1:num_perimetry_subj)];
            y = [leftPerimetry rightPerimetry];

            xtickpositions = VA_tickpositions;
            xticklabels = VA_ticklabels;
            ytickpositions = perimetry_tickpositions;
            yticklabels = perimetry_ticklabels;
            % visual performance (perimetry, stereo acuity) as a function of contrast sensitivity
        case "perimetry vs contrast sensitivity"
            title_str = "Perimetry Scores as a Function of Contrast Sensitivity";
            x = [data.LeftPELLIR_N(1:num_perimetry_subj) data.RightPELLIR_N(1:num_perimetry_subj)];
            y = [leftPerimetry rightPerimetry];

            xtickpositions = contrast_tickpositions;
            xticklabels = contrast_ticklabels;
            ytickpositions = perimetry_tickpositions;
            yticklabels = perimetry_ticklabels;
        case "stereoacuity vs contrast sensitivity"
            title_str = "Stereoacuity as a Function of Contrast Sensitivity";
            x = [data.LeftPELLIR_N data.RightPELLIR_N];
            y = log10([data.Randot data.Randot]);

            xtickpositions = contrast_tickpositions;
            xticklabels = contrast_ticklabels;
            ytickpositions = stereoacuity_tickpositions;
            yticklabels = stereoacuity_ticklabels;
            % visual perfromance (stereoacuity) as a function of perimetry
        case "stereoacuity vs perimetry"
            title_str = "Stereoacuity as a Function of Perimetry Scores";
            x = [leftPerimetry rightPerimetry];
            y = log10([data.Randot(1:num_perimetry_subj) data.Randot(1:num_perimetry_subj)]);

            xtickpositions = perimetry_tickpositions;
            xticklabels = perimetry_ticklabels;
            ytickpositions = stereoacuity_tickpositions;
            yticklabels = stereoacuity_ticklabels;
    end

    [r, p] = corrcoef(x(:), y(:));
    r_squared = r(1,2);
    p_value = p(1,2);
    

    text_str = sprintf('R = %.3f\np-value = %.3f', r_squared, p_value);

    % plot the scatter
    figure('Position', [100 100 650 650],'Visible','off');
    hold on;

    get(groot);
    hold on;

    %     scatter(x, y,'SizeData',DefaultMarkerSize, 'LineWidth', DefaultMarkerLineWidth);

    s = scatter(x, y, DefaultMarkerSize, 'LineWidth', DefaultMarkerLineWidth, 'MarkerEdgeColor', [1 1 1], 'MarkerFaceAlpha', alpha);
    s(1).MarkerFaceColor = red;   % assign the first color to the first data point
    s(2).MarkerFaceColor = blue;  % assign the second color to the second data point

    % Fit a trendline
    coeff = polyfit(x(:), y(:), 1);
    y_fit = polyval(coeff, x(:));
    hold on;
    plot(x(:), y_fit, 'DisplayName', 'Trend Line', 'color', red);

    set(gca, 'YTick', ytickpositions, 'YTickLabel', yticklabels);
    set(gca, 'XTick', xtickpositions, 'XTickLabel', xticklabels);

    % style plots based on the case
    switch data_selected
        case "contrast vs uncorrected visual acuity"
            xlabel(UVA_label);
            ylabel(contrast_label);
            set(gca, 'XDir','reverse') % Negative LogMAR values are better

            x1(1)=xline(VA_normal ,'--',VA_normal_label , 'HandleVisibility','off');
            x1(2)=xline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            x1(3)=yline(contrast_normal,'--',contrast_normal_label,'Color','k','HandleVisibility','off');
            x1(4)=yline(contrast_disability,'--',contrast_disability_label,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='bottom';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='left';

            ylim([1.4 2.15])
            xlim([-0.5 1.25])

            annotation_position = [0.7, 0.1, 0.2, 0.1];

        case "stereoacuity vs uncorrected visual acuity"
            xlabel(UVA_label);
            ylabel(stereo_label);
            set(gca, 'XDir','reverse') % Negative LogMAR values are better
            set(gca, 'YDir','reverse') % smaller stereoacuity scores are better

            x1(1)=xline(VA_normal,'--',VA_normal_label, 'HandleVisibility','off');
            x1(2)=xline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            x1(3)=yline(stereo_normal,'--',stereo_normal_label,'Color','k','HandleVisibility','off');
            x1(4)=yline(stereo_disability,'--',stereo_disability_label,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='bottom';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='left';

            annotation_position = [0.72, 0.13, 0.089, 0.1];
            xlim([-0.46 1.2])
            ylim(log10([10 425]))

        case "perimetry vs uncorrected visual acuity"
            xlabel(UVA_label);
            ylabel(perimetry_label);
            set(gca, 'XDir','reverse') % Negative LogMAR values are better

            x1(1)=xline(VA_normal,'--',VA_normal_label, 'HandleVisibility','off');
            x1(2)=xline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            x1(3)=yline(perimetry_normal,'--',perimetry_normal_label,'Color','k','HandleVisibility','off');
            % x1(4)=yline(perimetry_disability ,'--',perimetry_disability_label,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='bottom';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            %x1(4).LabelVerticalAlignment='middle';
            %x1(4).LabelHorizontalAlignment='left';

            xlim([-0.47 1.3]);
            ylim([0.5 1.06]);
            annotation_position = [0.72, 0.1, 0.2, 0.1];

        case "contrast vs best corrected visual acuity"
            xlabel(BCVA_label);
            ylabel(contrast_label);
            set(gca, 'XDir','reverse') % Negative LogMAR values are better

            x1(1)=xline(VA_normal,'--',VA_normal_label , 'HandleVisibility','off');
            x1(2)=xline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            x1(3)=yline(contrast_normal,'--',contrast_normal_label,'Color','k','HandleVisibility','off');
            x1(4)=yline(contrast_disability,'--',contrast_disability_label ,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='bottom';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='left';

            xlim([-0.43 0.6])
            ylim([1.4 2.15])

            annotation_position = [0.7, 0.1, 0.2, 0.1];

        case "stereoacuity vs best corrected visual acuity"
            xlabel(BCVA_label);
            ylabel(stereo_label);
            set(gca, 'XDir','reverse') % Negative LogMAR values are better
            set(gca, 'YDir','reverse') % smaller stereoacuity scores are better

            x1(1)=xline(VA_normal,'--',VA_normal_label , 'HandleVisibility','off');
            x1(2)=xline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            x1(3)=yline(stereo_normal,'--',stereo_normal_label,'Color','k','HandleVisibility','off');
            x1(4)=yline(stereo_disability ,'--',stereo_disability_label ,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='bottom';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='left';

            annotation_position = [0.7, 0.1, 0.2, 0.1];

            xlim([-0.3 0.6])
        case "perimetry vs best corrected visual acuity"
            xlabel(BCVA_label);
            ylabel('Perimetry Score, logarithmically scaled');
            set(gca, 'XDir','reverse') % Negative LogMAR values are better

            x1(1)=xline(VA_normal,'--',VA_normal_label , 'HandleVisibility','off');
            x1(2)=xline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            x1(3)= yline(perimetry_normal,'--',perimetry_normal_label ,'Color','k','HandleVisibility','off');
            % x1(4)=yline(perimetry_disability,'--',perimetry_disability_label,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='bottom';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            % x1(4).LabelVerticalAlignment='middle';
            % x1(4).LabelHorizontalAlignment='left';

            annotation_position = [0.7, 0.1, 0.2, 0.1];

            xlim([-0.5 0.4])
            ylim([0.5 1.05])
        case "perimetry vs contrast sensitivity"
            xlabel(contrast_label );
            ylabel(perimetry_label);

            x1(1)=xline(contrast_normal,'--',contrast_normal_label,'Color','k','HandleVisibility','off');
            x1(2)=xline(contrast_disability,'--',contrast_disability_label,'Color','k','HandleVisibility','off');
            x1(3)=yline(perimetry_normal,'--',perimetry_normal_label,'Color','k','HandleVisibility','off');
            % x1(4)=yline(perimetry_disability,'--',perimetry_disability_label ,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='bottom';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            %x1(4).LabelVerticalAlignment='middle';
            %x1(4).LabelHorizontalAlignment='left';

            xlim([1.5 2.3])

            annotation_position = [0.7, 0.1, 0.2, 0.1];

        case "stereoacuity vs contrast sensitivity"
            xlabel(contrast_label);
            ylabel(stereo_label);
            set(gca, 'YDir','reverse') % smaller stereoacuity scores are better

            x1(1)=xline(contrast_normal,'--',contrast_normal_label,'Color','k','HandleVisibility','off');
            x1(2)=xline(contrast_impairment,'--',contrast_impairment_label,'Color','k','HandleVisibility','off');
            x1(3)=yline(stereo_normal,'--',stereo_normal_label ,'Color','k','HandleVisibility','off');
            x1(4)=yline(stereo_disability,'--',stereo_disability_label,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='middle';
            x1(1).LabelHorizontalAlignment='center';
            x1(2).LabelVerticalAlignment='middle';
            x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='center';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='center';

            xlim([1.45 2.15])
            ylim(log10([15 420]))

            annotation_position = [0.7, 0.1, 0.2, 0.1];

        case "stereoacuity vs perimetry"
            xlabel(perimetry_label);
            ylabel(stereo_label);
            set(gca, 'YDir','reverse') % smaller stereoacuity scores are better

            x1(1)=xline(perimetry_normal,'--',perimetry_normal_label,'Color','k','HandleVisibility','off');
            % x1(2)=xline(perimetry_disability,'--',perimetry_disability_label,'Color','k','HandleVisibility','off');
            x1(3)=yline(stereo_normal,'--',stereo_normal_label,'Color','k','HandleVisibility','off');
            x1(4)=yline(stereo_disability,'--',stereo_disability_label,'Color','k','HandleVisibility','off');

            x1(1).LabelVerticalAlignment='bottom';
            x1(1).LabelHorizontalAlignment='center';
            %  x1(2).LabelVerticalAlignment='bottom';
            % x1(2).LabelHorizontalAlignment='center';
            x1(3).LabelVerticalAlignment='middle';
            x1(3).LabelHorizontalAlignment='left';
            x1(4).LabelVerticalAlignment='middle';
            x1(4).LabelHorizontalAlignment='left';

            annotation_position = [0.7, 0.1, 0.2, 0.1];
    end

    annotation('textbox', annotation_position, 'String', text_str, 'FitBoxToText', 'on', 'BackgroundColor', 'w', FontSize=16, FaceAlpha=0.5);

    title(title_str);
    legend('Left Eye','Right Eye')

    % save to correlational plots folder
    print(fullfile('Figures/Correlational Plots', title_str), '-dpdf');
end

%% BAR GRAPHS: Without grouping
clear cases case_idx data_selected
cases = [ "uncorrected visual acuity", "best corrected visual acuity",...
    "contrast sensitivity", "perimetry", "stereoacuity"];

for case_idx = 1:length(cases)
    data_selected = cases(case_idx); % set the measurements to plot
    switch data_selected % select the data based on the case

        case "uncorrected visual acuity"
            mean_value = nanmean([data.LeftETDRSUncorrected ; data.RightETDRSUncorrected]);
            se_value = nanstd([data.LeftETDRSUncorrected ; data.RightETDRSUncorrected])/sqrt(length([data.LeftETDRSUncorrected ; data.RightETDRSUncorrected]));


        case "best corrected visual acuity"
            mean_value = nanmean([data.LeftETDRSCorrected ; data.RightETDRSCorrected]);
            se_value = nanstd([data.LeftETDRSCorrected ; data.RightETDRSCorrected])/sqrt(length([data.LeftETDRSCorrected ; data.RightETDRSCorrected]));

        case "contrast sensitivity"
            mean_value = nanmean([data.LeftPELLIR_N ; data.RightPELLIR_N]);
            se_value = nanstd([data.LeftPELLIR_N ; data.RightPELLIR_N])/sqrt(length([data.LeftPELLIR_N ; data.RightPELLIR_N]));

        case "perimetry"
            mean_value = nanmean([data.LeftPerimetry ; data.RightPerimetry]);
            se_value = nanstd([data.LeftPerimetry ; data.RightPerimetry])/sqrt(length([data.LeftPerimetry ; data.RightPerimetry]));

        case "stereoacuity"
            mean_value = nanmean(data.Randot);
            se_value = nanstd(data.Randot)/sqrt(length(data.Randot));

    end

    figure('Position', [100 100 750 550],'Visible','off'); hold on

    get(groot);

    bar(mean_value, 'barwidth',1, 'FaceColor', [0.5 0.5 1]);

    text(1:length(mean_value), mean_value, num2str(mean_value', '%0.2f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'k', 'FontSize', 10);

    errorbar(mean_value, se_value, 'k', 'linestyle', 'none', 'LineWidth', 1.5);

    set(gca, 'xticklabels', {});
    set(gca, 'xtick', []);

    switch data_selected % select the appropriate style for each case
        case "uncorrected visual acuity"
            title_str = "Mean Uncorrected Visual Acuity (logMAR)";
            ylabel('Uncorrected Visual Acuity (logMAR)');
            yline(VA_normal ,'--',VA_normal_label, 'HandleVisibility','off');
            yline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            ylim(VA_lim);

        case "best corrected visual acuity"
            title_str = "Mean Best Corrected Visual Acuity (logMAR)";
            ylabel('Best Corrected Visual Acuity (logMAR)');
            yline(VA_normal ,'--',VA_normal_label, 'HandleVisibility','off');
            yline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            ylim(VA_lim);

        case "contrast sensitivity"
            title_str = "Mean Contrast Sensitivity";
            ylabel('Contrast Sensitivity (logCS)');
            yline(contrast_normal,'--',contrast_normal_label,'Color','k','HandleVisibility','off');
            yline(contrast_disability,'--',contrast_disability_label,'Color','k','HandleVisibility','off');
            ylim(CS_lim);

        case "perimetry"
            title_str = "Mean Perimetry Score";
            ylabel('Perimetry Score');
            yline(perimetry_normal,'--',perimetry_normal_label, 'HandleVisibility','off');
            yline(perimetry_disability,'--',perimetry_disability_label, 'HandleVisibility','off');
            ylim(perimetry_lim);

        case "stereoacuity"
            title_str = "Mean Stereoacuity";
            ylabel('Stereoacuity (arc sec)');
            yline(stereo_normal,'--',stereo_normal_label , 'HandleVisibility','off');
            yline(stereo_disability ,'--',stereo_disability_label , 'HandleVisibility','off');
            ylim(Stereo_lim);
    end

    title(title_str);

    % save to bar graph folder
    print(fullfile('Figures/Bar Graphs', title_str), '-dpdf');
end

%% BAR GRAPHS: Grouped by eye dominance

% Select rows for each dominance type
domEye_idx = data.EyeDominance == 1;
nonDomEye_idx = data.EyeDominance == 0;

% clear cases case_idx data_selected
cases = [ "uncorrected visual acuity", "best corrected visual acuity",...
    "contrast sensitivity", "perimetry"];

for case_idx = 1:length(cases)
    data_selected = cases(case_idx); % set the measurements to plot
    switch data_selected % select the data based on the case
        case "uncorrected visual acuity"
            selectedColumns = {'LeftETDRSUncorrected', 'RightETDRSUncorrected'};

        case "best corrected visual acuity"
            selectedColumns = {'LeftETDRSCorrected', 'RightETDRSCorrected'};

        case "contrast sensitivity"
            selectedColumns = {'LeftPELLIR_N','RightPELLIR_N'};

        case "perimetry"
            selectedColumns = {'LeftPerimetry','RightPerimetry'};
    end

    selectDomData = data(domEye_idx, selectedColumns); % Select the data points where Eye dominance = 1
    meanDom = nanmean(selectDomData{:,:}, 1);
    semDom = nanstd(selectDomData{:,:},1)./sqrt(sum(~isnan(selectDomData{:,:}))); % standard error

    selectNonDomData = data(nonDomEye_idx, selectedColumns); % Select the data points where Eye dominance = 0
    meanNonDom = nanmean(selectNonDomData{:,:}, 1);
    semNonDom = nanstd(selectNonDomData{:,:},1)./sqrt(sum(~isnan(selectNonDomData{:,:}))); % standard error

    figure('Position', [100 100 750 550],'Visible','off'); hold on

    get(groot);

    barWidth = 0.4;
    barPos = [1-barWidth/2, 2-barWidth/2]; % x-coordinates for the two bars

    bar(barPos(1), meanDom(1), barWidth, 'FaceColor', [0.5 0.5 1])
    bar(barPos(2), meanNonDom(1), barWidth, 'FaceColor', [1 0.5 0.5])

    % add mean values for dominant and non-dominant to the bar graph
    text(barPos(1), meanDom(1)+semDom(1), sprintf('%.2f', meanDom(1)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    text(barPos(2), meanNonDom(1)+semNonDom(1), sprintf('%.2f', meanNonDom(1)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

    errorbar(barPos(1), meanDom(1), semDom(1), 'k', 'LineStyle', 'none', 'LineWidth', 1.5)
    errorbar(barPos(2), meanNonDom(1), semNonDom(1), 'k', 'LineStyle', 'none', 'LineWidth', 1.5)

    set(gca, 'xticklabels', {'Dominant Eye', 'Non-dominant Eye'});
    set(gca, 'xtick', [barPos(1), barPos(2)]);

    switch data_selected % select the appropriate style for each case
        case "uncorrected visual acuity"
            title_str = "Mean Uncorrected Visual Acuity (logMAR)";
            ylabel('Uncorrected Visual Acuity (logMAR)');
            yline(VA_normal ,'--',VA_normal_label, 'HandleVisibility','off');
            yline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            ylim(VA_lim);

        case "best corrected visual acuity"
            title_str = "Mean Best Corrected Visual Acuity (logMAR)";
            ylabel('Best Corrected Visual Acuity (logMAR)');
            yline(VA_normal ,'--',VA_normal_label, 'HandleVisibility','off');
            yline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            ylim(VA_lim);

        case "contrast sensitivity"
            title_str = "Mean Contrast Sensitivity";
            ylabel('Contrast Sensitivity (logCS)');
            yline(contrast_normal,'--',contrast_normal_label,'Color','k','HandleVisibility','off');
            yline(contrast_disability,'--',contrast_disability_label,'Color','k','HandleVisibility','off');
            ylim(CS_lim);

        case "perimetry"
            title_str = "Mean Perimetry Score";
            ylabel('Perimetry Score');
            yline(perimetry_normal,'--',perimetry_normal_label, 'HandleVisibility','off');
            yline(perimetry_disability,'--',perimetry_disability_label, 'HandleVisibility','off');
            ylim(perimetry_lim);

        case "stereoacuity"
            title_str = "Mean Stereoacuity";
            ylabel('Stereoacuity (arc sec)');
            yline(stereo_normal,'--',stereo_normal_label , 'HandleVisibility','off');
            yline(stereo_disability ,'--',stereo_disability_label , 'HandleVisibility','off');
            ylim(Stereo_lim);
    end

    title(title_str);

    % save to bar graph folder
    print(fullfile('Figures/Bar Graphs', title_str), '-dpdf');
end
%% BAR GRAPHS: Grouped by sex
% Select rows for each sex
Female_idx = data.Sex == 1;
Male_idx = data.Sex == 0;

% clear cases case_idx data_selected
cases = [ "IPD", "uncorrected visual acuity", "best corrected visual acuity",...
    "contrast sensitivity", "stereoacuity","perimetry"];

for case_idx = 1:length(cases)
    data_selected = cases(case_idx); % set the measurements to plot
    switch data_selected % select the data based on the case
        case "IPD"
            selectedColumns = {'IPD'};

        case "uncorrected visual acuity"
            selectedColumns = {'LeftETDRSUncorrected', 'RightETDRSUncorrected'};

        case "best corrected visual acuity"
            selectedColumns = {'LeftETDRSCorrected', 'RightETDRSCorrected'};

        case "contrast sensitivity"
            selectedColumns = {'LeftPELLIR_N','RightPELLIR_N'};

        case "stereoacuity"
            selectedColumns = {'Randot'};

        case "perimetry"
            selectedColumns = {'LeftPerimetry','RightPerimetry'};
    end

    selectFemaleData = data(Female_idx, selectedColumns); % Select the data points where Eye dominance = 1
    meanFemale = nanmean(selectFemaleData{:,:}, 1);

    selectMaleData = data(Male_idx, selectedColumns);
    meanMale = nanmean(selectMaleData{:,:}, 1);

     % Perform t-test and compute p-value
    [~, pval, ~, stats] = ttest2(selectFemaleData{:,:}, selectMaleData{:,:});

    figure('Position', [100 100 750 550],'Visible','off'); hold on

    get(groot);

    barWidth = 0.4;
    barPos = [1-barWidth/2, 2-barWidth/2]; % x-coordinates for the two bars

    bar(barPos(1), meanFemale(1), barWidth, 'FaceColor', [0.5 0.5 1]);
    bar(barPos(2), meanMale(1), barWidth, 'FaceColor', [1 0.5 0.5]);

    text(barPos(1), meanFemale(1)+0.1, num2str(meanFemale(1), '%.2f'), 'HorizontalAlignment', 'center');
    text(barPos(2), meanMale(1)+0.1, num2str(meanMale(1), '%.2f'), 'HorizontalAlignment', 'center');
    text(mean(barPos), max([meanFemale(1), meanMale(1)])+0.2, ['p = ' num2str(pval, '%.3f')], 'HorizontalAlignment', 'center');


    set(gca, 'xticklabels', {'Female', 'Male'});
    set(gca, 'xtick', [barPos(1), barPos(2)]);

    switch data_selected % select the appropriate style for each case
        case "uncorrected visual acuity"
            title_str = "Mean Uncorrected Visual Acuity (logMAR)";
            ylabel('Uncorrected Visual Acuity (logMAR)');
            yline(VA_normal ,'--',VA_normal_label, 'HandleVisibility','off');
            yline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            ylim(VA_lim);

        case "best corrected visual acuity"
            title_str = "Mean Best Corrected Visual Acuity (logMAR)";
            ylabel('Best Corrected Visual Acuity (logMAR)');
            yline(VA_normal ,'--',VA_normal_label, 'HandleVisibility','off');
            yline(VA_disability,'--',VA_disability_label, 'HandleVisibility','off');
            ylim(VA_lim);

        case "contrast sensitivity"
            title_str = "Mean Contrast Sensitivity";
            ylabel('Contrast Sensitivity (logCS)');
            yline(contrast_normal,'--',contrast_normal_label,'Color','k','HandleVisibility','off');
            yline(contrast_disability,'--',contrast_disability_label,'Color','k','HandleVisibility','off');
            ylim(CS_lim);

        case "perimetry"
            title_str = "Mean Perimetry Score";
            ylabel('Perimetry Score');
            yline(perimetry_normal,'--',perimetry_normal_label, 'HandleVisibility','off');
            yline(perimetry_disability,'--',perimetry_disability_label, 'HandleVisibility','off');
            ylim([0 1.5]);

        case "stereoacuity"
            title_str = "Mean Stereoacuity";
            ylabel('Stereoacuity (arc sec)');
            yline(stereo_normal,'--',stereo_normal_label , 'HandleVisibility','off');
            yline(stereo_disability ,'--',stereo_disability_label , 'HandleVisibility','off');
            ylim([0 60]);
    end

    % calculate standard error of the mean
    seFemale = nanstd(selectFemaleData{:,:}) / sqrt(sum(Female_idx));
    seMale = nanstd(selectMaleData{:,:}) / sqrt(sum(Male_idx));

    errorbar(barPos, [meanFemale(1), meanMale(1)], [seFemale(1), seMale(1)], 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

    title(title_str);

    % save to bar graph folder
    print(fullfile('Figures/Bar Graphs', title_str), '-dpdf');
end
%% Notify user that figures are ready
disp('All figures/image files have been generated');