# text cleaning script using textclean library
# see https://github.com/trinker/textclean#functions for instructions
# Tina Keil, t.keil@lancaster.ac.uk, February 2022

# blog data can be big, so increase java heap
# but adjust to RAM available on your machine!
options(java.parameters = "-Xmx8000m") #8GB ram
options(scipen=999) #turn off scientific notation

#load required libraries
library(dplyr)
library(filesstrings)
library(stringi)
library(lubridate) #for converting dates
library(data.table) #fread is much faster for reading csv
library(readr)
library(textclean)
library(beepr)

#set working directory to directory of script
path <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(path)
source("functions.R")

############ settings ##############
in_file <- "rse-sheffield.csv" #name of file to import
out_name <- tools::file_path_sans_ext(in_file)
out_file <- paste0("cleaned/","clean_",out_name,".csv") #name of file after cleaning
out_csv <- paste0(out_file, ".csv")
infilepath <- paste0("originals/",in_file)

############## process ##############
now <- start_time()

#get data from csv file
if (file.exists(infilepath)) {
  raw_data <- read.csv(infilepath, sep=",")
} else {
  stop("Can't find input file. Please check.")
}

url <- raw_data$article.href
  
cat("* Converting date\n")
#from 22 January 2020 14:43 -> 2020-01-22 14:43:00
pubdate <- str_replace(raw_data$published, " - ", " ")
pubdate <- dmy_hm(pubdate)

#reformat author
author <- str_replace_all(raw_data$author, "\\.", ". ")
author <- trimws(str_to_title(author))
  
#clean text
cat("* Starting to process title and body\n")
title <- cleantext(raw_data$title)
content <- cleantext(raw_data$content)

content <- stri_replace_all_fixed(content,paste0(title,". "),"")
content <- stri_replace_all_fixed(content,paste0(author,". "),"")
content <- stri_replace_all_fixed(content,paste0(raw_data$published,". "),"")

#add to new data frame
clean_data <- data.frame(url,title,content,author,pubdate)
  
save2file(clean_data, out_name, out_file)

show_alltime(now, out_name)
