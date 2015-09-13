################################################################################
#  This is a script used to accomplish the requirements in the Coursera
#  "Getting and Cleaning Data" Course Project

#  This script is run from the same directory where the raw data is unzipped
#  > dir()
#  [1] "getdata_projectfiles_UCI HAR Dataset"     
#  [2] "getdata_projectfiles_UCI HAR Dataset.zip" "README.R"                                
#  [4] "run_analysis.R" 
#
#

# Load path to all data files, then trim to only files used in experiment 
HARfiles <- dir(recursive = TRUE)
HARfiles <- HARfiles[grep("^getdata_projectfiles_UCI HAR Dataset/",HARfiles)]

# The first goal is achieved with several ldply merges as we go forward
#   1.  Merges the training and the test sets to create one data set.
# I don't have these installed by default, they're needed to merge results
install.packages("plyr")
library(plyr)

# for the final averaging of data I'll need sqldf too
library(sqldf)

# Test and train data are captured strictly by row in the text file, so they
# can be merged at each step - test rows always come before train rows because
# of how grep returns the file names (test > train in alphabetical order)
# The "X" file contains all the "features" results, and we merge with ldply
# to a single data frame from the list lapply creates.

xtrial <- lapply(HARfiles[x = grep("/t.+/X_.+txt$",HARfiles)], read.table)
xtrial <- ldply(xtrial,data.frame)

# xtrial has 561 columns, which correspond to the feature_id's of the
# "features" data set, so we can now name the columns, satisfying this goal
#   (as with the merge, we have to keep doing it as we add further data)
#   4.  Appropriately labels the data set with descriptive variable names
#
#   Gather and index features.  ID turns out to match row index
features <-  read.table(HARfiles[grep("/features.txt$",HARfiles)],
                       col.names = c("features_id", "features_name"))
names(xtrial) <- features$features_name

# Now reduce the data set columns to accomplish this goal:
#   2. Extracts only the measurements on the mean and standard deviation 
#      for each measurement.
#
# The Features text file flags mean and standard deviation as follows:
#      mean          -> contains "mean()" but in actual data labels
#                       this translates to "-mean()"
#      std deviation -> contains "std()", in labels "-std()"
#
# This lets us grep the columns indexes based on the new column names
meancolumns <- grep("-mean[()]",names(xtrial))
stdcolumns <- grep("-std[()]",names(xtrial))
# The sort statement preserves the column order, as the raw data does
# have it organized in a useful way (all XYZ for one measurement near
# each other and mean before std deviation)
alltrial <- xtrial[,sort(c(meancolumns,stdcolumns))]

# The "subjects" file has subject number in the exact same order as the X-file,
# so bring it in the same way, merge it, then apply it to alltrial
subjects <-  lapply(HARfiles[x = grep("/subject.+txt$",HARfiles)], read.table)
# goal #1
subjects <-  ldply(subjects,data.frame)
# goal #4
names(subjects) <- "subject"
alltrial$subject <- subjects$subject 

# The "y" file tracks activity id in the same exact order as X-file
ytrial <-  lapply(HARfiles[x = grep("/t.+/y_.+txt$",HARfiles)], read.table)
# goal #1
ytrial <-  ldply(ytrial,data.frame)
# goal #4
names(ytrial) <- "activity_id"
# now bring in activity names to accomplish this goal:
#   3.  Uses descriptive activity names to name the activities in the data set
#   Gather and index activity labels.
activity <- read.table(HARfiles[grep("/activity_labels.txt$",HARfiles)],
                       col.names = c("activity_id", "activity"))
#   apply activity names to the ytrial data set
ytrial$activity <- activity[match(ytrial[["activity_id"]],
                                         activity[["activity_id"]]),
                                   "activity"]

# now bring activity into the main data frame
alltrial$activity <- ytrial$activity


# Finally create a new data frame and output file for this goal:
#   5. From the data set in step 4, creates a second, independent tidy 
#      data set with the average of each variable for each activity 
#      and each subject.
#   I interpret this to mean a data set that has one entry per combination
#   of activity+subject  (so subject #5, LAYING is one row, #5 SITTING is
#   another row, all other columns averaged within the variable

# My strategy for this task is to use sqldf, as this kind of gruop by
# activity is very natural in SQL syntax, where in aggregate or data.table
# getting the average of 79 columns is somewhat awkward. The same sql 
# statement also lets me rename and order columns to suit my preference in
# one command.

# To generate the sql statement, I need to manipulate the column names, so
# I can do all the "avg(column_name)" statements in one vectorized operation
# and not violate any MySql naming rules for columns

avgrows <- length( unique(alltrial[,c("subject","activity")])$subject)
avgtrial <-  unique(alltrial[,c("subject","activity")])
rownames(avgtrial) <- 1:avgrows
# the names to be averaged are all but the last two in the data table
#    (the last two are subject and activity)
allcols <- length(names(alltrial)) - 2
allnames <- names(alltrial)[1:allcols]

# The parentheses () & - cause problems in the MySql statement
# I want to keep the - separation, so switch to underscores
allnames <-  gsub("\\(\\)","",allnames)
allnames <-  gsub("-","_",allnames)

# The fixed names go back into the original data frame, because
# so far I've preserved the original column order and it makes
# the "build sql statement" logic easier.
names(alltrial) <- c(allnames,"subject","activity")

# The sql statement construction requires the following fragment
#   for each column that is to be to be averaged
#     (this prefixes tBodyAcc_mean_X with "avg_" & takes average)
#     , AVG(tBodyAcc_mean_X) avg_tBodyAcc_mean_X
# This statement builds it for all averaged columns
sqlstr <- paste(", AVG(", allnames,") avg_", allnames, 
                       sep="", collapse = "")

# now add the beginning "select" and the ending "from" 
#  and "group by" statements for a complete sql statement
#  this format meanst the key indexes (subject & activity)
#  are in the first 2 columns, instead of the last 2)
sqlstr <- paste("SELECT subject, activity", sqlstr,
                " FROM alltrial GROUP BY subject, activity")

# generate the tidy data frame and print it to a file
tidytrial <- sqldf(sqlstr)
# because there are no commas in data, generate a .csv file 
write.table(tidytrial,file = "tidytrial.csv", 
            row.names = FALSE, sep = ",")







