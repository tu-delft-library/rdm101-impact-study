# **RDM101 impact study**

This repository contains the R scripts used to preprocess, analyse, and visualise the data underlying the RDM101 Impact Study at TU Delft. The scripts support the mixed-methods analysis presented in the RDM101 Impact Study report and reproduce all quantitative and qualitative processing steps that do not involve confidential raw data. The code includes:

-   Data preprocessing workflows for pre- and post-training surveys and GS feedback forms

-   Calculation of descriptive statistics and pre/post-training comparisons

-   Functions used to generate category frequencies

-   Visualisation scripts used for figures in the report

The scripts are written in R (4.2.2) and make use of packages such as readxl, dplyr, ggplot2, stringr, tidyr, stringdist, tidyverse, tm, wordcloud2, writexl, cluster, patchwork, viridis.

A complete list of package dependencies is provided in the README files for the two analyses. No confidential or identifying information is embedded in the code. Raw datasets from Graduate School feedback forms and surveys are not included in this repository due to privacy restrictions. Instead, placeholder file paths and template structures are provided to enable users to understand the workflow and adapt it to their datasets if appropriate.

This code repository is intended to support transparency and reproducibility of the analytical workflow and to complement the published report and accompanying data.

**Acknowledgements**

We would like to thank Elviss Dvinskis and Selin Kubilay for their help with the analysis and contributions to it.

**Author**: Nikki Grens
