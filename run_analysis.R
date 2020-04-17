### Getting and cleaning data course project 

### Download the data file 
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

if(!file.exists('Dataset.zip')){
  download.file(url, 'Dataset.zip')
  unzip('Dataset.zip')
}

###########################################################################
#script should do the following : 
# #1 merges the training and the test sets to create one data set
# (apparently we can ignore the inertial signals data)
###########################################################################
setwd('UCI HAR Dataset')
features <- read.table('features.txt', stringsAsFactors = FALSE)
names(features) <- c('FeatureID','FeatureName')

## remove parentheses from feature names
features$FeatureName <- gsub('[\\(\\)]','',features$FeatureName)

activity_labels <- read.table('activity_labels.txt', stringsAsFactors = FALSE)
names(activity_labels) <- c('ActivityID','ActivityName')

setwd('./test')

subject_test <- read.table('subject_test.txt')
X_test <- read.table('X_test.txt')
y_test <- read.table('y_test.txt')

names(subject_test) <- 'SubjectID'
names(X_test) <- features[,2]
names(y_test) <- 'ActivityID'

## combine all test data
combined_test_data <- cbind(y_test, subject_test, X_test)

setwd('../train')

subject_train <- read.csv('subject_train.txt', sep = '', stringsAsFactors = FALSE)
X_train <- read.csv('X_train.txt', sep ='', stringsAsFactors = FALSE)
y_train <- read.csv('y_train.txt', sep ='', stringsAsFactors = FALSE)

names(subject_train) <- 'SubjectID'
names(X_train) <- features[,2]
names(y_train) <- 'ActivityID'

## combine all the training data
combined_train_data <- cbind(y_train, subject_train, X_train)

## combine the testing and training data 
combined_data <- rbind(combined_test_data, combined_train_data)

###########################################################################
#2 : Extracts only the measurements on the mean and standard deviation 
#     for each measurement
###########################################################################

## also include the activity and subject IDs
mean_sd <- grepl('(ActivityID|SubjectID|-mean|-std)', names(combined_data))

data_subset <- combined_data[, mean_sd == TRUE]

###########################################################################
#3 Uses descriptive activity names to name the activities in the data set
###########################################################################

data_subset <- merge(activity_labels, data_subset,by = 'ActivityID')

###########################################################################
#4 Appropriately labels the data set with descriptive variable names
###########################################################################

## this was done previously 

###########################################################################
#5 From the data set in step 4, creates a second, independent tidy data set
#   with the average of each variable for each activity and each subject 
###########################################################################
library(dplyr) 

tidy_data <- data_subset %>% select(-c(ActivityID)) %>% group_by(SubjectID, ActivityName) %>%
  summarise_all(mean) %>% arrange(SubjectID, ActivityName)

## write output table 
setwd('../..')

write.table(tidy_data, 'tidy_data.txt')


