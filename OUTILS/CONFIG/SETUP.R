# ---- SETUP ----

# Code appearance ([Tools] [Global Options] [Appearance]) : Tomorrow Night Blue

# FOLDERS
# folders=c("DATA","OUTILS","OUTPUT","T E M P","WHOREHOUSE");for (i in 1:length(folders)) {dir.create(paste("../",folders[i], sep="/"))}

options(repr.plot.width=49,repr.plot.height=36,scipen=999,digits=1,warn=-1)
my.color="#273749" # 214263 0B4279 0b2131 1b3142


# ---- PACKAGES ----
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, # always first
               devtools,crosstalk,docxtractr,eurostat,ggpubr,kableExtra,reactable,
               highcharter,plotly,pheatmap,gplots,dtwclust,ggrepel,smacof,DT,
               readr,readxl,restatapi,scales,glue,patchwork,here,ggplotify)

pacman::p_load_gh("wilkelab/ggtext","clauswilke/gridtext") # "jokergoo/ComplexHeatmap"


# ---- THEME ----
my.theme = function() {
  theme_minimal() +
    theme(text=element_text(family="Calibri",color=my.color),
          panel.background=element_blank(),
          panel.spacing=unit(0.1,"lines"),
          panel.border=element_rect(size=0.1,fill=NA),
          panel.grid=element_blank(),
          strip.background=element_blank(),
          strip.placement="outside",
          strip.text=element_text(color=my.color,face="italic"),
          plot.title.position="plot",
          plot.title=element_markdown(),
          plot.subtitle=element_markdown(),
          axis.line.x.bottom=element_line(color="grey",size=.3), # set as element_blank to remove : axis.line is ignored
          axis.line.y.left=element_line(color="grey",size=.3), # set as element_blank to remove : axis.line is ignored          axis.title=element_text(face="italic"),
          axis.ticks=element_blank(),
          axis.text=element_blank(),
          legend.title=element_blank())
}

theme_set(my.theme())


# ---- Color Palette : Age groups ----
palette.AgeG = c("royalblue4","brown4","darkorange","gold","tan","khaki4","darkgreen")#;scales::show_col(palette.AgeG)
names(palette.AgeG) = c("ALL","<18","18-24","25-34","35-54","55-64","65+")

# ---- Color Palette : Clusters ----
palette.clu = c("firebrick","mediumorchid4","forestgreen","darkblue")#;scales::show_col(palette.clu)


# ---- FUNCTION : Label Color ----

f.label.color = function(x,color.neg="green3",color.poz="red") {
  paste0("<b><span style='color:",
         case_when(x<0~color.neg,
                   x>0~color.poz,
                   TRUE~"#273749"),
         "'>",x,"</span>")}

# ---- EU MS : Protocol Order ----
# UPLOAD to OUTILS/REF : \\net1.cec.eu.int\ESTAT\F\1\common\03 flash estimates\BOGDAN\EU.PO.txt
EU.PO = read_delim(here("OUTILS","REF","EU.PO.txt"),
                   "\t",escape_double=FALSE,trim_ws=TRUE) %>%
  as.data.frame() %>%
  filter(COUNTRY!="UK")

country.list=c(as.list(unique(as.character(EU.PO$COUNTRY))),"EU")
