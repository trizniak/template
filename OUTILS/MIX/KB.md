**Knowledge Base** {.tabset .tabset-pills}
================

## Links to relevant articles

-----

* **Colors**
  + [HTML color codes](https://htmlcolorcodes.com/)
  + [R colors](http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf)
* **RMarkdown**
  + [**Basic Syntax**](https://www.markdownguide.org/basic-syntax/)
  + [<span style="color:DarkRed">Dynamic Title</span>](https://stackoverflow.com/questions/52540279/dynamic-rmarkdown-title-from-r-code-chunk)
  + [Unicode characters](https://jrgraphix.net/r/Unicode)
  + [Repeating child block with changing variable value](https://gist.github.com/rmoff/a043676a2f084b81a434)
* **Plotly**
  + [Linking two charts : Interactive data visualization](https://s3.amazonaws.com/assets.datacamp.com/production/course_7193/slides/chapter3.pdf)
  + [Set hovermode to *compare data on hover*](https://stackoverflow.com/questions/46730394/r-set-plotly-hovermode-to-compare-data-on-hover)
  + [Multiple filters and drop down menus](https://stackoverflow.com/questions/51718742/multiple-filters-and-drop-down-menus-for-plotly-in-r)
  + [Customize ModeBar buttons](https://stackoverflow.com/questions/37437808/how-to-custom-or-display-modebar-in-plotly)
* **DataTable (DT)**
  + [Bi-directional Color Bar](https://stackoverflow.com/questions/33521828/stylecolorbar-center-and-shift-left-right-dependent-on-sign)


## OUTILS [outside R]

-----

* [web scraping] the [SelectorGadget chrome extension](https://chrome.google.com/webstore/detail/selectorgadget/mhjhnkcfbdhnjickkkdbjoemdmbfginb?hl=en) could isolate the individual html node.


## Code snippets  {.tabset .tabset-dropdown}

### [RMarkdown] <span style="color:DarkRed">Dynamic Title</span>

      ---
      output: html_document
      title: '`r days <- 60; paste0(days, " Days")`' # note the ; between lines of code
      ---
      
    -------------
    SOURCE : https://stackoverflow.com/questions/52540279/dynamic-rmarkdown-title-from-r-code-chunk


### [Plotly] Customize ModeBar buttons

      ggplotly() %>% config(displaylogo=FALSE,  
          modeBarButtonsToRemove=list(  
          "sendDataToCloud",  
          "toImage",  
          "autoScale2d",  
          "resetScale2d",  
          "hoverClosestCartesian",  
          "hoverCompareCartesian",
          "zoom2d",
          "pan2d",
          "select2d",
          "lasso2d",
          "zoomIn2d",
          "zoomOut2d"))  
      modeBarButtonsToAdd=list()
 

### [Crosstalk] Checkbox filters

      bscols(widths=c(...,NA),
       list(filter_checkbox(id="...",label="...",
                            sharedData=...,group=~...,inline=FALSE)),
       ggplotly(...))


### [Multi-Dimensional Scaling]

      # Classical MDS
      # N rows (objects) x p columns (variables)
      # each row identified by a unique row name

      d <- dist(mydata) # euclidean distances between the rows
      fit <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim
      fit # view results

      # plot solution
      x <- fit$points[,1]
      y <- fit$points[,2]
      plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2",
        main="Metric MDS", type="n")
      text(x, y, labels = row.names(mydata), cex=.7)
      
    -------------
    SOURCE : https://www.statmethods.net/advstats/mds.html


### [DataTable (DT)] Bi-directional Color Bar

      make a custom styleColorBar function that uses the CSS gradients (same as the original styleColorBar) to make the kind of bars you want.
      ! ! ! adding new lines breaks the CSS):
      color_from_middle <- function (data,color1,color2) {
      max_val=max(abs(data))
      JS(sprintf("isNaN(parseFloat(value)) || value < 0 ? 'linear-gradient(90deg, transparent, transparent ' + (50 + value/%s * 50) + '%%, %s ' + (50 + value/%s * 50) + '%%,%s  50%%,transparent 50%%)': 'linear-gradient(90deg, transparent, transparent 50%%, %s 50%%, %s ' + (50 + value/%s * 50) + '%%, transparent ' + (50 + value/%s * 50) + '%%)'",
      max_val,color1,max_val,color1,color2,color2,max_val,max_val))
      }
      
      Using some test data:
      data <- data.frame(a=c(rep("a",9)),value=c(-4,-3,-2,-1,0,1,2,3,4))
      datatable(data) %>%
      formatStyle('value',background=color_from_middle(data$value,'red','blue'))
      
    -------------
    SOURCE : https://stackoverflow.com/questions/33521828/stylecolorbar-center-and-shift-left-right-dependent-on-sign


### Regression by groups

      data = data %>%
        group_by(...) %>%
        do({
          mod=lm(var.Y~var.X, data=.)
          data.frame(slope=coef(mod)[2])
          }) %>%
        right_join(data)

### Dynamic variables

      for (lag_size in c(1, 5, 10, 15, 20)) {
        new_col_name <- paste0("lag_result_", lag_size)
        grouped_data <- grouped_data %>%
          mutate(!!sym(new_col_name) := lag(Result, n = lag_size, default = NA))
        }
      
      sym(new_col_name) := is a dynamic way of writing lag_result_1 =, lag_result_2 =, etc. when using functions like mutate()
      
    -------------
    SOURCE : https://stackoverflow.com/questions/55940655/how-to-mutate-for-loop-in-dplyr

### [ggplot] Refer to dataframe inside ggplot

      If you wrap the plotting code in {...}, you can use . to specify exactly where the previously calculated results are inserted
      
        df %>% filter(area == "Health") %>% {
        ggplot(.) +    # add . to specify to insert results here
        geom_line(aes(x = as.factor(year), y = value, 
                      group = sub_area, color = sub_area), size = 2) + 
        geom_point(aes(x = as.factor(year), y = value, 
                       group = sub_area, color = sub_area), size = 2) +
        theme_minimal(base_size = 18) + 
        geom_text(data = dplyr::filter(., year == 2016 & sub_area == "Activities"),    # and here
                  aes(x = as.factor(year), y = value, 
                      color = sub_area, label = area), size = 6, hjust = 1)
        }
      
    -------------
    SOURCE : https://stackoverflow.com/questions/44007998/subset-filter-in-dplyr-chain-with-ggplot2

### Self-referent function argument

      For a function argument defined as itself, specify the argument in the call instead of the definition.
      This does not work:
        x = 4
        my.function <- function(x = x){}
        my.function() # recursive error!
      but this does work:
        x = 4
        my.function <- function(x){}
        my.function(x = x) # works fine!
      
    -------------
    SOURCE : https://stackoverflow.com/questions/4357101/promise-already-under-evaluation-recursive-default-argument-reference-or-earlie 
