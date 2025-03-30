# Script to extract text of forum posts from a website --------------------
# Allows the user to specify the specific thread with the variable thread_number
# Code verfied to work on 2025-03-30

# Setup -------------------------------------------------------------------

# Load libraries
library(rvest)
library(glue)
library(tidyverse)

# Define the URL

thread_number <- "1215552"

# URL for pages after the first page add a number to the URL which increments by
# 15 for each page
# This number appears in the URL after list/ and before e.g. /1215552.page
# Use glue from {glue} to create a vector of URLs corresponding to each page
# NOTE: 0 is a valid value which corresponds to the first post
page_numbers <- seq.int(0, 150, by = 15)

urls <- glue(
	"https://www.dcurbanmom.com/jforum/posts/list/",
	"{page_numbers}/",
	"{thread_number}.page"
)

# Extract text of forum posts ---------------------------------------------

# Read the HTML content of the page

page <- map(
	urls,
	\(x) {
		# Add a delay to avoid overloading the server
		Sys.sleep(5)
		read_html(x)
	}
)

# Extract the text of the forum posts
# The div classes containing the text of the forum posts have ids that begin
# with "post_text_" followed by numbers
# Extract these from the pages using html_element and extract the text using
# html_text2 from {rvest}

posts <- map(
	page,
	\(x) {
		x |>
			html_elements(
				css = ".postbody"
			) |>
			html_table() |>
			list_rbind() |>
			rename(posts = X1)
	}
)

# Convert to dataframe and add row id

posts_df <- list_rbind(posts)

posts_df <- posts_df |>
	mutate(row_id = row_number())

# Write to CSV ------------------------------------------------------------

write_csv(posts_df, "output/forum_posts.csv")
