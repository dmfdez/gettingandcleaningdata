setwd('C:/Users/dmartin/Google Drive/Coursera/Getting and Cleaning Data/EjerciciosUCI HAR Dataset/')

print("Read and process features and activity text files")

# Load id->feature label data
feature.vector.labels.data <- read.table('features.txt', col.names = c('id','label'))

# Select only the measurements on the mean and standard deviation for each measurement.
# Using grepl we can return logical vector of matching columns.
# Features we want to select have -mean() or -std() as a part of the name.
selected.features <- subset(feature.vector.labels.data, grepl('-(mean|std)\\(', feature.vector.labels.data$label))

# Load id->activity label data
activity.labels <- read.table('activity_labels.txt', col.names = c('id', 'label'))

# Read train and test data sets
print("Read and process training dataset")
train.df <- load.dataset('train', selected.features, activity.labels)
print("Read and process test dataset")
test.df <- load.dataset('test', selected.features, activity.labels)

# Merge train and test sets
print("Merge train and test sets")
merged.df <- rbind(train.df, test.df)
print("Finished dataset loading and merging")

# Convert to data.table for making it easier and faster 
# to calculate mean for activity and subject groups.
merged.dt <- data.table(merged.df)

# Calculate the average of each variable for each activity and each subject. 
tidy.dt <- merged.dt[, lapply(.SD, mean), by=list(label,subject)]

# Tidy variable names
tidy.dt.names <- names(tidy.dt)
tidy.dt.names <- gsub('-mean', 'Mean', tidy.dt.names)
tidy.dt.names <- gsub('-std', 'Std', tidy.dt.names)
tidy.dt.names <- gsub('[()-]', '', tidy.dt.names)
tidy.dt.names <- gsub('BodyBody', 'Body', tidy.dt.names)
setnames(tidy.dt, tidy.dt.names)

# Save datasets
setwd('..')
write.csv(merged.dt, file = 'tidy.csv', row.names = FALSE)
write.csv(tidy.dt,
file = 'tidy.csv',
row.names = FALSE, quote = FALSE)


print("Finished processing. Tidy dataset is written to tidy.csv")