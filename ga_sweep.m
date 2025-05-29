rng(1) % For reproducibility
fun = @rastriginsfcn;
nvar = 2;
%options = optimoptions('ga','PlotFcn',{'gaplotbestf','gaplotdistance','gaplotstopping'})
%options = optimoptions('ga','PlotFcn',{'gaplotbestf','gaplotdistance','gaplotstopping'}, 'MaxStallGenerations',20)
%options = optimoptions('ga','PlotFcn',{'gaplotbestf','gaplotdistance','gaplotstopping'}, 'PopulationSize', 100)
%options = optimoptions('ga','PlotFcn',{'gaplotbestf','gaplotdistance','gaplotstopping'}, 'PopulationSize', 50, 'CrossoverFraction', 1)
options = optimoptions('ga','PlotFcn',{'gaplotbestf','gaplotdistance','gaplotstopping'}, 'PopulationSize', 50, 'MutationFcn',{@mutationgaussian,1,0.2})



[x,fval] = ga(fun,nvar,[],[],[],[],[],[],[],options)

% Plot where the GA sampled
%plotPopulationHistory(populationLocations)


% % Random baseline for comparison
% lb = [-1, -1];
% ub = [2, 2];
% % Run random sampling baseline
% numSamples = 1000;
% [bestX, bestFval, sampledPoints] = randomSamplingBaseline(fun, numSamples, lb, ub);



function scores = rastriginsfcn(pop)
    scores = 10.0 * size(pop,2) + sum(pop .^2 - 10.0 * cos(2 * pi .* pop),2);
end


function plotPopulationHistory(populationLocations)

    figure;
    hold on;
    numGenerations = length(populationLocations);
    colors = lines(numGenerations);

    for gen = 1:numGenerations
        pop = populationLocations{gen};
        scatter(pop(:,1), pop(:,2), 30, colors(gen,:), 'filled', 'MarkerFaceAlpha', 0.5);
    end

    xlabel('X Position');
    ylabel('Y Position');
    title('Population Locations Over Generations');
   % legend(arrayfun(@(x) ['Gen ', num2str(x)], 1:numGenerations, 'UniformOutput', false), 'Location', 'bestoutside');
    axis equal;
    grid on;
end

function [bestX, bestFval, sampledPoints] = randomSamplingBaseline(fitnessFcn, numSamples, lb, ub)
    
    sampledPoints = zeros(numSamples, length(lb));
    fitnessValues = zeros(numSamples, 1);
    
    % Sampling loop
    for i = 1:numSamples
        % Uniform random sampling within bounds
        sampledPoints(i, :) = lb + rand(1, length(lb)) .* (ub - lb);
        % Evaluate fitness
        fitnessValues(i) = fitnessFcn(sampledPoints(i, :));
    end
    
    % Find minimum
    [bestFval, idx] = min(fitnessValues);
    bestX = sampledPoints(idx, :);
    
    % Display result
    fprintf('Random Sampling Result:\n');
    fprintf('Best Fitness: %.4f at [%.4f, %.4f]\n', bestFval, bestX(1), bestX(2));
    
    % Optional: plot sampled points
    figure;
    scatter(sampledPoints(:,1), sampledPoints(:,2), 30, fitnessValues, 'filled');
    colorbar;
    xlabel('X'); ylabel('Y');
    title('Random Sampling Points (colored by fitness)');
    axis equal;
    grid on;
end