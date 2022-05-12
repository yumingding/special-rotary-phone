# loads packages
library(tidyverse)
library(missForest) # data cleaning (resolving n/a)
library(boot) #cross validation
#install.packages("caret")
library(caret) # cross validation
library(leaps) # model selection (forwards, backwards, etc)
library(tree)  # tree() 
library(partykit) # ctree()
library(randomForest)  # random forest

rm(list =ls()) # clears the rstudio environment
dev.off() # clears the rstudio plots

stroke_data <- read_csv("C:\\Users\\yumin\\Desktop\\Classwork\\Spring 2022\\DSP539\\Final Project\\healthcare-dataset-stroke-data.csv")

stroke_data <- subset(stroke_data, gender != "Other") # Removes row where gender is "other". 
#This is only one data point out of the over 5000 and including this data point causes problems with crossfold validation

# Changing the type of the data
stroke_data$gender <- as.factor(stroke_data$gender)  
stroke_data$ever_married <- as.factor(stroke_data$ever_married)
stroke_data$work_type <- as.factor(stroke_data$work_type)
stroke_data$Residence_type <- as.factor(stroke_data$Residence_type)
stroke_data$bmi <- as.numeric(stroke_data$bmi)
stroke_data$stroke <- as.factor(stroke_data$stroke)
stroke_data$smoking_status <- as.factor(stroke_data$smoking_status)
stroke_data$hypertension <- as.factor(stroke_data$hypertension)
stroke_data$heart_disease <- as.factor(stroke_data$heart_disease)

stroke_data <- as.data.frame(stroke_data) # change to data frame

stroke_data[stroke_data == "Unknown"] <- "N/A" # setting 'unknown' values to NA

str(stroke_data)  # checking that all the data types are correct

stroke_data_clean <- missForest(stroke_data) # using KNN imputation to estimate values for NA
class(stroke_data_clean) # checking the class. missForest creates its own data type
stroke_data_clean_df <- stroke_data_clean$ximp # the dataframe has to be extracted
class(stroke_data_clean_df)  # checking that I'm working with a dataframe

#Creating dummy variables
# gender
male_gen <- ifelse(stroke_data_clean_df$gender == "Male", 1, 0) # dummy variable for gender is 1-male, 0-female (baseline)

# work_type. The baseline here is private employment
children_wrk <- ifelse(stroke_data_clean_df$work_type == "children", 1, 0)
Govt_job_wrk <- ifelse(stroke_data_clean_df$work_type == "Govt_job", 1, 0)
Never_worked_wrk <- ifelse(stroke_data_clean_df$work_type == "Never_worked", 1, 0)
Self_employed_wrk <- ifelse(stroke_data_clean_df$work_type == "Self-employed", 1, 0)

#smoking_status. The baseline here is never smoked.
formerly_smoked_smk <- ifelse(stroke_data_clean_df$smoking_status == "formerly smoked", 1, 0)
smokes_smk <- ifelse(stroke_data_clean_df$smoking_status == "smokes", 1, 0)

# making new data frame with dummy variables
df.stroke <- data.frame(stroke.df = stroke_data_clean_df$stroke, male.df = male_gen, age.df = stroke_data_clean_df$age, 
                        hypertension.df = stroke_data_clean_df$hypertension, heart_disease.df = stroke_data_clean_df$heart_disease,
                        ever_married.df = stroke_data_clean_df$ever_married, children.df = children_wrk, Govt_job.df = Govt_job_wrk, 
                        Never_worked.df = Never_worked_wrk, Self_employed.df = Self_employed_wrk, Residence_type.df = stroke_data_clean_df$Residence_type,
                        avg_glucose_level.df = stroke_data_clean_df$avg_glucose_level, bmi.df = stroke_data_clean_df$bmi, formerly_smoked.df = formerly_smoked_smk,
                        smokes.df = smokes_smk)

head(df.stroke) # checking the first few lines of the new data frame

# creating the dummy variables using ifelse() changed the data types and they new variables have to be set to factors
df.stroke$male.df <- as.factor(df.stroke$male.df) 
df.stroke$children.df <- as.factor(df.stroke$children.df)
df.stroke$Govt_job.df <- as.factor(df.stroke$Govt_job.df)
df.stroke$Never_worked.df <- as.factor(df.stroke$Never_worked.df)
df.stroke$Self_employed.df <- as.factor(df.stroke$Self_employed.df)
df.stroke$formerly_smoked.df <- as.factor(df.stroke$formerly_smoked.df)
df.stroke$smokes.df <- as.factor(df.stroke$smokes.df)

str(df.stroke) # checking that I have all the types that I want

# creating a 80/20 training/testing split
test.num <- sample(1:nrow(df.stroke), round(5109*0.2))  # randomly sample 20% of the total data 
test.stroke <- df.stroke[test.num,]  # set as testing set
str(test.stroke) 
nrow(test.stroke)
train.stroke <- df.stroke[-test.num,]  # set the remaining data as the training set
str(train.stroke)
nrow(train.stroke)

#logistic regression
glm.stroke <- glm(stroke.df ~ .,data = train.stroke, family = binomial) # logistic regression of the full model with all variables. Training data

summary(glm.stroke)  # summary statistics

predicted <- predict(glm.stroke, test.stroke, type = "response")  # use the model to predict stroke occurrence on the test data
predicted <- ifelse(predicted <0.5, 0, 1)  # logistic response outputs between 0 and 1 and the divider here is chosen to be 0.5
predicted <- as.factor(predicted) # change the type to factor

confusionMatrix(predicted, test.stroke$stroke.df) # creates a confusion matrix of the predicted values against the actual values in the test set

stroke.pos <- filter(train.stroke, stroke.df == 1) # filtering the training data to have only the positive stroke rows
nrow(stroke.pos)
stroke.neg <- filter(train.stroke, stroke.df == 0) # filtering the training data to only have the negative stroke rows
nrow(stroke.neg)

# here I'm creating multiple sets of data where the split between stroke and no stroke is 50/50
set.seed(13453251)
neg1 <- sample(1:nrow(train.stroke), nrow(stroke.pos)) # create a set of numbers that corresponds to the number of stroke.pos rows
sample.neg1 <- stroke.neg[neg1,]  
str(sample.neg1)

subdata1 <- rbind(stroke.pos, sample.neg1)  # a sub data set with all of the positive stroke cases and an equal number of negative stroke cases
str(subdata1)

glm.subdata1 <- glm(stroke.df ~ .,data = subdata1, family = binomial) # logistic model based on subdata1
summary(glm.subdata1)

predicted.sub1 <- predict(glm.subdata1, test.stroke, type = "response")
predicted.sub1 <- ifelse(predicted.sub1 <0.5, 0, 1)
predicted.sub1 <- as.factor(predicted.sub1)

confusionMatrix(predicted.sub1, test.stroke$stroke.df)

#Since the number of negative stroke data in the subset data is sampled randomly, different subset data is generated to compare them
#set 2
set.seed(22553681)
neg2 <- sample(1:nrow(train.stroke), nrow(stroke.pos))
sample.neg2 <- stroke.neg[neg2,]
str(sample.neg2)

subdata2 <- rbind(stroke.pos, sample.neg2)
str(subdata2)

glm.subdata2 <- glm(stroke.df ~ .,data = subdata2, family = binomial)
summary(glm.subdata2)

predicted.sub2 <- predict(glm.subdata2, test.stroke, type = "response")
predicted.sub2 <- ifelse(predicted.sub2 <0.5, 0, 1)
predicted.sub2 <- as.factor(predicted.sub2)

confusionMatrix(predicted.sub2, test.stroke$stroke.df)

#set 3
set.seed(312)
neg3 <- sample(1:nrow(train.stroke), nrow(stroke.pos))
sample.neg3 <- stroke.neg[neg3,]
str(sample.neg3)

subdata3 <- rbind(stroke.pos, sample.neg3)
str(subdata3)

glm.subdata3 <- glm(stroke.df ~ .,data = subdata3, family = binomial)
summary(glm.subdata3)

predicted.sub3 <- predict(glm.subdata3, test.stroke, type = "response")
predicted.sub3 <- ifelse(predicted.sub3 <0.5, 0, 1)
predicted.sub3 <- as.factor(predicted.sub3)

confusionMatrix(predicted.sub3, test.stroke$stroke.df)
# 3 different subsets were created where the accuracy compares poorely to the confusion matrix using the full set of data 


#set 4 where there are more no stroke samples
set.seed(4112)
neg4 <- sample(1:nrow(train.stroke), nrow(stroke.pos)*10) # 10 times more negative stroke data than positive stroke data
sample.neg4 <- stroke.neg[neg4,]
str(sample.neg4)

subdata4 <- rbind(stroke.pos, sample.neg4)
str(subdata4)

glm.subdata4 <- glm(stroke.df ~ .,data = subdata4, family = binomial)

predicted.sub4 <- predict(glm.subdata4, test.stroke, type = "response")
predicted.sub4 <- ifelse(predicted.sub4 <0.5, 0, 1)
predicted.sub4 <- as.factor(predicted.sub4)

confusionMatrix(predicted.sub4, test.stroke$stroke.df)





# model selection to see if the model can be trimmed down to have less variables
regfit.exh = regsubsets(stroke.df ~., data = train.stroke,nvmax = 14, method = "exhaustive")   # best subset selection
summary(regfit.exh)
exh.summary <- summary(regfit.exh) # summary() function will pull several values including R^2 and BIC out
names(exh.summary)
exh.summary$rsq
plot(exh.summary$rsq, xlab = "Number of Variables",
     ylab = "RSQ", type = "l", main = "Best Subset Approach") # type = "1" changes the points to line
plot(exh.summary$rsq)   # about 7-8 variables is when it evens out
plot(exh.summary$bic, xlab = "Number of Variables",
     ylab = "BIC", type = "l", main = "Best Subset Approach") # type = "1" changes the points to line

regfit.back = regsubsets(stroke.df ~., data = train.stroke,nvmax =14, method = "backward")     # backwards selection
summary(regfit.back)
back.summary <- summary(regfit.back)
names(back.summary)
back.summary$rsq
plot(back.summary$rsq, xlab = "Number of Variables",
     ylab = "RSQ", type = "l", main = "Backwards Selection") # type = "1" changes the points to line
plot(back.summary$rsq)   # really from 7-8 variables the graph evens out. The video lecturers recommend using the simplist model posible
plot(back.summary$bic, xlab = "Number of Variables",
     ylab = "BIC", type = "l", main = "Backwards Selection") # type = "1" changes the points to line

regfit.forw = regsubsets(stroke.df ~., data = train.stroke,nvmax = 14, method = "forward")     # forwards selection 
summary(regfit.forw)
forw.summary <- summary(regfit.forw)
names(forw.summary)
forw.summary$rsq        # about 7-8 variables is when the graph evens out
plot(forw.summary$rsq, xlab = "Number of Variables",
     ylab = "RSQ", type = "l", main = "Forwards Selection") # type = "1" changes the points to line
plot(forw.summary$rsq) # this plot is a great visual to show how many variables are just good enough 
plot(forw.summary$bic, xlab = "Number of Variables",
     ylab = "BIC", type = "l", main = "Forwards Selection") # type = "1" changes the points to line

# logistic model using the smaller selected model
glm.mod.sel <- glm(stroke.df ~ age.df + hypertension.df + heart_disease.df + ever_married.df + children.df + Self_employed.df +
                     avg_glucose_level.df + bmi.df, data = df.stroke, family = binomial)

predicted.sel <- predict(glm.mod.sel, test.stroke, type = "response")
predicted.sel <- ifelse(predicted.sel <0.5, 0, 1)
predicted.sel <- as.factor(predicted)

confusionMatrix(predicted.sel, test.stroke$stroke.df)  # checking the misclassification rates of the selected model


cv_stroke_sel <- cv.glm(df.stroke, glm.mod.sel, K = 10) # cross validation using 10 fold
cv_stroke_sel$delta[1]   # the selected model with 8 variables is comparable to the full model


#Here I'm running crossfold validation on the full model to confirm that using a 10 fold CV for the select model is adequate
glm.stroke.full <- glm(stroke.df ~ .,data = df.stroke, family = binomial)
cv.error.50 <- rep(0, 50) # setting up empty frame
for (i in 2:51) {
  cv.error.50[i-1] <- cv.glm(df.stroke, glm.stroke.full, K = i)$delta[1]
}
cv.error.50[10]

plot(cv.error.50)


# Tree


train.tree <- ctree(stroke.df ~ . , df.stroke, subset = -test.num) # building a tree model on the training data
summary(train.tree)
plot(train.tree)

set.seed(445)
tree.pred <- predict(train.tree, test.stroke)  
stroke.test <- test.stroke$stroke.df
table(stroke.test)
table(tree.pred)
table(tree.pred, stroke.test)  # poor results using decision tree. confusion matrix

#confusionMatrix(tree.pred, test.stroke$stroke.df)

set.seed(14361)
bag.stroke <- randomForest(stroke.df ~ ., data = df.stroke,
                           subset = -test.num, mtry = 14, importance = TRUE) # romdonForest function also doubles as bagging
bag.stroke
plot(bag.stroke)
legend("right", colnames(bag.stroke$err.rate),col=1:4,cex=0.8,fill=1:4)
yhat.bag <- predict(bag.stroke, newdata = test.stroke)
table(yhat.bag)
table(stroke.test)
table(yhat.bag, stroke.test)  # confusion matrix . # poor results using bagging




### Box Plots 
par(mfrow=c(1,3))
boxplot(age, ylab = "Age in years", main = "Subjects Age")

min(age) #0.08
max(age) #82

boxplot(avg_glucose_level, ylab = "Glucose level in mg/dL", main = "Subjects Avg Glucose Lvl")

stroke_data_bmi_filtered <- filter(stroke_data, bmi != "N/A")

boxplot(as.data.frame(stroke_data_bmi_filtered$bmi), ylab = "BMI", main = "Subjects BMI")

max(stroke_data_clean_df$bmi) #97.6


attach(stroke_data_clean_df)

### qq plots (cleaned data)
attach(stroke_data_clean_df)
par(mfrow = c(1,3))
qqnorm(age) 
qqline(age, col = 2)
qqnorm(avg_glucose_level)          # Q-Q plot to check the normality of the data. If data is normal then the data should be linear
qqline(avg_glucose_level, col = 2)
qqnorm(bmi) 
qqline(bmi, col = 2)

#age
par(mfrow = c(1,3))                                           # divides a single graphic grid to 1x3
hist(age, freq=FALSE, xlab="x", ylab="relative frequency",
     breaks="FD", main="Histogram und normal PDF")
#curve(dnorm(age, mean=0, sd=1), lwd=2, col="blue", add=TRUE)    # adds a curve over the histogram
lines(density(age), lwd=2, col="red") ## empirical density estimate
boxplot(age)         # draws a box-whisker plot of values of x
qqnorm(age)          # Q-Q plot to check the normality of the data. If data is normal then the data should be linear
qqline(age, col = 2) # Add a line to the Q-Q plot. Color set to 2 

#avg_glucose_level
par(mfrow = c(1,3))                                           # divides a single graphic grid to 1x3
hist(avg_glucose_level, freq=FALSE, xlab="x", ylab="relative frequency",
     breaks="FD", main="Histogram und normal PDF")
#curve(dnorm(avg_glucose_level, mean=0, sd=1), lwd=2, col="blue", add=TRUE)    # adds a curve over the histogram
lines(density(avg_glucose_level), lwd=2, col="red") ## empirical density estimate
boxplot(avg_glucose_level)         # draws a box-whisker plot of values of x
qqnorm(avg_glucose_level)          # Q-Q plot to check the normality of the data. If data is normal then the data should be linear
qqline(avg_glucose_level, col = 2) # Add a line to the Q-Q plot. Color set to 2 

#bmi
bmi <- as.numeric(bmi)
par(mfrow = c(1,3))                                           # divides a single graphic grid to 1x3
hist(bmi, freq=FALSE, xlab="x", ylab="relative frequency",
     breaks="FD", main="Histogram und normal PDF")
#curve(dnorm(bmi, mean=0, sd=1), lwd=2, col="blue", add=TRUE)    # adds a curve over the histogram
lines(density(bmi), lwd=2, col="red") ## empirical density estimate
boxplot(bmi)         # draws a box-whisker plot of values of x
qqnorm(bmi)          # Q-Q plot to check the normality of the data. If data is normal then the data should be linear
qqline(bmi, col = 2) # Add a line to the Q-Q plot. Color set to 2 
