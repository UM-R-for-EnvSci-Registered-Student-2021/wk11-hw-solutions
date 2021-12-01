---
title: "Week 11 - Assignment"
author: "Jose Luis Rodriguez Gil"
date: "24/11/2021"
output: 
  html_document:
    number_sections: true
    keep_md: true
---








# Read the data

The first thing we need to do is to read all the available data. We have data fro three sites collected over multiple years, with each year in its own `.csv` file. The table in each file does not contain a column called "year", the only reference to the year is in the file name. We want to examine temporal trends, so we need to incorporate the year information in the final data, as such, we also need to gather that information form the file name into its own column of the final data set.


```r
kelp_data <- tibble(files = fs::dir_ls(here("data"))) %>%  # we create a tibble of files in that folder
  mutate(data = pmap(list(files), 
                     ~ read_csv(..1, col_names = TRUE, na = c("-99999")))) %>%  # We load each individual file as a tibble-within-a-tibble
  mutate(data = pmap(list(files, data), 
                     ~ mutate(..2, source_file = as.character(..1)))) %>% # To each individual dataset we add the name of the file it came from (for reference)
  select(data) %>% # select only the actual data tibbles
  map_df(bind_rows) %>%  # bind them all into one tibble
  clean_names() %>%  # clean the column names 
    mutate(year = stringr::str_extract(source_file, "(?<=Kelp_NPP_)[:digit:]{4}")) %>% # extract the date using regex
  select(-source_file) %>%  # we dont need it anymore 
  mutate(year = as.numeric(year)) # because year was treated as a string, but we need it to be numeric in order to plot it.


print(kelp_data)
```

```
## # A tibble: 210 × 15
##    site  season   npp_dry npp_carbon npp_nitrogen growth_rate_dry growth_rate_car…
##    <chr> <chr>      <dbl>      <dbl>        <dbl>           <dbl>            <dbl>
##  1 ABUR  3-Summer 0.0299    0.00845     0.000625           0.0266           0.0253
##  2 ABUR  4-Autumn 0.0188    0.00473     0.000409           0.0262           0.0254
##  3 AQUE  3-Summer 0.0377    0.00913     0.000361           0.0329           0.0298
##  4 AQUE  4-Autumn 0.0173    0.00452     0.000385           0.0221           0.0223
##  5 MOHK  3-Summer 0.0473    0.0129      0.000752           0.0348           0.0365
##  6 MOHK  4-Autumn 0.0228    0.00574     0.000363           0.0334           0.0321
##  7 ABUR  1-Winter 0.00659   0.00186     0.000122           0.0463           0.0478
##  8 ABUR  2-Spring 0.00393   0.00122     0.000104           0.0334           0.0347
##  9 ABUR  3-Summer 0.00249   0.000847    0.0000524          0.0281           0.0287
## 10 ABUR  4-Autumn 0.00329   0.000892    0.0000756          0.0354           0.0324
## # … with 200 more rows, and 8 more variables: growth_rate_nitrogen <dbl>,
## #   se_npp_dry <dbl>, se_npp_carbon <dbl>, se_npp_nitrogen <dbl>,
## #   se_growth_rate_dry <dbl>, se_growth_rate_carbon <dbl>,
## #   se_growth_rate_nitrogen <dbl>, year <dbl>
```


# Model fits

Now we are going to run the `lm()` for `npp_dry` vs `year`. In order to make the results easier to handle, we want to extract the most relevant data from these models into their own columns. 


```r
kelp_data_and_lm <- kelp_data %>% 
  group_by(site) %>% 
  nest() %>% 
  mutate(model = pmap(list(data),
                   ~ lm(npp_dry ~ year, data = ..1))) %>%  # Main model fit
  mutate(intercept = map_dbl(.x = model,
                             ~ round(tidy(.x)$estimate[1], digits = 3)), # extract the intercept into its own column
         slope = map_dbl(.x = model,
                         ~ round(tidy(.x)$estimate[2], digits = 4)), # extract the slope into its own column
         r_squared = map_dbl(.x = model,
                             ~ round(glance(.x)$r.squared, digits = 3)), # extract the r_squared into its own column
         p_value = map_dbl(.x = model,
                           ~ round(glance(.x)$p.value, digits = 3)) # extract the p_value into its own column
  )

print(kelp_data_and_lm)
```

```
## # A tibble: 3 × 7
## # Groups:   site [3]
##   site  data               model  intercept   slope r_squared p_value
##   <chr> <list>             <list>     <dbl>   <dbl>     <dbl>   <dbl>
## 1 ABUR  <tibble [70 × 14]> <lm>       0.499 -0.0002     0.079   0.019
## 2 AQUE  <tibble [70 × 14]> <lm>       1.90  -0.0009     0.427   0    
## 3 MOHK  <tibble [70 × 14]> <lm>       1.03  -0.0005     0.065   0.034
```

Now let's format it a bit with `gt()` so it is easier to read by humans. One "problem" here is that we have the columns `data` and `model` wich are filled with datasets. Those cannot be placed in a regular table, so we will remove them before we apply `gt()`


```r
kelp_data_and_lm %>% 
  select(-data, -model) %>% 
  gt() %>% 
  tab_header(
    title = md("**Change on Giant Kelp NPP**"),
    subtitle = "Summary of the regression of Giant Kelp NPP vs time for the three studied sites")
```

```{=html}
<div id="ulvequjbhg" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#ulvequjbhg .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#ulvequjbhg .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ulvequjbhg .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#ulvequjbhg .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#ulvequjbhg .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ulvequjbhg .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ulvequjbhg .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#ulvequjbhg .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#ulvequjbhg .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#ulvequjbhg .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#ulvequjbhg .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#ulvequjbhg .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#ulvequjbhg .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#ulvequjbhg .gt_from_md > :first-child {
  margin-top: 0;
}

#ulvequjbhg .gt_from_md > :last-child {
  margin-bottom: 0;
}

#ulvequjbhg .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#ulvequjbhg .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#ulvequjbhg .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ulvequjbhg .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#ulvequjbhg .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ulvequjbhg .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#ulvequjbhg .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#ulvequjbhg .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ulvequjbhg .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ulvequjbhg .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#ulvequjbhg .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ulvequjbhg .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#ulvequjbhg .gt_left {
  text-align: left;
}

#ulvequjbhg .gt_center {
  text-align: center;
}

#ulvequjbhg .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#ulvequjbhg .gt_font_normal {
  font-weight: normal;
}

#ulvequjbhg .gt_font_bold {
  font-weight: bold;
}

#ulvequjbhg .gt_font_italic {
  font-style: italic;
}

#ulvequjbhg .gt_super {
  font-size: 65%;
}

#ulvequjbhg .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  <thead class="gt_header">
    <tr>
      <th colspan="4" class="gt_heading gt_title gt_font_normal" style><strong>Change on Giant Kelp NPP</strong></th>
    </tr>
    <tr>
      <th colspan="4" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style>Summary of the regression of Giant Kelp NPP vs time for the three studied sites</th>
    </tr>
  </thead>
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">intercept</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">slope</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">r_squared</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">p_value</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <td colspan="4" class="gt_group_heading">ABUR</td>
    </tr>
    <tr><td class="gt_row gt_right">0.499</td>
<td class="gt_row gt_right">-2e-04</td>
<td class="gt_row gt_right">0.079</td>
<td class="gt_row gt_right">0.019</td></tr>
    <tr class="gt_group_heading_row">
      <td colspan="4" class="gt_group_heading">AQUE</td>
    </tr>
    <tr><td class="gt_row gt_right">1.897</td>
<td class="gt_row gt_right">-9e-04</td>
<td class="gt_row gt_right">0.427</td>
<td class="gt_row gt_right">0.000</td></tr>
    <tr class="gt_group_heading_row">
      <td colspan="4" class="gt_group_heading">MOHK</td>
    </tr>
    <tr><td class="gt_row gt_right">1.034</td>
<td class="gt_row gt_right">-5e-04</td>
<td class="gt_row gt_right">0.065</td>
<td class="gt_row gt_right">0.034</td></tr>
  </tbody>
  
  
</table>
</div>
```

# Plots

Now that we have a consolidated tibble with the data, the models, and the main descriptors of the regression, we can use this to create our plots.


```r
kelp_plot <- kelp_data_and_lm %>% 
  mutate(plot = pmap(list(data, site, intercept, slope, r_squared),
                     ~ ggplot() +
                       geom_point(data = ..1, aes(x = year, y = npp_dry), alpha = 0.4, stroke = 0) +
                       geom_smooth(data = ..1, aes(x = year, y = npp_dry), method = "lm", colour = "grey20", size = 0.3) +
                       
                       annotate(geom = "text",
                                x = 2015,
                                y = 0.045,
                                label = str_c("y = ", ..3, " + ", ..4 ,"x", sep = ""),
                                hjust = 0,
                                vjust = 0,
                                size = 2.5) +
                       
                       annotate(geom = "text",
                                x = 2015,
                                y = 0.045,
                                label = str_c('R^2 == ', ..5),
                                parse = TRUE,
                                hjust = 0,
                                vjust = 1.5, 
                                size = 2.5) +
                       
                       coord_cartesian(xlim = c(min(kelp_data$year, na.rm = TRUE), max(kelp_data$year, na.rm = TRUE)),
                                       ylim = c(0, max(kelp_data$npp_dry, na.rm = TRUE)),
                                       expand = expansion(mult = 0, add = 0)) +
                       
                       labs(title = str_c("Site:", ..2, sep = " "),
                            x = NULL,
                            y = expression("Net primary production of"~italic("M. pyrifera")~ "dry mass" ~(kg~.~m^{-2}~.~d^{-1})))),
         
         filename = str_c(site, "_plot.pdf", sep = "")) %>% 
  ungroup() %>% 
  select(plot, filename)

kelp_plot
```

```
## # A tibble: 3 × 2
##   plot   filename     
##   <list> <chr>        
## 1 <gg>   ABUR_plot.pdf
## 2 <gg>   AQUE_plot.pdf
## 3 <gg>   MOHK_plot.pdf
```


Now that we have a simplified tibble with just the plots and the given file names, i can use `pwalk()` to walk through the list and apply `ggsave()` to each of them


```r
kelp_plot %>% 
  pwalk(ggsave,                    # what we want to do as we walk thorugh the object   
        path =  here("figures"),   # where we want to save it
        width = 120, height = 120, units = "mm") # other things you need for ggsave
```

```
## `geom_smooth()` using formula 'y ~ x'
```

```
## Warning: Removed 1 rows containing non-finite values (stat_smooth).
```

```
## Warning in if (!expand) {: the condition has length > 1 and only the first
## element will be used

## Warning in if (!expand) {: the condition has length > 1 and only the first
## element will be used
```

```
## Warning: Removed 1 rows containing missing values (geom_point).
```

```
## `geom_smooth()` using formula 'y ~ x'
```

```
## Warning: Removed 1 rows containing non-finite values (stat_smooth).
```

```
## Warning in if (!expand) {: the condition has length > 1 and only the first
## element will be used

## Warning in if (!expand) {: the condition has length > 1 and only the first
## element will be used
```

```
## Warning: Removed 1 rows containing missing values (geom_point).
```

```
## `geom_smooth()` using formula 'y ~ x'
```

```
## Warning: Removed 1 rows containing non-finite values (stat_smooth).
```

```
## Warning in if (!expand) {: the condition has length > 1 and only the first
## element will be used

## Warning in if (!expand) {: the condition has length > 1 and only the first
## element will be used
```

```
## Warning: Removed 1 rows containing missing values (geom_point).
```

