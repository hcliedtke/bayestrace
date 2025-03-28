# BayesTrace


## The App

A lite version of BayesTrace app can be accessed [here](https://hcliedtke.shinyapps.io/BayesTrace/). 

This is a reporting and diagnostics tool for the popular program [BayesTraits](http://www.evolution.reading.ac.uk/BayesTraitsV4.1.2/BayesTraitsV4.1.2.html). It allows you to dump the plain text outputs of a BayesTraits analysis into a browser-based user interface (a Shiny app) and produce an interactive report with diagnostics metrics, plots and other useful visualization of results.  

BayesTraits can be run in different modes. BayesTrace is able to identify which mode was run and provide adequate outputs

If the same mode was run repeatedly, to check convergence of the MCMC chain, or with slightly different parameters to check e.g. prior sentitivity, these multiple runs (of the same mode) can be uploaded into a single BayesTrace report.

Here are some screen shots of what the interactive reports/dashboards look like:

<img width="839" alt="Screenshot 2024-05-25 at 19 10 33" src="https://github.com/hcliedtke/bayestrace/assets/28728517/39bc3aea-5fcf-4526-a511-76f11c27e5b2">


## Example Dashboards

* Multistates - Ancestral States reconstruction [dashboard](https://rawcdn.githack.com/hcliedtke/bayestrace/388852d5915b63b0cd12e55aa7e150733be16bc2/bayestrace_shiny/BayesTrace/examples/Artiodactyl_multistates_anc_states/BayesTrace_report.html)
* Discrete states - [dashboard](https://rawcdn.githack.com/hcliedtke/bayestrace/1cdf46504ebe67e2789ce7d2137359cd211c0e24/bayestrace_shiny/BayesTrace/examples/Primates_discrete/BayesTrace_report.html#model-comparison---logbf)
* Model comparison - runs with vs. without covarion [dashboard](https://rawcdn.githack.com/hcliedtke/bayestrace/1cdf46504ebe67e2789ce7d2137359cd211c0e24/bayestrace_shiny/BayesTrace/examples/Bird_covarion/BayesTrace_report.html#mcmc-diagnostics)

## Usage

A lite version of BayesTrace can be accessed [here](https://hcliedtke.shinyapps.io/BayesTrace/). This version is limited to 1Gb of memory. A version with more capacity will be launched soon. alternatively, the content of this repository can be cloned/downloaded and the app can be run locally via R-Studio. Those unfamiliar with running shiny apps, see more [here](https://www.r-bloggers.com/2021/04/run-shiny-apps-locally/).

Users need only set the path to the working directory that contain the following mantatory files:

* tree file
* traits file
* .log output file

If available, the following optional files can also be incuded in the directory

* Stones file

Once the BayesTraits outputs have been uploaded, hit "Generate report" to build a .html file with the BayesTrace report.  
