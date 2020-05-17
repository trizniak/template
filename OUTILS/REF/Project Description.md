**[Project Name]**
================

[ DETAILS ]

-----

# FOLDERS
* *DATA* : all data files (external + saved .Rdata)
* *OUTILS*
  + *BLOX* : output building blocks (.Rmd)
  + *CONFIG* : SETUP.R, UPDATES.R, param.rds
  + *FUNS* : scripts
  + *MIX* : various miscellanea (images, logos, ...)
  + *REF* : references (this document, EU countries & protocol order)


# SCRIPTS
* **_MAIN** : core project script
* CONFIG
  + *SETUP* : packages & personalization (theme, color palettes, label color function, EU countries, ...)
  + *UPDATES* : updating original input data (output : *DATAFILE.Rdata*)
* FUNS
  + *DATA_* : Main data files (incl. data.breaks)
  + *Fdx_* : descriptors (titles, legends, captions, ...)
  + *Fpam_* : Processing, Analysis, Modeling
  + *Ftab_* : Tables
  + *Fviz_* : Visualizations

-----

# Names : File , Variable , Function

## Files
* *data.Rdata* : main project data, including ONLY variables and cases used in the analysis
* *DATAFILE.Rdata* : COMPLETE data file, based on original input data, withh all supplementary variables
* *data* : main project data
* *data.x* : intermediate data set
* *data.viz* : data set used for visualization
* *data.XT* : shared data (crosstalk)
* *param.rds* : key project parameteres that need to be consistent across analyses and data processing steps
* [MIX] *KB* : Knowledge Base (code snippets, links to relevant articles)

## Variables
* *l_* : level
* *s_* : share
* *y_* : Year-on-Year (YoY) change
  
## Functions
* *F.data.* : data
* *F.pam.* : Processing, Analysis, Modeling
* *F.tab.* : table
* *F.viz.* : visualization

-----
