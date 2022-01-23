---
title: "example wrangling commands"
author: "Grady Weyenberg"
date: "Math 271 - 1/18/2022"
output: 
  html_document: 
    keep_md: yes
---



If you're reading the Rmd, note that the code chunk default has been set to not evaluate anything.

## Gapminder

I'll demonstrate with an example data set from the `gapminder` package.


```r
library(tidyverse)
library(gapminder)
data(gapminder)
gapminder
```


## select (columns)

How to select individual columns from a dataset using `dplyr::select`


```r
( gap_select <- select(gapminder, starts_with("co"),  year:pop, gdp = gdpPercap ) )
```

### pipe `%>%`

`apple+shift+M` or `ctrl+shift+m` 


```r
gapminder %>% select(pop, starts_with("co")) %>% slice_tail(n=3)
slice_tail(select(gapminder, starts_with("co"), pop), n=3)
```



### Selecting columns


```r
gapminder %>% select(country, year, pop)
gapminder %>% select(!gdpPercap)
gapminder %>% select(country:lifeExp)
gapminder %>% select(starts_with("co"), year, gdpPercap)
```

Select can also rename columns


```r
gapminder %>% select(co=country, yr=year, lifeExp)
```

Related command is `dplyr::rename` which renames without dropping other columns.



## Slicing rows
`dplyr::slice` selects rows by number. `slice_head` and `slice_tail` show a given number of rows at the start or end of the data. `slice_sample` can be used to randomly select some rows, which is useful for understanding what the bigger data set looks like.

```r
gapminder %>% slice(1:20)
gapminder %>% slice_head(n=5)
gapminder %>% slice_tail(n=10)
gapminder %>% slice_sample(prop=0.01)
```

## Filtering rows

Filtering numbers uses `<`, `>`, `<=`, `>=`, `==`, `!=`, `dplyr::near`, `dplyr::between`. You should be very careful with `==` and `!=`, it's generally better to use `near(x,2)` than `x == 2`. The latter will usually work, right up until it doesn't. 

For example: Is $1 - 0.9 - 0.1 = 0$? According to R: FALSE


```r
gapminder %>% filter(lifeExp > 80)
gapminder %>% filter(between(lifeExp, 20, 30))
```

Filtering strings and factors uses `==`, `!=`, and `%in%`. More complicated pattern matching using "regular expressions" is possible, but we won't cover that now.


```r
gapminder %>% filter(country == "a"Rwand)
gapminder %>% filter(continent != "Asia")
gapminder %>% filter(continent %in% c("Oceania", "Asia"))
gapminder %>% filter(continent == "Africa", lifeExp > 70)
```

## Add new variables with mutate


```r
gapminder %>% mutate(pop = as.integer(pop),
                     gdp = gdpPercap * pop, 
                     lifeExp_zscore = (lifeExp - mean(lifeExp)) / sd(lifeExp) )
```

If you mutate grouped data, any summaries in mutate will be calculated within groups


```r
gapminder %>% group_by(country) %>% mutate(life_mean=mean(lifeExp), life_delta = lifeExp - life_mean)
```


## Sort data with arrange


```r
gapminder %>% arrange(year)
gapminder %>% arrange(desc(year))

gapminder %>% arrange(year, lifeExp)
```


## compute statistics with summarize


```r
gapminder %>% summarize(life_mean = mean(lifeExp), life_sd=sd(lifeExp),
                        first_year = min(year), biggest_population=max(pop))
```

## Grouping


```r
gapminder %>% group_by(continent) %>% summarise(lifeExp_mean = weighted.mean(lifeExp, pop),
                                                lifeExp_median = median(lifeExp))

gapminder %>% 
  group_by(year, continent) %>% 
  summarise(lifeExp_mean = weighted.mean(lifeExp, pop),
            lifeExp_median = median(lifeExp))
```

## Putting it all together

Let's see how this works in practice: You're given a task to make a plot showing how life expectancy changes over time in each country.


```r
gap_deltas <- gapminder %>% 
  group_by(country) %>%
  arrange(year) %>% # ensure the temporal order
  mutate(lifeExp_delta = lifeExp - lag(lifeExp)) %>% # difference from last lifeExp value
  filter( !is.na(lifeExp_delta) ) %>% # drop rows with NA
  arrange(continent, year, lifeExp_delta) %>% # sort data
  select(country:year, lifeExp_delta) # pick out variables of interest
gap_deltas
```

We'll cover this more in the future, but let's graph!


```r
library(ggplot2)
ggplot(gap_deltas) + 
  aes(x=year, y=lifeExp_delta, group=country) + 
  geom_line(alpha=0.2) + 
  facet_wrap(~continent) + 
  labs(title="National life expectancy trends",
       subtitle="change over previous 4-year period",
       x="Year (Gregorian calendar)",
       y="Change in Life Expectancy",
       caption="Source: Gapminder")
```


# Pivots (convert columns to rows)

Many of these functions come from the `tidyr` package (which is loaded by `tidyverse`).

Most often, the goal is to maneuver your data in to a "tidy" form to make it easy to plot and analyze. The general idea is

1. Each "variable" (type of observed quantity) goes in a column
2. Each "observation" (individual that is measured) goes in a row

However, it is common to prepare spreadsheets with raw data in other formats.

The `relig_income` data is a typical example of a data set which has been partially processed into a "contingency table" (or "crosstabs"). It is not tidy.


```r
relig_income
```

If we think about how this data was collected, we realize that a subject (observation) in this study is an individual who filled out the survey. There are two variables (things we measure about the subject): `religion` and `income`. The data has been partially summarized already, and the numbers in the table are the "counts" of how many subjects fall into each combination of religion and income group, and this `count` will be our third variable.


```r
(relig_tidy <- relig_income %>% pivot_longer(!religion, names_to = "income", values_to="count"))
```
## Billboard data


```r
billboard
```

As the data is entered in the spreadsheet, the data focuses on the billboard ranking trajectory of each track after it debuted. If we think back to how the data was originally collected, the "subject" being observed is "a track on the Billboard top 100", and the "variables" being recorded are `artist`, `track`, `date.entered`, how many `week`s has this track been on the chart, and what `rank` is it?


```r
billboard_tidy <- billboard %>% 
  pivot_longer(starts_with("wk"), 
               names_to="week", 
               names_prefix="wk", 
               values_to = "rank", 
               values_drop_na = TRUE) %>% 
  mutate(week=as.numeric(week))
ggplot(billboard_tidy) + 
  aes(x=week, y=rank, group=track) + 
  geom_line(alpha=0.2) + 
  scale_y_reverse()
```

We can already detect an interesting pattern. If a track has been on the chart for more than 20 weeks and a decrease in popularity leaves it below #50, it's removed from the Billboard chart entirely to make room for a new song.

## WHO Tuberculosis data

The `who` data set has three different variable values encoded in the column names. In this case, the prefix and pattern are specified using _regular expressions_. 


```r
glimpse(who)
who %>% pivot_longer(starts_with("new"), 
                     names_to=c("diagnosis", "gender", "age"), 
                     names_prefix = "new_?", 
                     names_pattern = "(.*)_(.)(.*)", 
                     values_to="count",
                     values_drop_na = TRUE)
```

## Regular Expressions

- interactive tutorial: https://regexone.com/
- https://regex101.com/
- https://rpubs.com/rudeboybert/MATH241_regex
- https://en.wikipedia.org/wiki/Regular_expression
