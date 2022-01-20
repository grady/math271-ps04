---
title: "Hawaii Solar Irradiance"
author: "Math 271"
date: "Spring 2022"
output: 
  html_document:
    css: lab.css
    keep_md: true
    theme: lumen
    toc: yes
    toc_float: yes
---



## Solution document setup

Create a solution document and save it as `PS04_solution.Rmd`. Change the knitr options to `keep_md: true`, like in the instructions document. You can edit the intro block by hand, or go to the _gear icon next to knit_ > _output options_ > _advanced_ > check _keep markdown source file_.

Get in the habit of loading all packages in a setup chunk at the top of the file. Add change the chunk options area to have `include=FALSE, warning=FALSE, message=FALSE` to hide all the loading chatter.



## Daily Solar Irradiance for Hawaii

Here is a published collection of data of [solar irradiance](https://figshare.com/articles/dataset/Daily_Incoming_Solar_Radiation_in_Hawaii/5579134)
for the state of Hawaii.

Below is an example of how to download a file from a URL and save it to whatever computer runs the Rmd file. The `if()` statement ensures that the file is not downloaded repeatedly. This is an example of _conditional code execution_. Copy and paste this code into your document.


```r
solar_file <- "daily_solar_radiation.txt"
if( !file.exists(solar_file) )
  download.file("https://ndownloader.figshare.com/files/9700246", solar_file)

raw_solar <- read_csv(solar_file)
```

```
## Rows: 82 Columns: 9139
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr    (4): Station.Name, Sta..ID, Island, Network
## dbl (9134): SKN, LON, LAT, Elev., X1990.01.01, X1990.01.02, X1990.01.03, X19...
## lgl    (1): X1990.05.10
```

```
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

This file is a typical example of raw data that is not in tidy form. By perusing the raw data file I was able to determine that it has several columns of reasonably tidy information, such as measuring station identification tags, Latitude, Longitude, and Elevation. However, then it has thousands of columns with names like `X1990.05.10`, and these columns contain the irradiance data. There are many `NA` (missing data) values for the irradiance. Presumably, some stations did not exist for the entire period of time.


```r
#str(raw_solar, list.len=15, give.attr=FALSE)
raw_solar
```

```
## # A tibble: 82 × 9,139
##      SKN Station.Name Sta..ID Island Network   LON   LAT Elev. X1990.01.01
##    <dbl> <chr>        <chr>   <chr>  <chr>   <dbl> <dbl> <dbl>       <dbl>
##  1  87.9 IPIF         HE281   BI     HECO    -155.  19.7   111          NA
##  2 132.  Spencer      HE282   BI     HECO    -155.  20.0   454          NA
##  3 128.  Laupahoehoe  HE283   BI     HECO    -155.  19.9  1145          NA
##  4 128.  Hakalau      HE284   BI     HECO    -155.  19.8  1665          NA
##  5  93.9 KiholoBay    HE285   BI     HECO    -156.  19.9     2          NA
##  6  69.2 Palamanui    HE286   BI     HECO    -156.  19.7   297          NA
##  7  93   Mamalahoa    HE287   BI     HECO    -156.  19.8   636          NA
##  8  70.7 Puuwaawaa    HE288   BI     HECO    -156.  19.7  1659          NA
##  9  54.8 Thurston     HVT     BI     HavoNet -155.  19.4  1202          NA
## 10  54.9 Ola a        HVO     BI     HavoNet -155.  19.5  1042          NA
## # … with 72 more rows, and 9,130 more variables: X1990.01.02 <dbl>,
## #   X1990.01.03 <dbl>, X1990.01.04 <dbl>, X1990.01.05 <dbl>, X1990.01.06 <dbl>,
## #   X1990.01.07 <dbl>, X1990.01.08 <dbl>, X1990.01.09 <dbl>, X1990.01.10 <dbl>,
## #   X1990.01.11 <dbl>, X1990.01.12 <dbl>, X1990.01.13 <dbl>, X1990.01.14 <dbl>,
## #   X1990.01.15 <dbl>, X1990.01.16 <dbl>, X1990.01.17 <dbl>, X1990.01.18 <dbl>,
## #   X1990.01.19 <dbl>, X1990.01.20 <dbl>, X1990.01.21 <dbl>, X1990.01.22 <dbl>,
## #   X1990.01.23 <dbl>, X1990.01.24 <dbl>, X1990.01.25 <dbl>, …
```

## Pivot and wrangle

1. Use `tidyr::pivot_longer` to pivot all columns that start with "X" into new variables `date` and `irradiance`, dropping all the `NA` values. Save the result in `solar`. (Read the `?pivot_longer` help file.)

2. Fix column names. Some of the column names are a bit ugly and annoying to type. Use `dplr::rename` to rename these columns
    - `Station.Name` to `name`
    - `Sta..ID` to `id`
    - `LON` to `lon`
    - `LAT` to `lat`
    - `Elev.` to `elev`

Note the consistency in capitalization. This is worth your time.

## Time is an illusion, lunchtime doubly so

The remaining portion of the new `date` variable looks like `1990.05.10`, and is a character string. But this string obviously represents a point in time in Year.Month.Day format. _The._ __*Horror.*__

[__Time is a data nightmare.__](https://www.mojotech.com/blog/the-complexity-of-time-data-programming/)
That link only gives you the vague outlines of just the issues that humans have caused through political fractiousness and our insistence on syncing clocks with the passage of the sun in the sky. 
[Nature](https://en.wikipedia.org/wiki/Solar_time) has even 
[more fun](https://en.wikipedia.org/wiki/Sidereal_time) 
and [surprises](https://en.wikipedia.org/wiki/Terrestrial_Time)
in [store for us](https://en.wikipedia.org/wiki/Introduction_to_general_relativity), although those issues are of less practical importance. The primary source of difficulties for most Earthlings are time zones, daylight savings time, and leap days (and leap _seconds_ if you're really into precision). 

By the way, are all your clocks synchronized?

The tidyverse tool for handling dates and times is the `lubridate` package. 
It lubricates dates. Have a gaze at the
[Lubridate cheat sheet](https://rawgit.com/rstudio/cheatsheets/master/lubridate.pdf). Spend some time being boggled by the section _Math with Date-times_ on the second page. If you thought you knew what _11/4/2018 01:30 US/Eastern_ __really__ means, or if you thought that _six hours_ was a pretty cut and dry concept, then I hope you are feeling suitably chastened.


3. Parse the `Date` strings. Read the help and then use the `lubridate::ymd` function with `mutate` to replace the `date` column with interpreted R date objects. 

4. Create a new `Month` variable Read the help and then use `lubridate::month` with `mutate` to create a new variable with the `month` of the observation. Use the appropriate argument to `month` to get names instead of numbers.

:::{.license}
Make sure that you've stored the results of your wrangling manipulations back to the `solar` object. You can either do this by making one big pipe `pivot_longer(...) %>% select(...) %>% mutate(...) %>% ...` or by doing it one line at a time, updating the `solar` object as you go.
:::

## Data exploration

The next couple of exercises are answered with code. You can use a chunk option `result="hide"` to supress the output in your document. This is good for demonstrating code without showing unneeded output.

5. Practice by creating `filter` views of the data on these conditions:
    - Big Island stations only
    - Neighbor island stations (not Oahu)
    - Stations below 1000 ft elevation
    - Stations between 1000 and 2000 ft elevation
    - Measurements in June, July, or August.
    - Big Island stations with a Longitude west of -155.55 degrees. (Basically, West Hawaii.)
 
6. All-data summaries. Use `summarize` to find:
    - `mean` irradiance and its `sd` (standard deviation)
    - `min` and `max` station elevation
 
7. Group summaries. Use `group_by` with `tally` or `summarize` to find:
    - mean irradiance on each island.
    - mean irradiance each month.
    - number of observations for each station id.
    - number of observations for each combination of Island and Network.
    - The date of the first and last record at each station. 
      + Cue Jaws theme music.
        + It's not really that bad. Use `min` and `max`.

Answer this one with code and text.

8. Here's one more question that you can answer fairly easily with these methods, although I'll leave it up to you to try and work out a way to do it: _Do the Station Names and Station IDs contain completely redundant information?_ Or stated another way: _Is Station ID just a code for the Station Name?_

## Submitting your answers

- Make sure you pass all the autograding tests in the `tests.R` file.
- Make sure that you have commited the solution `.Rmd`, `.md`, `.html` files to git. If you have a `PS04_solution_files` directory (because you made a graph maybe?), commit that too.
- Push everything to github. Double-check things there. If you used any extra packages make sure you added them to PACKAGES.
- When you're happy, go to the Feedback pull request and add @grady as a reviewer.
