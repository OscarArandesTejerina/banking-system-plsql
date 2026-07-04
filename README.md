# Heart Disease Classification (Python)

A Naive Bayes classifier implemented entirely from scratch in Python, with no machine-learning libraries, and applied to heart disease prediction from clinical data. The emphasis of the project is on the underlying probabilistic mechanics: estimating priors and likelihoods directly from data, combining categorical and continuous features in a single framework, and handling the practical issues of numerical stability and missing values.

## Overview

The classifier predicts a patient's disease category from a mix of clinical measurements, some categorical (such as chest-pain type and resting ECG results) and some continuous (such as age, cholesterol, and maximum heart rate). This mixture of feature types, together with missing values in the data, motivates the main design choices in the implementation.

## Method

The model is a Naive Bayes classifier built on Bayes' theorem and the conditional-independence assumption between features. Key implementation details:

- **Class priors** estimated from the training data with Laplace smoothing.
- **Discrete features** modeled with Laplace-smoothed categorical distributions, so unseen category/class combinations never receive zero probability.
- **Continuous features** modeled with class-conditional Gaussian distributions, with a small variance floor to avoid numerical issues.
- **Log-space computation** — likelihoods are summed as log-probabilities rather than multiplied, preventing floating-point underflow.
- **Native missing-value handling** — missing entries are skipped in the per-instance likelihood rather than imputed or dropped, so no records are discarded.

Prediction assigns each instance to the class with the highest sum of the log-prior and the observed log-likelihood terms.

## Results

| Dataset | Accuracy |
|---------|----------|
| Training set (80%) | 66.5% |
| Test set (20%) | 63.9% |

The small gap between training and test accuracy indicates the model is not overfitting. The modest overall accuracy reflects the strong conditional-independence assumption, the Gaussian approximation for continuous features, a multi-class target, and a relatively small dataset. The goal of the project is a transparent, correct from-scratch implementation rather than maximizing predictive performance.


## Dataset

Heart disease dataset with a mix of categorical and continuous clinical features and a one-hot encoded disease-category target. See the report for a full description of the features.

## Repository Contents

```
naive-bayes-classifier/
├── README.md
├── naive_bayes.ipynb   # notebook: loads data, runs the classifier, shows results
└── report.pdf          # Full write-up: model, derivation, and results
```

## Tech

Python · probabilistic modeling · classification (from scratch, no ML libraries)
