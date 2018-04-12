###library
#install.packages("xgboost")
#install.packages("data.table")
#install.packages("caret")

library(xgboost)
library(data.table)
library(Matrix)
library(caret)

#####make model
dim(train)
df <- data.table(train,keep.rownames = F)

###split city
table(df$city)
df_sj <- df %>%
  filter(city=="sj")
df_iq <- df %>%
  filter(city=="iq")

#####make model (XGBoost)
###split train test
num <- 100
result_sj <- matrix(nrow = 2,ncol = num)

for(i in 1:num){
  set.seed(1+i)
  nn_sj <- sample(nrow(df_sj),nrow(df_sj)/3)
  nn_iq <- sample(nrow(df_iq),nrow(df_iq)/3)

  sj_train <- df_sj[-nn_sj,]
  sj_test  <- df_sj[nn_sj,]

  iq_train <- df_iq[-nn_iq,]
  iq_test  <- df_iq[nn_iq,]

  ####xgboost for sj
  y_train_sj <- as.numeric(sj_train[,4])
  x_train_sj <- sj_train[,-c(1:5)]
  xx_train_sj <- xgb.DMatrix(as.matrix(x_train_sj), label = y_train_sj)
  #xxx_train_sj <- xgb.DMatrix(as.matrix(x_train_sj[,-c(1:9)]), label = y_train_sj)

  set.seed(1+i)
  xgb_params = list(
    booster = 'gbtree',
    objective = 'reg:linear',
    colsample_bytree=1,
    eta=0.005,
    max_depth=20,
    min_child_weight=3,
    alpha=0.3,
    lambda=0.4,
    gamma=0.01, # less overfit
    subsample=0.6,
    silent=TRUE)

  #cv.nround <- 5000
  #bst.cv <- xgb.cv(param=xgb_params, data = xx_train_sj,  nfold = 100, nrounds=cv.nround)
  x_test_sj <- sj_test[,-c(1:5)]
  xx_test_sj <- xgb.DMatrix(as.matrix(x_test_sj))
  model_sj <- xgb.train(xgb_params, xx_train_sj, nrounds = 300)
  
  #####Prediction
  test_label_sj <- round(predict(model_sj, newdata = xx_test_sj, type = "raw"))
  #####accuracy
  mae_sj <- MAE(pred = test_label_sj, obs = sj_test$total_cases)
  print(c(i,":",mae_sj), quote=F)
  if(i == 1){
    bst_model_sj <- model_sj
    tmp_i = i
  }else if(min(result_sj[2,], na.rm = T) > mae_sj){
    bst_model_sj <- model_sj
    tmp_i = i
  }
  #####result
  result_sj[1,i] <- i
  result_sj[2,i] <- mae_sj
}


####xgboost for iq
y_train_iq <- as.numeric(iq_train[,4])
x_train_iq <- iq_train[,-c(1:5)]
xx_train_iq <- xgb.DMatrix(as.matrix(x_train_iq), label = y_train_iq)
xxx_train_iq <- xgb.DMatrix(as.matrix(x_train_iq[,-c(1:9)]), label = y_train_iq)

set.seed(100)
xgb_params = list(
  booster = 'gbtree',
  objective = 'reg:linear',
  colsample_bytree=1,
  eta=0.005,
  max_depth=20,
  min_child_weight=3,
  alpha=0.3,
  lambda=0.4,
  gamma=0.01, # less overfit
  subsample=0.6,
  silent=TRUE)

#cv.nround <- 5000
#bst.cv <- xgb.cv(param=xgb_params, data = xx_train_iq,  nfold = 100, nrounds=cv.nround)
x_test_iq <- iq_test[,-c(1:5)]
xx_test_iq <- xgb.DMatrix(as.matrix(x_test_iq))
model_iq <- xgb.train(xgb_params, xx_train_iq, nrounds = 1000)

#####Prediction
test_label_sj <- round(predict(bst_model_sj, newdata = xx_test_sj, type = "raw"))
test_label_iq <- round(predict(model_iq, newdata = xx_test_iq, type = "raw"))

#####accuracy
MAE(pred = test_label_sj, obs = sj_test$total_cases)
MAE(pred = test_label_iq, obs = iq_test$total_cases)
MAE(pred = c(test_label_sj,test_label_iq), obs = c(sj_test$total_cases,iq_test$total_cases))