# ---- SETUP ----

# Code appearance ([Tools] [Global Options] [Appearance]) : Tomorrow Night Blue

options(repr.plot.width=49,
	repr.plot.height=36,
	scipen=999,
	digits=1,
	warn=-1)
my.color="#273749" # 214263 0B4279 0b2131 1b3142


# ---- PACKAGES ----
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
        devtools,	#[.KEY]		https://cran.r-project.org/web/packages/devtools/index.html
        here,		#[.KEY]		https://cran.r-project.org/web/packages/here/index.html
        readr,		#[.KEY]		https://cran.r-project.org/web/packages/readr/index.html
        scales,		#[.KEY]		https://cran.r-project.org/web/packages/scales/index.html
        # smacof,	#[ANALYTICS]	https://cran.r-project.org/web/packages/smacof/index.html
        # pheatmap,	#[ANALYTICS]	https://cran.r-project.org/web/packages/pheatmap/index.html
        # docxtractr,	#[DATA]		https://cran.r-project.org/web/packages/docxtractr/index.html
        eurostat,	#[DATA]		https://cran.r-project.org/web/packages/eurostat/index.html
        # readxl,	#[DATA]		https://cran.r-project.org/web/packages/readxl/index.html
        # restatapi,	#[DATA]		https://cran.r-project.org/web/packages/restatapi/index.html
        # crosstalk,	#[INTERACTIVE]	https://cran.r-project.org/web/packages/crosstalk/index.html
        extrafont,	#[OUTILS]	https://cran.r-project.org/web/packages/extrafont/index.html
        # glue,		#[OUTILS]	https://cran.r-project.org/web/packages/glue/index.html
        janitor,	#[OUTILS]	https://cran.r-project.org/web/packages/janitor/index.html
        # DT,		#[TAB]		https://cran.r-project.org/web/packages/DT/index.html
        # kableExtra,	#[TAB]		https://cran.r-project.org/web/packages/kableExtra/index.html
        # reactable,	#[TAB]		https://cran.r-project.org/web/packages/reactable/index.html
        # dtwclust,	#[TIME SERIES]	https://cran.r-project.org/web/packages/dtwclust/index.html
        # fable,        #[TIME SERIES]	https://cran.r-project.org/web/packages/fable/index.html
        # feasts,	#[TIME SERIES]	https://cran.r-project.org/web/packages/feasts/index.html
        # slider,	#[TIME SERIES]	https://cran.r-project.org/web/packages/feasts/index.html
        # tsibble,	#[TIME SERIES]	https://cran.r-project.org/web/packages/tsibble/index.html
        # urca,        	#[TIME SERIES]	https://cran.r-project.org/web/packages/urca/index.html
        # zoo,       	#[TIME SERIES]	https://cran.r-project.org/web/packages/zoo/index.html
        ggiraph,	#[VIZ]		https://cran.r-project.org/web/packages/ggiraph/index.html
        # ggplotify,	#[VIZ]		https://cran.r-project.org/web/packages/ggplotify/index.html
        # ggpubr,	#[VIZ]		https://cran.r-project.org/web/packages/ggpubr/index.html
        # ggrepel,	#[VIZ]		https://cran.r-project.org/web/packages/ggrepel/index.html
        # gplots,	#[VIZ]		https://cran.r-project.org/web/packages/gplots/index.html
        ggtext,		#[VIZ]		https://cran.r-project.org/web/packages/ggtext/index.html
        # highcharter,	#[VIZ]		https://cran.r-project.org/web/packages/highcharter/index.html
        patchwork,	#[VIZ]		https://cran.r-project.org/web/packages/patchwork/index.html
        # plotly,	#[VIZ]		https://cran.r-project.org/web/packages/plotly/index.html
        # plotrix,	#[VIZ]		https://cran.r-project.org/web/packages/plotrix/index.html
        # ragg,        	#[VIZ]		https://cran.r-project.org/web/packages/ragg/index.html
        tidyverse	#[.KEY]]	https://cran.r-project.org/web/packages/tidyverse/index.html
)


# ---- THEME ----
my.theme = function() {
  theme_minimal() +
    theme(text=element_text(family="Calibri",
			    color=my.color),
          axis.line.x.bottom=element_blank(), # to remove : axis.line is ignored
          axis.line.y.left=element_blank(), # to remove : axis.line is ignored
          axis.text=element_blank(),
          axis.ticks=element_blank(),
          axis.title=element_text(face="italic"),
          legend.title=element_blank(),
          panel.background=element_blank(),
          panel.border=element_rect(size=0.1,fill=NA),
          panel.grid=element_blank(),
          panel.spacing=unit(0.1,"lines"),
          plot.title=element_markdown(),
          plot.title.position="plot",
          plot.subtitle=element_markdown(),
          strip.background=element_blank(),
          strip.placement="outside",
          strip.text=element_text(color=my.color,
				  face="italic"))
}
theme_set(my.theme())
# FONTS ----
# extrafont::font_import(prompt=FALSE)

# ---- Color Palette : Age groups ----
# 6 groups
palette.AgeG6=c("royalblue4",
		"brown4",
		"darkorange",
		"gold",
		"tan",
		"khaki4",
		"darkgreen")
# scales::show_col(palette.AgeG6)
names(palette.AgeG6)=c("ALL",
		       "<18",
		       "18-24",
		       "25-34",
		       "35-54",
		       "55-64",
		       "65+")
# 4 groups
palette.AgeG4=c("royalblue4",
		"brown4",
		"gold",
		"khaki4",
		"darkgreen")
# scales::show_col(palette.AgeG4)
names(palette.AgeG4)=c("ALL",
		       "<18",
		       "18-34",
		       "35-64",
		       "65+")

# ---- Color Palette : Clusters ----
palette.clu = c("firebrick",
		"mediumorchid4",
		"forestgreen",
		"darkblue")
# scales::show_col(palette.clu)


# ---- FUNCTION : Label Color ----
f.label.color = function(x,
			 color.negative="red",
			 color.neutral="grey",
			 color.pozitive="green4") {
  paste0("<b><span style='color:",
	 case_when(x<0~color.negative,
                   x>0~color.pozitive,
                   TRUE~color.neutral),
         "'>",x,"</span>")}
# scale_y_continuous(labels=function (X) f.label.color(X,"midnightblue","#273749","magenta") / labels=f.label.color)


# ---- FUNCTION : Pretty Rounding ----
f.pretty.round = function (x,step=5) {
  E=ifelse(x==0,0,floor(log10(abs(x))-1))
  F=x/10^E
  step*ceiling(F/step)*10^E
}


# ---- FUNCTION : Scale / RUI limits ----
f.lim = function (data,
                  ind.t,
                  symm=FALSE) { # are the limits symmetric?
  # For a function argument defined as itself, specify the argument in the call instead of the definition.
  # https://stackoverflow.com/questions/4357101/promise-already-under-evaluation-recursive-default-argument-reference-or-earlie
  lim = data %>%
    mutate(v.p=ifelse(YOY>0,f.pretty.round(pmax(y_RUI.HI,YOY+2*y_SD,na.rm=TRUE),
                                           step=5),0),
           v.n=ifelse(YOY<0,f.pretty.round(pmin(y_RUI.lo,YOY-2*y_SD,na.rm=TRUE),
                                           step=5),0)) %>%
    summarize(n=min({if (ind.t=="INEQ") -4 else -10},
                    min(v.n,na.rm=TRUE)),
              p=max({if (ind.t=="INEQ") 4 else 10},
                    max(v.p,na.rm=TRUE))) %>%
    unlist()
  if (symm) c(n=-max(abs(lim)),p=max(abs(lim))) else lim
}


# ---- FUNCTION : DATA (NS / SILC.noSIG / SILC.SIG / FE.noSIG / FE.SIG / FE.cens[+] / FE.cens[-]) ----
f.data.censig = function (data,
                        palette=palette.overview) {
  
  is.SILC=NROW(subset(data,SOURCE=="SILC"))>0 & length(palette)>6
  data %>%
    mutate(source.censig=factor(case_when(SOURCE=="FE" & cens==0 & SIG==0 ~
                                            names(palette)[3],
                                          SOURCE=="FE" & cens==0 & SIG==1 ~
                                            names(palette)[4],
                                          SOURCE=="FE" & cens==1 & YOY<0 ~
                                            names(palette)[ifelse(INDICATOR %in% c("AROP","QSR"),5,6)],
                                          SOURCE=="FE" & cens==1 & YOY>0 ~
                                            names(palette)[ifelse(INDICATOR %in% c("AROP","QSR"),6,5)],
                                          if (is.SILC) SOURCE=="SILC" & SIG==0 ~
                                            names(palette)[7],
                                          if (is.SILC) SOURCE=="SILC" & SIG==1 ~
                                            names(palette)[8]),
                       levels=names(palette)))
}


# ---- FUNCTION : RUI segments ----
f.data.RUI = function(data,
                      n=RUI.segments) {
  data = data %>%
    mutate(y_hRUI=ifelse(SOURCE=="FE" & cens==0,
                         (y_RUI.HI-y_RUI.lo)/2,
                         0),
           y_cRUI=ifelse(SOURCE=="FE" & cens==0,
                         (y_RUI.HI+y_RUI.lo)/2,
                         0))
  
  for (i in 1:n) {
    data = data %>%
      mutate("y_hRUI.{i}":=ifelse(SOURCE=="FE" & cens==1,
                                  (y_RUI.HI-y_RUI.lo)/(2*n),
                                  0),
             "y_cRUI.{i}":=ifelse(SOURCE=="SILC",NA,
                                  y_RUI.lo+!!as.name(paste0("y_hRUI.",i))*(2*i-1)),
             "y_hRUI.{i}":=!!as.name(paste0("y_hRUI.",i))*ifelse(cens==1,(1-(i-1)/n),
                                                                 {if (i==1) 1 else 0}),
             "alpha_RUI.{i}":=ifelse(SOURCE=="SILC",NA,
                                     0.77*(1-(i-1)/(n))^2))
  }
  data
}


# ---- LABELS : INDICATOR ----
INDICATOR.lab =
  c(AROP="At-risk-of-poverty rate (AROP)",
    INWORK="In-work poverty",
    QSR="Quintile Share Ratio (QSR)",
    MEDIAN="Median income",
    D1="Income decile 1 (D1)",
    D3="Income decile 3 (D3)",
    D7="Income decile 7 (D7)",
    D9="Income decile 9 (D9)")


# ---- EU MS : Protocol Order ----
EU.PO = read_delim(here("OUTILS","REF","EU.PO.txt"),"\t",
		   escape_double=FALSE,
		   trim_ws=TRUE) %>%
  as.data.frame() %>%
  filter(COUNTRY!="UK")
country.list=c(as.list(unique(as.character(EU.PO$COUNTRY))),"EU")
