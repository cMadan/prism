---
title: 'Prism: Multiple spline regression with regularization, dimensionality reduction, and feature selection'
tags:
  - regression
  - smoothing spline
  - matlab
  - pca
  - relevance vector machine
  - multiple regression
  - lasso
authors:
 - name: Christopher R Madan
   orcid: 0000-0003-3228-6501
   affiliation: Boston College
date: 26 June 2016
bibliography: paper.bib
---

# Summary

Prism uses a combination of statistical methods to conduct spline-based multiple regression. Prism conducts this regression using regularization, dimensionality reduction, and feature selection, through a combination of smoothing spline regression, PCA, and RVR/LASSO. Smoothing splines can be used to model non-parametric relationships using piece-wise cubic functions [@WahbWold1975; @fox2000nonparametric]. Relevance vector regression (RVR) refers to application of a relevance vector machine (RVM) to a regression problem; broadly, RVM is similar to multiple linear regression with regularization, using automatic relevance determination for feature selection [@Tipp2000]. RVM shares many commonalities with SVM, and is implemented as a special case of a Sparse Bayesian framework [@Tipp2001; @FaulTipp2003].

Prism has been tested in MATLAB 2015b and requires three first-party toolboxes: (1) Curve Fitting Toolbox; (2) Statistics and Machine Learning Toolbox; (3) Signal Processing Toolbox. Relevance vector regression requires the SparseBayes V2 toolbox, which can be obtained from http://www.relevancevector.com.

-![Illustration of Prism regression procedure, first conducting spline regression for each predictor, followed by dimensionality reduction and feature selection (panel A). The logo for Prism is shown in panel B.](fig1_prism.png)

Prism was implemented for conducting multiple regression investigating age-related differences in brain morphology. While linear and quadratic regression are often used (e.g., [@SoweEtal2003; @HogsEtal2013; @MadaKens2016]), it has been shown that non-linear (spline) regression is more appropriate [@FjelEtal2010; @FjelEtal2013].

# References
