clc; clear; close all;

% setting
nvar = 2;

nTrials = 10;   % repeats per rate
popSize = 50;
mutationRates = [0.01, 0.05, 0.1, 0.2, 0.3];

objFuncs = {@rastriginsfcn, @camel3humpfcn};
funcNames = {'Rastrigin', '3-Hump Camel'};
nFunc = numel(objFuncs);

% storage
results = table('Size', [nFunc * numel(mutationRates), 6], ...
    'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Function', 'MutationRate', 'MeanFval', 'StdFval', 'MeanTime', 'MeanGens'});
row = 1;

% parallel pool
if isempty(gcp('nocreate'))
    parpool('AttachedFiles','ga_sweep.m');
end


% sweep over objective functions
for fIdx = 1 : nFunc
    func = objFuncs{fIdx};
    fname = funcNames{fIdx};
    fprintf('Processing function: %s\n', fname);

    % loop over mutation rates
    for mu = mutationRates
        fprintf('Testing mutation rate μ = %.3f\n', mu);
        fvals = zeros(nTrials, 1);
        times = zeros(nTrials, 1);
        gens = zeros(nTrials, 1);

        for t = 1 : nTrials
            rng(t);
            options = optimoptions('ga', ...
                'UseParallel',true, ...
                'PlotFcn',{'gaplotbestf','gaplotdistance','gaplotstopping'}, ...
                'PopulationSize', popSize, ...
                'MutationFcn', {@mutationuniform, mu});

            % run GA and time it
            tic;
            [x, fval, exitflag, output] = ga(func,nvar,[],[],[],[],[],[],[],options);
            times(t) = toc;
            fvals(t) = fval;
            gens(t) = output.generations;
        end

        results.Function(row) = fname;
        results.MutationRate(row) = mu;
        results.MeanFval(row) = mean(fvals);
        results.StdFval(row) = std(fvals);
        results.MeanTime(row) = mean(times);
        results.MeanGens(row) = mean(gens);
        row = row + 1;
    end
end

% Display / save
disp(results);
writetable(results, 'ga_sweep_results.csv');

% plot
for fIdx = 1 : nFunc
    fname = funcNames{fIdx};
    subT = results(strcmp(results.Function, fname),  :);

    fig = figure;
    yyaxis left
    errorbar(subT.MutationRate, subT.MeanFval, subT.StdFval,'-o','LineWidth',1.2);
    ylabel('Mean Best Fitness \pm 1\,STD');
    xlabel('Mutation Rate \mu');
    yyaxis right
    plot(subT.MutationRate, subT.MeanTime,'--s','LineWidth',1.2);
    ylabel('Mean Elapsed Time (s)');

    title('Effect of GA Mutation Rate on ', fname);
    grid on;
    legend('Fitness','Time','Location','northwest');
end

% objective functions
function f = rastriginsfcn(X)
    xx = [X(1), X(2)];
    f  = 10*numel(xx) + sum(xx.^2 - 10*cos(2*pi*xx));
end

function f = camel3humpfcn(X)
    x = X(1);
    y = X(2);
    f = 2*x^2 - 1.05*x^4 + (x^6)/6 + x*y + y^2;
end

