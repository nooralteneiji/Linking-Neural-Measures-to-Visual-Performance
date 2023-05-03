%% Prepare independent variables 

mean_perimetry = (data.RightPerimetry + data.LeftPerimetry)/2; % remove NaN

stereoacuity = data.Randot; 

mean_uncorrected_acuity = (data.RightETDRSUncorrected + data.LeftETDRSUncorrected)/2;
mean_corrected_acuity = (data.RightETDRSCorrected + data.LeftETDRSCorrected)/2;

difference_interoccular_uncorrected = abs(data.RightETDRSUncorrected - data.LeftETDRSUncorrected);
difference_interoccular_corrected = abs(data.RightETDRSCorrected - data.LeftETDRSCorrected);

mean_contrast = (data.RightPELLIR_N + data.LeftPELLIR_N)/2;

modelData = table(mean_perimetry, stereoacuity, mean_uncorrected_acuity, mean_corrected_acuity, difference_interoccular_uncorrected, difference_interoccular_corrected, mean_contrast, ...
    'VariableNames', {'mean_perimetry', 'stereoacuity', 'mean_uncorrected_acuity', 'mean_corrected_acuity', 'difference_interoccular_uncorrected', 'difference_interoccular_corrected', 'mean_contrast'});

%% Fit the models 
Stereo_uncorrected_formula = 'stereoacuity ~ mean_uncorrected_acuity + difference_interoccular_uncorrected + mean_contrast';
Stereo_uncorrected_model = fitlme(modelData, Stereo_uncorrected_formula);

Stereo_corrected_formula = 'stereoacuity ~ mean_corrected_acuity + difference_interoccular_corrected + mean_contrast';
Stereo_corrected_model = fitlme(modelData, Stereo_corrected_formula);

Perimetry_uncorrected_formula = 'mean_perimetry ~ mean_uncorrected_acuity + difference_interoccular_uncorrected + mean_contrast';
Perimetry_uncorrected_model = fitlme(modelData, Perimetry_uncorrected_formula);

Perimetry_corrected_formula = 'mean_perimetry ~ mean_corrected_acuity + difference_interoccular_corrected + mean_contrast';
Perimetry_corrected_model = fitlme(modelData, Perimetry_corrected_formula);

%% set models names
% Define your models
models = {Stereo_uncorrected_model, Stereo_corrected_model, Perimetry_uncorrected_model, Perimetry_corrected_model};

% Define model names
modelNames = {'Stereoacuity (UVA)', 'Stereoacuity (BCVA)', 'Perimetry (UVA)', 'Perimetry (BCVA)'};

%% Evaluate fitness of models 
% Adjust for multiple comparisons 
% apply the Benjamini-Hochberg procedure

% Initialize a table to store ANOVA results
anovaResults = cell(length(models), 2);

% Compute ANOVA results and store them in the table
for i = 1:length(models)
    anovaTable = anova(models{i});
    anovaResults{i, 1} = modelNames{i}; % Store the model name
    anovaResults{i, 2} = anovaTable;    % Store the ANOVA table
end

% Gather all numeric p-values from the ANOVA tables
allPValues = [];
for i = 1:size(anovaResults, 1)
    anovaTable = anovaResults{i, 2};
    if isa(anovaTable, 'dataset') % Check if it's a dataset array
        anovaTable = dataset2table(anovaTable); % Convert dataset array to table
    end
    pValues = table2array(anovaTable(:, end)); % Convert p-values column to numeric array (for tables)
    allPValues = [allPValues; pValues];
end

% Calculate corrected p-values using mafdr
correctedPValues = mafdr(allPValues, 'BHFDR', true);

% Update ANOVA tables with corrected p-values
correctedPValuesIndex = 1;
for i = 1:size(anovaResults, 1)
    anovaTable = anovaResults{i, 2};
    numRows = size(anovaTable, 1);
    if isa(anovaTable, 'dataset') % Check if it's a dataset array
        anovaTable = dataset2table(anovaTable); % Convert dataset array to table
    end
    anovaTable(:, end) = array2table(correctedPValues(correctedPValuesIndex:correctedPValuesIndex + numRows - 1));
    anovaResults{i, 2} = anovaTable;
    correctedPValuesIndex = correctedPValuesIndex + numRows;
end

% Display ANOVA results with corrected p-values
for i = 1:size(anovaResults, 1)
    fprintf('ANOVA results for %s (with corrected p-values):\n', anovaResults{i, 1});
    disp(anovaResults{i, 2});
end

%% ========COMPARE MODELS========= 
% Compare goodness-of-fit
AIC = zeros(1, numel(models));
BIC = zeros(1, numel(models));
Rsquared = zeros(1, numel(models));

for i = 1:numel(models)
    AIC(i) = models{i}.ModelCriterion.AIC;
    BIC(i) = models{i}.ModelCriterion.BIC;
    LogLikelihood(i) = models{i}.ModelCriterion.LogLikelihood;
    Deviance(i) = models{i}.ModelCriterion.Deviance;
    Rsquared(i) = models{i}.Rsquared.Ordinary;
end

figure;
bar([AIC; BIC; LogLikelihood; Deviance]');
set(gca, 'XTickLabel', modelNames);
legend('AIC', 'BIC', 'LogLikelihood', 'Deviance');
title('Model Fit Comparison');
ylim([-500 1500]);
xlabel('Response Variable')

figure;
bar([Rsquared]');
set(gca, 'XTickLabel', modelNames);
title('R-squared Comparison');
ylim([0 1])
ylabel('R-squared')
xlabel('Response Variable')

% Create a table with the results
resultsTable = table(AIC', BIC', LogLikelihood', Deviance', Rsquared', 'RowNames', modelNames, ...
    'VariableNames', {'AIC', 'BIC', 'LogLikelihood', 'Deviance', 'Rsquared'});

% Display the table
disp(resultsTable);

%% RESIDUAL ANALYSIS: Evaluate how well the data fits the models 

% =====Visualize the residuals======
% Plotting the residuals of your model against the fitted values or predictor variables can help identify any patterns or non-linearity in the data. 
% Any obvious trends or patterns may indicate that model is not fitting the data well.

% Create a figure for QQ plots
figure;

% Loop through each model
for i = 1:numel(models)
    model = models{i};
    model_name = modelNames{i};
    
    % Get residuals
    residual_values = model.Residuals.Raw;
    valid_residuals = ~isnan(residual_values);
    residual_values = residual_values(valid_residuals);

    % Perform Lilliefors test
    [residNorm, pValue] = lillietest(residual_values);
    fprintf('%s:\n', model_name);
    fprintf('  Lilliefors Test p-value: %.4f\n', pValue);
    
    % Create QQ plot in a subplot
    % visually check whether or not data follows a normal distribution.
    subplot(3, 2, i);
    qqplot(residual_values);
    xlabel('Standard Normal Quantiles');
    ylabel('Sample Quantiles');
    title(['QQ Plot for ', model_name]);
end

%% 
% Extract fitted values and residuals for each model
fittedValues = cell(1, numel(models));
residuals = cell(1, numel(models));
for i = 1:numel(models)
    model = models{i};
    fittedValues{i} = predict(model);
    residuals{i} = table(model.residuals, 'VariableNames', {'residuals'});
end

% Create scatter plots of residuals vs. fitted values
figure;
for i = 1:numel(models)
    subplot(2, 2, i);
    scatter(fittedValues{i}, residuals{i}.residuals);
    xlabel('Fitted Values');
    ylabel('Residuals');
    title(modelNames{i});
    hold on
    % Add horizontal line at y=0
    yline(0, 'k--');
end


