## libraries 

library(data.table)
library(dplyr)

## download and unzip files 

filename <- "Dataset.zip" 
if(!file.exists(filename)){
         fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
         download.file(fileurl, filename, method = "curl")}
if(!file.exists("UCI HAR Dataset")){
         unzip(filename)} 

## read metadata 

featureNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)

## read data 

subjecttrain<- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE) 

subjecttest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)

## merge the training and test data to one data set 

x<- rbind(x_train,x_test)
y<- rbind(y_train,y_test)
subject<- rbind(subjecttrain,subjecttest)

## name the columns 

colnames(x)<-t(featureNames[2]) 
colnames(y)<- "activity" 
colnames(subject)<- "subject"

## merge data 

data<- cbind(subject, y, x)

## extract only the measurements of mean and std to keep 

columnskeep<- grepl("subject|activity|mean|std", colnames(data))
data <- data[,columnskeep]

## Use descriptive activity names to name the activities in the data set

data$activity<- activityLabels[data$activity,2]

## Appropriately label the data set with descriptive variable names 

names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("^t", "Time", names(data))
names(data)<-gsub("^f", "Frequency", names(data))
names(data)<-gsub("tBody", "TimeBody", names(data))
names(data)<-gsub("-mean()", "Mean", names(data), ignore.case = TRUE)
names(data)<-gsub("-std()", "STD", names(data), ignore.case = TRUE)
names(data)<-gsub("-freq()", "Frequency", names(data), ignore.case = TRUE)
names(data)<-gsub("angle", "Angle", names(data))
names(data)<-gsub("gravity", "Gravity", names(data))

## From the data set in the previous step, create a second, independent tidy data set with 
## the average of each variable for each activity and each subject. 

tidydata <- data %>%
          group_by(subject, activity) %>%
          summarise_all(funs(mean))
write.table(tidydata, "tidydata.txt", row.name=FALSE) 
