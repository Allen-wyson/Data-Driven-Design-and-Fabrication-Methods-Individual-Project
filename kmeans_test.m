clc; clear; close all;

load fisheriris
X_full = meas(:,1:2);
labels = species;

figure('Name','sepal length vs sepal width','NumberTitle','off');
gscatter(X_full(:,1), X_full(:,2), labels, 'rgb', 'o', 8);
xlabel('Sepal Length (cm)');
ylabel('Sepal Width  (cm)');
title('Iris Dataset: sepal length vs sepal width');
legend({'setosa','versicolor','virginica'}, 'Location','best');
grid on;

maxK = 6;  % test k = 2 to 6
avgSil = zeros(maxK,1);
allSil = cell(maxK,1);
opts = statset('UseParallel',false);

for k = 2:maxK
    rng(1);
    [idx, C] = kmeans(X_full, k, ...
                     'Replicates', 10, ...
                     'Options', opts, ...
                     'Distance', 'sqeuclidean');
    sil_vals = silhouette(X_full, idx, 'sqeuclidean');
    avgSil(k) = mean(sil_vals);
    allSil{k} = sil_vals;
end

figure('Name','Silhouette Scores for k = 2 to 6','NumberTitle','off');
kRange = 2:maxK;
plot(kRange, avgSil(kRange), '-o', 'LineWidth', 1.5, 'MarkerSize', 8);
xlabel('Number of Clusters (k)');
ylabel('Average Silhouette Score');
title('Selecting k via Silhouette Analysis');
xticks(kRange);
grid on;

[~, bestK] = max(avgSil(2:maxK));
bestK = bestK + 1;  % because index 1 corresponds to k=2

fprintf('Optimal k by silhouette: %d\n', bestK);

rng(1);
[idx_final, centroids] = kmeans(X_full, bestK, ...
                                'Replicates', 10, ...
                                'Options', opts, ...
                                'Distance', 'sqeuclidean');

colors = lines(bestK);
figure('Name',sprintf('k-means Clustering (k = %d)', bestK),'NumberTitle','off');
hold on;
for c = 1:bestK
    scatter(X_full(idx_final==c,1), X_full(idx_final==c,2), ...
            40, colors(c,:), 'filled', 'MarkerFaceAlpha',0.6);
end
plot(centroids(:,1), centroids(:,2), 'kx', 'MarkerSize', 15, 'LineWidth', 2);
hold off;
xlabel('Sepal Length (cm)');
ylabel('Sepal Width  (cm)');
title(sprintf('k-means Clusters (k = %d) on Sepal Measurements', bestK));
legendStrings = arrayfun(@(x) sprintf('Cluster %d',x), 1:bestK, 'UniformOutput',false);
legend([legendStrings, {'Centroids'}], 'Location','bestoutside');
grid on;

uniqueSpecies = unique(labels);
clusterLabels = strings(bestK,1);
accuracyCount = 0;
for c = 1:bestK
    members = labels(idx_final==c);
    if isempty(members)
        clusterLabels(c) = "N/A";
        continue
    end
    counts = cellfun(@(s) sum(strcmp(members,s)), uniqueSpecies);
    [~, idxMax] = max(counts);
    clusterLabels(c) = uniqueSpecies{idxMax};
end

assignedLabels = strings(150,1);
for i = 1:150
    assignedLabels(i) = clusterLabels(idx_final(i));
end

trueLabels = string(labels);
accuracy = mean(assignedLabels == trueLabels);
fprintf('Clustering accuracy (k = %d): %.2f%%\n', bestK, accuracy*100);
figure('Name','Confusion Matrix: Cluster vs True Species','NumberTitle','off');
confusionchart(trueLabels, assignedLabels);
title(sprintf('Confusion Matrix (k = %d)', bestK));
