## Code Book for tidytrial.csv

The context for this data can be found in the [Samsung Smartphone Human activity study](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

The unique key for tidytrial.csv is the combination of the first two columns:
* **subject**   - A number from 1-30, each representing a test subject
* **activity**  - one of 6 activities the subject was doing while being measured  
   LAYING, SITTING, STANDING, WALKING, WALKING_DOWNSTAIRS, WALKING_UPSTAIRS   

Each subject was measured between 281 and 409 times, and each measurement was organized into 561 variables, of this format: `[measurement]-[function]-[XYZ]` where
* measurement = data samsung device provided during the activity (see below)
* function = statistical function on data collected during the activity (eg, mean, max, skew)
* [XYZ] = if the measurement is broken down into X axis, Y axis, Z axis, the variable is appended  
Raw variable example: `fBodyBodyGyroJerkMag-std() or avg_tBodyAcc-mean()-Z`

Only measurements with these functions were included in the tidytrial data. (33 measurements, 66 averaged columns in tidytrial.csv)
* mean(): Mean value
* std(): Standard deviation
 
tidytrial.csv averages the measurements of all similar activities.  So if subject #1 was measured SITTING 34 times, the average of those 34 measurements is captured in tidytrial.csv.

The variable names have been modified to reflect this, the format is `avg_[measurement]_[function]_[X]`  
Processed variable example: `avg_fBodyBodyGyroJerkMag_std or avg_tBodyAcc_mean_Z`

The list of measurements, pulled from the features_info.txt of the source data zip file is replicated here:

`These signals were used to estimate variables of the feature vector for each pattern:`  
`'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.`

`tBodyAcc-XYZ`  
`tGravityAcc-XYZ`  
`tBodyAccJerk-XYZ`  
`tBodyGyro-XYZ`  
`tBodyGyroJerk-XYZ`  
`tBodyAccMag`  
`tGravityAccMag`  
`tBodyAccJerkMag`  
`tBodyGyroMag`  
`tBodyGyroJerkMag`  
`fBodyAcc-XYZ`  
`fBodyAccJerk-XYZ`  
`fBodyGyro-XYZ`  
`fBodyAccMag`  
`fBodyAccJerkMag`  
`fBodyGyroMag`  
`fBodyGyroJerkMag`  



