clc; clear; close all;

load fisheriris.mat;

X = meas;
 mu = mean(X, 1);
 sigma = std(X, [], 1);
 Z = (X - mu) ./ sigma;

[coeff, score, latent, ~, explained] = pca(Z);

cumExplained = cumsum(explained);

figure('Name','Iris PCA: PC1 vs PC2','NumberTitle','off');
gscatter(score(:,1), score(:,2), species, 'rgb', 'o', 8);
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('Iris Dataset: Projection onto First Two PCs');
legend({'setosa','versicolor','virginica'}, 'Location','best');
grid on;

figure('Name','Iris PCA: Explained Variance','NumberTitle','off');
bar(explained, 'FaceColor',[.2 .2 .8]);
hold on;
plot(cumExplained, '-o', 'LineWidth', 2, 'Color',[.85 .33 .10]);
xlabel('Principal Component Index');
ylabel('Variance Explained (%)');
title('Scree Plot & Cumulative Variance');
xticks(1:4);
legend({'Individual PC','Cumulative'}, 'Location','best');
grid on;
hold off;
