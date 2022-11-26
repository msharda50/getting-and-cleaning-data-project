##############################################################################
#
# FILE
#   run_analysis.R
#
# OVERVIEW
#   Using data collected from the accelerometers from the Samsung Galaxy S 
#   smartphone, process the data and create a tidy data set, outputting the
#   resulting tidy data to a file named "TidyData.txt".
#   See README.md for details.
#
##############################################################################


##############################################################################
# STEP 1 - Set up the working environment - Get data
##############################################################################
 
options(warn=-1)  
library(data.table)
options(warn=0)

fileurl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "mydata.zip", method = "curl")
unzip("mydata.zip")
setwd("./UCI HAR Dataset")


##############################################################################
# STEP 2 - Merging the training and test sets
##############################################################################
 
subject_train <- read.table("./train/subject_train.txt", header = FALSE)
names(subject_train)<-"subjectID"
subject_test <- read.table("./test/subject_test.txt", header = FALSE)
names(subject_test)<-"subjectID"

## Reading and labeling the activities 
y_train <- read.table("./train/y_train.txt", header = FALSE)
names(y_train) <- "activity"
y_test <- read.table("./test/y_test.txt", header = FALSE)
names(y_test) <- "activity"

## Reading the function names
FeatureNames<-read.table("features.txt")

## Reading and labeling features  
X_train <- read.table("./train/X_train.txt", header = FALSE)
names(X_train) <- FeatureNames$V2
X_test <- read.table("./test/X_test.txt", header = FALSE)
names(X_test) <- FeatureNames$V2

##############################################################################
# Step 3 - Merge the training and the test sets to create one data set
##############################################################################

train <- cbind(subject_train, y_train, X_train)
test <- cbind(subject_test, y_test, X_test)
alldata <- rbind(train, test)

## Extracting the columns which have "mean" and "std" in the variable name
meancol<-alldata[,grep('mean()', names(alldata), fixed=TRUE)]
stdcol<-alldata[,grep('std()', names(alldata), fixed=TRUE)]
keycol<-alldata[,(1:2)]
meanstd_data<-cbind(keycol,meancol,stdcol)

## Reading the activity labels
actlbl<-read.table("activity_labels.txt")
## Encode activities and adding the labels
alldata$activity <- factor(alldata$activity, labels=actlbl$V2)

##############################################################################
# Step 4 - Appropriately label the data set with descriptive variable names
##############################################################################
 
names(alldata)<-gsub("tBody","TimeDomainBody",names(alldata), fixed=TRUE)
names(alldata)<-gsub("tGravity","TimeDomainGravity",names(alldata), fixed=TRUE)
names(alldata)<-gsub("fBody","FrequencyDomainBody",names(alldata), fixed=TRUE)
names(alldata)<-gsub("Acc","Acceleration",names(alldata), fixed=TRUE)
names(alldata)<-gsub("Gyro", "AngularVelocity",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-XYZ","3AxialSignals",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-X","XAxis",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-Y","YAxis",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-Z","ZAxis",names(alldata), fixed=TRUE)
names(alldata)<-gsub("Mag","MagnitudeSignals",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-mean()","MeanValue",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-std()","StandardDeviation",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-mad()","MedianAbsoluteDeviation ",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-max()","LargestValueInArray",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-min()","SmallestValueInArray",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-sma()","SignalMagnitudeArea",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-energy()","EnergyMeasure",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-iqr()","InterquartileRange ",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-entropy()","SignalEntropy",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-arCoeff()","AutoRegresionCoefficientsWithBurgOrderEqualTo4",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-correlation()","CorrelationCoefficient",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-maxInds()", "IndexOfFrequencyComponentWithLargestMagnitude",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-meanFreq()","WeightedAverageOfFrequencyComponentsForMeanFrequency",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-skewness()","Skewness",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-kurtosis()","Kurtosis",names(alldata), fixed=TRUE)
names(alldata)<-gsub("-bandsEnergy()","EnergyOfFrequencyInterval.",names(alldata), fixed=TRUE)

##############################################################################
# Step 5 - Creating a tidy set. Saving the file tidy.txt 
##############################################################################

DT<-data.table(alldata)
tidy<-DT[,lapply(.SD,mean),by="activity,subjectID"]
write.table(tidy, file="TidyData.txt", row.name=FALSE, col.names=TRUE)
print ("The script 'run_analysis.R was executed successfully.  As a result, the file TidyData.txt has been saved in the working directory, in folder UCI HAR Dataset.")
rm(list=ls())
