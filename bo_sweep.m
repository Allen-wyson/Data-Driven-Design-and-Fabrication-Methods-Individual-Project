clc; clear; close all;

%% Settings
X1 = optimizableVariable('x',[-5 5]);
X2 = optimizableVariable('y',[-5 5]);
vars = [X1,X2];
explorationRatios = 0.1 : 0.1 : 0.9;
nExperiments = 10;
objFuncs = {@rastriginsfcn, @threeHumpCamel};
funcNames = {'Rastrigins', '3-Hump Camel'};

%% parallel pool
if isempty(gcp('nocreate'))
    parpool('AttachedFiles','bo_sweep.m');
end

%% Loop over each objFuncs
for fIdx = 1 : numel(objFuncs)
    objFunc = objFuncs{fIdx};
    fname = funcNames{fIdx};

    % plot the function surface and contour
    [xg, yg] = meshgrid(linspace(-5,5,200), linspace(-5,5,200));
    Z = arrayfun(@(xx,yy) objFunc(struct('x',xx,'y',yy)), xg, yg);

    figure('Name', [fname ' Surface']);
    surf(xg, yg, Z, 'EdgeColor','none'); shading interp;
    title([fname ' Surface']); xlabel('x'); ylabel('y'); zlabel('f(x,y)');
    view(45,30); colorbar;

    figure('Name', [fname ' Contour']);
    contourf(xg, yg, Z, 50, 'LineColor','none');
    title([fname ' Contour']); xlabel('x'); ylabel('y'); colorbar;

    % results array
    avgTime = zeros(size(explorationRatios));
    avgPerf = zeros(size(explorationRatios));

    % sweep exploration ratio
    for idx = 1 : numel(explorationRatios)
        k = explorationRatios(idx);
        timevec = zeros(1, nExperiments);
        perfvec = zeros(1, nExperiments);

        for j = 1 : nExperiments

            % Perform Bayesian Optimization
            results = bayesopt(objFunc, vars, ...
                'AcquisitionFunctionName','expected-improvement-plus', ...
                'ExplorationRatio',k, ...
                'NumSeedPoints',6, ...
                'UseParallel', true, ...
                'PlotFcn',{});  % @plotAcquisitionFunction, @plotObjectiveModel,@plotMinObjective
            timevec(j) = results.TotalElapsedTime;
            perfvec(j) = results.MinEstimatedObjective;
        end

        avgTime(idx) = mean(timevec);
        avgPerf(idx) = mean(perfvec);
        perfStd(idx) = std(perfvec);
    end

    % save and display results
    T = table(explorationRatios', avgTime', avgPerf', perfStd', ...
        'VariableNames', {'ExplorationRatio', 'AvgTime', 'AvgPerformance', 'StdPerformance'});
    filename = sprintf('bo_avg_results_%s.csv',fname);
    writetable(T, filename);
    fprintf('Results saved to %s\n', filename);
    disp(T);
end

%% Plot aggregated BO results per function (with ±STD)
for fIdx = 1:numel(objFuncs)
    fname = funcNames{fIdx};    
    % Read in the CSV you just wrote
    T = readtable(sprintf('bo_avg_results_%s.csv', fname));

    figure('Name', fname, 'NumberTitle','off');
    % Left axis: performance ±1 STD
    yyaxis left
    errorbar(T.ExplorationRatio, T.AvgPerformance, T.StdPerformance, ...
        '-o','LineWidth',1.2, 'CapSize',10);
    ylabel('Mean Best Performance \pm 1\,STD');
    xlabel('ExplorationRatio');

    % Right axis: timing ±1 STD (optional errorbars)
    yyaxis right
    plot(T.ExplorationRatio, T.AvgTime, ...
        '--s','LineWidth',1.2);
    ylabel('Mean Elapsed Time (s) \pm 1\');

    title(sprintf('BO Exploration Sweep on %s', fname));
    grid on;
    legend('Performance','Time','Location','northwest');
end


%% plot the function surface and contour
[xg, yg] = meshgrid(linspace(-2,2,200), linspace(-2,2,200));
Z = arrayfun(@(xx,yy) threeHumpCamel(struct('x',xx,'y',yy)), xg, yg);

figure('Name', [fname ' Surface']);
surf(xg, yg, Z, 'EdgeColor','none'); shading interp;
title(['3-Hump Camel Surface']); xlabel('x'); ylabel('y'); zlabel('f(x,y)');
view(45,30); colorbar;

figure('Name', [fname ' Contour']);
contourf(xg, yg, Z, 50, 'LineColor','none');
title(['3-Hump Camel Contour']); xlabel('x'); ylabel('y'); colorbar;

% objective functions
function f = rastriginsfcn(X)
    xx = [X.x, X.y];
    f = 10*numel(xx) + sum(xx.^2 - 10*cos(2*pi*xx));
end

function f = threeHumpCamel(X)   % 3-hump camel function
    x = X.x;
    y = X.y;
    f  = (2*x^2 - 1.05*x^4 + (x^6)/6 + x*y + y^2);
end

