####Submissions
####make matrix for submission
dim(test_features)
dt <- data.table(test_features,keep.rownames = F)

###split city
table(dt$city)
dt_sj <- dt %>%
  filter(city=="sj")
dt_iq <- dt %>%
  filter(city=="iq")
###matrix
dt_sj2 <- dt_sj[,-c(1:4)]
ddt_sj <- xgb.DMatrix(as.matrix(dt_sj2))

dt_iq2 <- dt_iq[,-c(1:4)]
ddt_iq <- xgb.DMatrix(as.matrix(dt_iq2))
#####Prediction
pre_sj <- round(predict(model_sj, newdata = ddt_sj, type = "raw"))
pre_iq <- round(predict(model_iq, newdata = ddt_iq, type = "raw"))

#####makecsv
pre <- c(pre_sj,pre_iq)
sub <- submission_sample
sub$total_cases <- pre
write_csv(sub,path = "Desktop/DengAI/Submission_DengAI.csv")



