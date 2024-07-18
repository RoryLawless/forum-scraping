
# Script to extract text of forum posts from a website --------------------
# https://www.dcurbanmom.com/jforum/posts/list/1215552.page
# Text can be found in div classes with ids beginning with "post_text_" 
# followed by numbers

# Setup -------------------------------------------------------------------

# Load libraries
library(rvest)
library(glue)
library(tidyverse)

# Define the URL
# URL for pages after the first page add a number to the URL which increments by
# 15 for each page
# This number appears in the URL after list/ and before /1215552.page
# Use glue from {glue} to create a vector of URLs corresponding to each page
# NOTE: It seems 0 is a valid value which corresponds to the first page
page_numbers <- seq.int(0, 150, by = 15)

urls <- glue("https://www.dcurbanmom.com/jforum/posts/list/{page_numbers}/1215552.page")

# Extract text of forum posts ---------------------------------------------

# Read the HTML content of the page

page <- map(urls,
            read_html)

# Extract the text of the forum posts
# The div classes containing the text of the forum posts have ids that begin
# with "post_text_" followed by numbers
# Extract these from the pages using html_element and extract the text using
# html_text2 from {rvest}

posts <- map(page, \(x) x |> 
  html_element(xpath = '//*[starts-with(@id, "post_text_")]') |> 
  html_text2())

# Convert to dataframe and add row id

posts_df <- tibble(posts = unlist(posts))
posts_df <- posts_df |> 
  mutate(row_id = row_number())

# Write to CSV ------------------------------------------------------------

write_csv(posts_df, "output/forum_posts.csv")
