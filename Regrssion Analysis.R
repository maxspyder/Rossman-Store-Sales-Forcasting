library(forecast)
library(mlbench)
library(caret)
library(psych)
library(car)
library(leaps)
library(DescTools)
library(dplyr)
library(readr)
library(data.table)
library(lubridate)
Train <- fread("train.csv",stringsAsFactors = TRUE)
subsetx <- filter(Train, Store<5)
summary(subsetx)
sum(is.na(subsetx))
subsetx$Date <- as.Date(subsetx$Date)
subsetx$Month <- month(subsetx$Date)
subsetx$Year <- year(subsetx$Date)
subsetx$Week <- week(subsetx$Date)
correlationMatrix <- cor(subsetx[,c(1:2,4:7,9:12)])
correlationMatrix
highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.5)
print(highlyCorrelated)
pairs.panels(subsetx[,c(1:2,4:7,9:12)])

test <- filter(subsetx, Date >= "2015-02-01")
train <- filter(subsetx, Date < "2015-02-01")

model <- regsubsets(Sales~.,train,nvmax = 10)
reg.summary<-summary(model)
reg.summary
plot(reg.summary$adjr2,xlab="Number of Variables",ylab="Adjusted RSq",type="l")
which.max(reg.summary$adjr2)
plot(reg.summary$cp,xlab="Number of Variables",ylab="Cp",type='l')
plot(reg.summary$bic,xlab="Number of Variables",ylab="BIC",type='l')
which.min(reg.summary$bic)

train$Customers <- NULL
test$Customers <- NULL

control <- trainControl(method="repeatedcv", number=5)
model <- train(Sales~., data=train, method="lm", preProcess="scale", trControl=control)
importance <- varImp(model, scale=FALSE)
importance
plot(importance)

# selected Open, Promo, DayOfWeek, Week, Date, Year, StateHolidays, Store

NewModel <- train(Sales~Open+Promo+DayOfWeek+Week+Date+Year+Store, data=train, method="lm", preProcess="scale", trControl=control)
predictions <- predict(NewModel, test)
accuracy(predictions,test$Sales)

NewModel2 <- train(Sales~Open+Promo+DayOfWeek+Week+Date+Year+Store, data=train, method="penalized", preProcess="scale", trControl=control)
predictions2 <- predict(NewModel2, test)
accuracy(predictions2,test$Sales)

NewModel3 <- train(Sales~Open+Promo+DayOfWeek+Week+Date+Year+Store, data=train, method="lasso", preProcess="scale", trControl=control)
predictions3 <- predict(NewModel3, test)
accuracy(predictions3,test$Sales)

stepmodel <- train(Sales~Open+Promo+DayOfWeek+Week+Date+Year+Store, data=train, method="penalized", preProcess="scale", trControl=control)
predictions4 <- predict(stepmodel, test)
pred2 <- data.frame(predictions4,test$Open)
pred2$predictions4[which(pred2$test.Open == 0)] <- 0
x <- as.numeric(pred2$predictions4)
accuracy(x,test$Sales)

# Time Series

TS1 <- rev(filter(train,Store==1)$Sales)
Test1 <- rev(filter(test,Store==1)$Sales)

msts1 <- msts(TS1,seasonal.periods = c(7,365.25),start = decimal_date(as.Date("2013-01-01")))
Test1 <- msts(Test1,seasonal.periods = c(7,365.25),start = decimal_date(as.Date("2015-02-01")))
msts1 <- log10(msts1)
msts1 <- do.call(data.frame,                      # Replace Inf in data by NA
                 lapply(msts1,
                        function(x) replace(x, is.infinite(x), NA)))
msts1 <-na.interp(msts1)
msts1 <- msts(msts1,seasonal.periods = c(7,365.25),start = decimal_date(as.Date("2013-01-01")))

ggseasonplot(msts1, year.labels=TRUE, year.labels.left=TRUE)
autoplot(stl(msts1,s.window = "periodic"))

ABC <- log10(Test1)
ABC <- do.call(data.frame,                      # Replace Inf in data by NA
                 lapply(ABC,
                        function(x) replace(x, is.infinite(x), NA)))
ABC <- msts(ABC,seasonal.periods = c(7,365.25),start = decimal_date(as.Date("2015-02-01")))

#ABC = log Future Time series with NA
#Benchmarking

fit1 <- meanf(msts1,h=181) #mean
fit2 <- rwf(msts1,h=181)   #naive
fit3 <- snaive(msts1,h=181) #snaive

autoplot(msts1) +
  autolayer(fit1, series="Mean", PI=FALSE) +
  autolayer(fit2, series="Naïve", PI=FALSE) +
  autolayer(fit3, series="Seasonal naïve", PI=FALSE) +
  xlab("Year") + ylab("log(Sales)") +
  ggtitle("Forecasts for Sales") +
  guides(colour=guide_legend(title="Forecast"))

predfit1 <- 10^(fit1$mean)
predfit2 <- 10^(fit2$mean)
predfit3 <- 10^(fit3$mean)
accuracy(predfit1,Test1)
accuracy(predfit2,Test1)
accuracy(predfit3,Test1)

# Exponential Smoothing & ARIMA

# Holt's Linear Smoothing, Moving Avergae last 15 days

fit4 <- holt(msts1, damped = TRUE, h=181)

fit5 <- forecast(ma(msts1,30),181)

#Auto Arima with low AIC, AICc, BIC value

auto.arima(msts1)
#Arima(4,0,3)
fit6 <- forecast(Arima(msts1,order = c(4,0,3)),h=181)

autoplot(msts1) +
  autolayer(fit4, series="Holts smoothing", PI=FALSE) +
  autolayer(fit5, series="Moving Average", PI=FALSE) +
  autolayer(fit6, series="Arima", PI=FALSE) +
  xlab("Year") + ylab("log(Sales)") +
  ggtitle("Forecasts for Sales") +
  guides(colour=guide_legend(title="Forecast"))
autoplot(msts1) +
  autolayer(fit6, series="ARIMA", PI=FALSE)+
  guides(colour=guide_legend(title="Daily forecasts"))

predfit4 <- 10^(fit4$mean)
predfit5 <- 10^(fit5$mean)
predfit6 <- 10^(fit6$mean)
accuracy(predfit4,Test1)
accuracy(predfit5,Test1)
accuracy(predfit6,Test1)