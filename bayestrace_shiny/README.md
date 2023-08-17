# BayesTrace

This is a diagnostic/visualization tool for [BayesTraits](http://www.evolution.reading.ac.uk/BayesTraitsV4.0.1/BayesTraitsV4.0.1.html) output.

The aim is to produce a standardized report that can be useful for interpreting results from MCMC runs, but also to accompany research papers as supplementary materials.

BayesTraits v4 can run 10 different models:

1)	MultiState
2)	Discrete: Independent
3)	Discrete: Dependant
4)	Continuous: Random Walk (Model A)
5)	Continuous: Directional (Model B)
6)	Continuous: Regression
7)	Independent Contrast
8)	Independent Contrast: Correlation
9)	Independent Contrast: Regression
10)	Discrete: Covarion
12)	Fat Tail
13)	Geo

So far, BayesTrace can generate reports for Multistates and Discrete models  (i.e. options 1 to 3) for the MCMC method.


### Features under developlemnt

- [ ] Improve root state pie chart (make interactive)
- [ ] Improve phylogeny representation (ggtree + plotly, or network3d dendrogram)
- [ ] Add pGLS features
- [ ] Transition Rate Densities - fix middle rows, which are always a little squashed with plotly
- [ ] Generate reports for more BayesTraits models
