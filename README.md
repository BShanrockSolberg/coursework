## Smartphone Human Activity measurements summarized by subject & activity

The *[data source](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)* used in this repository comes from the [Samsung Smartphone Human activity study](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

The directory contains the following aside from this **README.md**:
* **tidytrial.csv** - mean & standard deviation data from the samsung data grouped by subject & activity
* **tidytrial_code_book.md**  - explains the meaning of the variables in tidytrial.csv 
* **run_analysis.R** - script used to process the data from the *data source*

**run_analysis.R** requires that the working directory contain both itself, and the extracted contents of the *data source* zip file.  The script makes takes the following actions
 1. aggregates common data from several files into a single data frame
 2. removes results not expressed in terms of "mean" or "standard deviation"
 3. averages results of all measurements by subject & activity
 4. writes the results to **tidytrial.csv**   