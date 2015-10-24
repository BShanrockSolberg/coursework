# Predictive Model for Human Activity Recognition
#### By Bradley Shanrock-Solberg
## Objective
Create a model to predict "classe" outcomes for test data based 
on training data provided for the exercise.  The training data
and test results are based on a this 
[Human Activity Prediction study](http://groupware.les.inf.puc-rio.br/har).

## Loading and Preprocessing the Data

Downloaded the files into working directory and loaded into data frames.

```r
require(caret)
haTrain <- read.csv("pml-training.csv")
haTest <- read.csv("pml-testing.csv")
```
After a basic look at the data using the "str()" command,
a large number of observations had missing data in many
columns.  This code is used to identify the problem columns,
which have 19216 of 19612 rows populated with either NA or "".

```r
dim(haTrain)
```

```
## [1] 19622   160
```

```r
table(sapply(as.data.frame(is.na(haTrain)),sum))
```

```
## 
##     0 19216 
##    93    67
```

```r
table(sapply(as.data.frame(haTrain == ""),sum))
```

```
## 
##     0 19216 
##    60    33
```

```r
trainVar <- names(haTrain[, sapply(as.data.frame(is.na(haTrain)),sum) == 0
                            & sapply(as.data.frame(haTrain == ""),sum) == 0])
trainVar
```

```
##  [1] "X"                    "user_name"            "raw_timestamp_part_1"
##  [4] "raw_timestamp_part_2" "cvtd_timestamp"       "new_window"          
##  [7] "num_window"           "roll_belt"            "pitch_belt"          
## [10] "yaw_belt"             "total_accel_belt"     "gyros_belt_x"        
## [13] "gyros_belt_y"         "gyros_belt_z"         "accel_belt_x"        
## [16] "accel_belt_y"         "accel_belt_z"         "magnet_belt_x"       
## [19] "magnet_belt_y"        "magnet_belt_z"        "roll_arm"            
## [22] "pitch_arm"            "yaw_arm"              "total_accel_arm"     
## [25] "gyros_arm_x"          "gyros_arm_y"          "gyros_arm_z"         
## [28] "accel_arm_x"          "accel_arm_y"          "accel_arm_z"         
## [31] "magnet_arm_x"         "magnet_arm_y"         "magnet_arm_z"        
## [34] "roll_dumbbell"        "pitch_dumbbell"       "yaw_dumbbell"        
## [37] "total_accel_dumbbell" "gyros_dumbbell_x"     "gyros_dumbbell_y"    
## [40] "gyros_dumbbell_z"     "accel_dumbbell_x"     "accel_dumbbell_y"    
## [43] "accel_dumbbell_z"     "magnet_dumbbell_x"    "magnet_dumbbell_y"   
## [46] "magnet_dumbbell_z"    "roll_forearm"         "pitch_forearm"       
## [49] "yaw_forearm"          "total_accel_forearm"  "gyros_forearm_x"     
## [52] "gyros_forearm_y"      "gyros_forearm_z"      "accel_forearm_x"     
## [55] "accel_forearm_y"      "accel_forearm_z"      "magnet_forearm_x"    
## [58] "magnet_forearm_y"     "magnet_forearm_z"     "classe"
```
trainVar now includes 59 variables and 1 column ("classe") of outcomes.
52 of these variables are actual physical measurements and one is based on
the subject name.  As the exercises might involve different accelerations
for different subjects (due to arm length, typical speed of motion, etc)
the subject name should remain.  Of the remaining:
* "X" is just a counter variable, unique for each observation
* 3 "timestamp" variables are probably not important for predicting activity
* "window" variables seem to indicate start and duration of a batch of activity 

In my judgement, none of these are useful to predict motion, as in theory the
time an exercise was done or which trial it might have been for each subject
should not matter for predicting activity and if they happen to have predictive
value within the data set, such "value" would serve only to cause overfitting
because any future measurements will be for a later time period, not included 
in the training data set.

Therefore these variables also must be excluded from the list of trainng columns.

```r
removeVar <- c("X","raw_timestamp_part_1", "raw_timestamp_part_2", 
               "cvtd_timestamp", "new_window", "num_window")
trainCol <- NULL
for (i in 1:length(trainVar)) {
  if (length(grep(trainVar[i], removeVar)) == 0) {
     trainCol <- c(trainCol, trainVar[i])
  } # end of exclude removal variables from the training list
} # end of loop through training variable list
length(trainCol) # includes only "classe" and useful training variables
```

```
## [1] 54
```

## Training the Model
Split the data into test and training groups:

```r
table(haTrain$classe)
```

```
## 
##    A    B    C    D    E 
## 5580 3797 3422 3216 3607
```

```r
inTrain <- createDataPartition(y = haTrain$classe, p = .75, list=FALSE)
training <- haTrain[inTrain, ]
testing <- haTrain[-inTrain, ]
table(training$classe)
```

```
## 
##    A    B    C    D    E 
## 4185 2848 2567 2412 2706
```

```r
table(testing$classe)
```

```
## 
##    A    B    C    D    E 
## 1395  949  855  804  901
```
### Model Selection
**lm** is inappropriate because the outcome is factors, not a fitted curve.

**glm** is inapporpriate because it can only work with binary factors

Some kind of **Tree Model** seemed best, as that has a natural tendency
to divide data into discrete buckets.  Start with a simple tree model:

```
set.seed(1000)
rpFit <- train(classe~., data = training[, trainCol], method = "rpart")
rpFit
table(predict(rpFit, newdata=training))
```

```
## CART 
## 
## 14718 samples
##    53 predictor
##     5 classes: 'A', 'B', 'C', 'D', 'E' 
## 
## No pre-processing
## Resampling: Bootstrapped (25 reps) 
## Summary of sample sizes: 14718, 14718, 14718, 14718, 14718, 14718, ... 
## Resampling results across tuning parameters:
## 
##   cp          Accuracy   Kappa      Accuracy SD  Kappa SD  
##   0.02743758  0.5582622  0.4296012  0.02381306   0.03951054
##   0.04169752  0.4714102  0.2984180  0.06067193   0.10155444
##   0.11696573  0.3273322  0.0609988  0.04166694   0.06483761
## 
## Accuracy was used to select the optimal model using  the largest value.
## The final value used for the model was cp = 0.02743758.
```

```
## 
##    A    B    C    D    E 
## 3186 3197 5456 1623 1256
```

While this model did very poorly (internal error rate estimated by kappa 
to be only .43), the problem looked like it might be tied the order of 
the initial cut (too many things bucketed to "C" early on.)   

The next step is to add bootstrap aggreggation to the basic tree model
as that might help it choose different tree paths that work through 
more of the training data set.  A quick search of models in this category
turned up the **treebag** method.

```
tbFit <- train(classe~., data = training[, trainCol], method = "treebag")
tbFit
```

```
## Bagged CART 
## 
## 14718 samples
##    53 predictor
##     5 classes: 'A', 'B', 'C', 'D', 'E' 
## 
## No pre-processing
## Resampling: Bootstrapped (25 reps) 
## Summary of sample sizes: 14718, 14718, 14718, 14718, 14718, 14718, ... 
## Resampling results
## 
##   Accuracy   Kappa      Accuracy SD  Kappa SD 
##   0.9780885  0.9722721  0.004669156  0.0058982
## 
## 
```

```
## 
##    A    B    C    D    E 
## 4199 2833 2575 2418 2693
```
This had a kappa value of over 97% for the training data, so I decided
to try this model out on the testing portion and see how it performed:


```r
 confusionMatrix(predict(tbFit, newdata = testing), testing$classe)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 1393    5    0    0    0
##          B    1  939    2    0    2
##          C    1    1  851    7    0
##          D    0    3    2  797    2
##          E    0    1    0    0  897
## 
## Overall Statistics
##                                          
##                Accuracy : 0.9945         
##                  95% CI : (0.992, 0.9964)
##     No Information Rate : 0.2845         
##     P-Value [Acc > NIR] : < 2.2e-16      
##                                          
##                   Kappa : 0.993          
##  Mcnemar's Test P-Value : NA             
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity            0.9986   0.9895   0.9953   0.9913   0.9956
## Specificity            0.9986   0.9987   0.9978   0.9983   0.9998
## Pos Pred Value         0.9964   0.9947   0.9895   0.9913   0.9989
## Neg Pred Value         0.9994   0.9975   0.9990   0.9983   0.9990
## Prevalence             0.2845   0.1935   0.1743   0.1639   0.1837
## Detection Rate         0.2841   0.1915   0.1735   0.1625   0.1829
## Detection Prevalence   0.2851   0.1925   0.1754   0.1639   0.1831
## Balanced Accuracy      0.9986   0.9941   0.9965   0.9948   0.9977
```
The kappa value for external error rate was even better for the 
testing data than the training data, and as this estimate of the 
external error rate > .99 there did not seem to be much value in 
trying to look for a stronger model when the objective was to 
answer only 20 test cases.  

## Outcome
This model proved successful in predicting all 20 test case activity
factors correctly.



