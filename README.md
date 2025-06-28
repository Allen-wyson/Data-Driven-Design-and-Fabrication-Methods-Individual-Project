# EPFL ME-438 Spring 2025 Individual Project


## 📋 Project Overview

This repository contains the final **individual** project for **ME-438** (Department of Mechanical Engineering) at EPFL. The study explores and compares data-driven techniques and optimization algorithms through four main investigations:

1. **Black-box Optimization**: Evaluate Genetic Algorithm (GA) vs. Bayesian Optimization (BO) on two benchmark functions (Rastrigin and Three-Hump Camel).
   *Everyday analogy:* Like trying both random recipe tweaks (GA) and smart taste-guided suggestions (BO) to bake the perfect cake.
2. **Principal Component Analysis (PCA)**: Reduce the four-dimensional Iris dataset to two dimensions and assess how well the main components separate flower species.
3. **K-means Clustering**: Find the optimal number of clusters for Iris sepal measurements and measure clustering accuracy against true species labels.
4. **Literature Review**: Summarize and critique two data-driven design papers in robotics, focusing on graph grammar co-design (RoboGrammar) and batch Bayesian Optimization for robotic cooking.


## ▶️ Running Analyses

Launch MATLAB and run each script in sequence.

* **Black-box Optimization**:

  ```matlab
  bo_sweep
  ```
* **Genetic Algorithm Sweep**:

  ```matlab
  ga_sweep
  ```
* **PCA on Iris Dataset**:

  ```matlab
  pca_analysis
  ```
* **K-means Clustering**:

  ```matlab
  kmeans_analysis
  ```

## 📈 Key Findings

* **BO vs. GA**: BO is more sample-efficient on smooth landscapes (Three-Hump Camel) but GA excels in rugged terrains (Rastrigin) with high mutation rates.
* **PCA**: Two principal components capture over 95% of variance; Iris Setosa forms a distinct cluster.
* **K-means**: Optimal cluster number (k=2) yields \~62% accuracy when mapping clusters to true species.
* **Paper Insights**: Grammar-based robot co-design offers structured search, while batch BO reduces trial noise in robotic cooking experiments.

## 👤 Author

**Yo‑Shiun Cheng** (Student ID: 386249)
Department of Mechanical Engineering, EPFL
