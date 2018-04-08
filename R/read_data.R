####read data & aggregate
##library
#install.packages("tidyverse")
#install.packages("viridis")
library(tidyverse)
library(viridis)

#read_csv
test_features  <- read.table("Desktop/DengAI/data/dengue_features_test.csv",sep = ",",header = T)
train_features <- read.table("Desktop/DengAI/data/dengue_features_train.csv",sep = ",",header = T)
label <- read.table("Desktop/DengAI/data/dengue_labels_train.csv",sep = ",",header = T)
submission_sample <- read.table("Desktop/DengAI/data/submission_format.csv",sep = ",",header = T)

#merge
train <- left_join(label, train_features) 
train_long <- train %>% gather(key, value, -c(1:3, 5))


# #aggregate
# # Histogram ----
# hi <- train_long %>%
#       ggplot(aes(value, fill = city)) +
#       geom_histogram(bins = 30) +
#       facet_wrap(~ key, scales = "free") +
#       scale_fill_viridis(discrete = TRUE)
# ggsave("Desktop/DengAI/image/test.png", plot = hi)
# 
# # Line graph ----
# g_line <- train_long %>%
#             ggplot(aes(week_start_date, value, color = city, group = city)) +
#             geom_line() +
#             facet_wrap(~ key, scales = "free") +
#             scale_color_viridis(discrete = TRUE)
# ggsave("Desktop/DengAI/image/test2.png", plot = g_line)
# 
# # Total cases ----
# case <- train_long %>%
#           filter(key == "total_cases") %>% 
#           ggplot(aes(week_start_date, value, color = city, group = city)) +
#           geom_line() +
#           scale_color_viridis(discrete = TRUE)
# ggsave("Desktop/DengAI/image/test3.png", plot = case)
# 
# # Total cases per weekofyear ----
# case_per_week <- train_long %>% 
#                     filter(key == "total_cases") %>% 
#                     ggplot(aes(weekofyear, value, color = city, group = year)) +
#                     geom_line() +
#                     scale_color_viridis(discrete = TRUE) +
#                     facet_wrap(~ city)
# ggsave("Desktop/DengAI/image/test4.png", plot = case_per_week)
# 
# # Distribution of events ----
# event <- train_long %>%
#             filter(key == "total_cases") %>% 
#             ggplot(aes(log2(value + 1), fill = city)) +
#             geom_histogram(bins = 60) +
#             scale_fill_viridis(discrete = TRUE)
# ggsave("Desktop/DengAI/image/test5.png", plot = event)