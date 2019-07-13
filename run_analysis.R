##########################
# Created in 13 July 2019#
# By OSSJR - Brazil	 #
##########################
# set directory
filePath<-"C:/Users/User/Desktop/RExercise/Coursera"
setwd(filePath)

##load packages##
library(tidyr)
library(dplyr)
library(data.table)

##download the file##
if(!file.exists("./data")){dir.create("./data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/fileProject.zip",method="winset")

##Unzip file##
if (!unzip(zipfile="./data/fileProject.zip",exdir="./data")) {
	print("Failed to unzip!") }
print("Success to unzip!")

##read subject files##
filesPath <- filesPath<-"C:/Users/User/Desktop/RExercise/Coursera/data/UCI HAR Dataset"
dsTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))
dsTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))

##read activity files##
daTest  <- tbl_df(read.table(file.path(filesPath, "test" , "Y_test.txt" )))
daTrain <- tbl_df(read.table(file.path(filesPath, "train", "Y_train.txt")))

##read data files##
dbTest  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))
dbTrain <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))

##merge##
alldataSubject <- rbind(dsTrain, dsTest)
setnames(alldataSubject, "V1", "subject")
alldataActivity<- rbind(daTrain, daTest)
setnames(alldataActivity, "V1", "activityNum")

dataTable <- rbind(dbTrain, dbTest)

##name variables##
dbf <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(dbf, names(dbf), c("featureNum", "featureName"))
colnames(dataTable) <- dbf$featureName

##column names for activity##
acLabels<- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(acLabels, names(acLabels), c("activityNum","activityName"))

# Merge columns
alldataSubject<- cbind(alldataSubject, alldataActivity)
dataTable<- cbind(alldataSubjAct, dataTable)

##extract pattern##
dbStd <- grep("mean\\(\\)|std\\(\\)",dbf$featureName,value=TRUE)
dbStd <- union(c("subject","activityNum"), dbStd)
dataTable<- subset(dataTable,select=dbStd) 

## enter name and create dataTable
dataTable <- merge(activityLabels, dataTable , by="activityNum", all.x=TRUE)
dataTable$activityName <- as.character(dataTable$activityName)

## create dataTable with variable means sorted by subject and Activity
dataTable$activityName <- as.character(dataTable$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = dataTable, mean) 
dataTable<- tbl_df(arrange(dataAggr,subject,activityName))

names(dataTable)<-gsub("std()", "SD", names(dataTable))
names(dataTable)<-gsub("mean()", "MEAN", names(dataTable))
names(dataTable)<-gsub("^t", "time", names(dataTable))
names(dataTable)<-gsub("BodyBody", "Body", names(dataTable))
names(dataTable)<-gsub("^f", "frequency", names(dataTable))
names(dataTable)<-gsub("Acc", "Accelerometer", names(dataTable))
names(dataTable)<-gsub("Mag", "Magnitude", names(dataTable))
names(dataTable)<-gsub("Gyro", "Gyroscope", names(dataTable))

#projeto finalizado com arquivo de gravação
write.table(dataTable, "TidyData.txt", row.name=FALSE)
