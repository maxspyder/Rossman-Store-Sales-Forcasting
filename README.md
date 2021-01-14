# Rossman-Store-Sales-Forcasting
This Project contains exploratory data analysis, feature extraction and forecasting using regression &amp; Time-series Methodologies (R). 

### Dataset Information
URL: https://www.kaggle.com/c/rossmann-store-sales

Dataset has been taken from Kaggle prediction competitions. 

Dataset includes daily sales information of 1115 Rossman Stores over 31 months from 01-01-2013 to 31-07-2015 in reverse order. 

For major amount of Stores there is no datapoints for last 4 months in 2014. 

### Limitation of this Project
have not taken stores dataset into account. which could have been merged with train dataset to build better model and extract better features. 

Forecasting have been done using very small store IDs to showcase various forecasting method performance. Results have not infered for the whole dataset. 

### Methodologies 

1. Linear regression with crossvalidation is used for feature extraction 

2. regression forecasting includes Linear Regreesion, Penalized Regression, Lasso Regression and a modified version of Penalized Regression. 

3. Time-Series forecasting models includes Naive, seasonal naive, mean average as benachmark models and ARIMA, Holt's linear smoothing, Moving avergare as sophisticated models.

### Results
presentation: https://docs.google.com/presentation/d/1ySjSQUSJNju9TDOZN-FeK6ObmcEtxVs4djIUOCuPTI0/edit?usp=sharing

Modified Penalized Regresion model is recommened for future store sales forecasting. 

Future work can be taking into account non linear models. 
