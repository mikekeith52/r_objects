# Create accuracy graph - whichever there is more of (0s or 1s) is the 'positive' class
# in this case, the positive class is 0 since there are more 0s than 1s
cutoffs_eval <- function(model, tuning_set, pred_col, iters = 1000, plot = T) {
  message('function evaluates cutoff metrics for two-class estimators')
  message('0/1 only accepted predicted values')
  if (plot == T) {
    library(tidyverse)
    message('plotting with tidyverse')
  }
  w <- which(names(tuning_set) == as.character(pred_col))
  for (i in 1:nrow(tuning_set)){
    if (tuning_set[[w]][i] != 1 & tuning_set[[w]][i] != 0) {
      stop(paste('non 0/1 binary class detected in', 
                 pred_col, 'column'))
    }
  }
  df <- data.frame(cutoff = rep(0, iters), accuracy = rep(0, iters), 
                   specificity = rep(0, iters), sensitivity = rep(0, iters))
  for (i in 1:iters) {
    p <- predict(model, tuning_set, type = 'prob')
    p_class <- ifelse(p[[2]] >= i/iters, 1, 0)
    evaluator <- data.frame(table(as.factor(tuning_set[[w]]), as.factor(p_class)))
    df$cutoff[i] <- i/iters
    if (sum(p_class == 1) == 0) {
      df$accuracy[i] <- sum(tuning_set[[w]] == 0)/length(tuning_set[[w]])
      if (sum(tuning_set[[w]] == 0) > sum(tuning_set[[w]] == 1)) {
        df$sensitivity[i] <- 1
        df$specificity[i] <- 0
      }
      else {
        df$sensitivity[i] <- 0
        df$specificity[i] <- 1 
      }
    }
    else if (sum(p_class == 0) == 0){
      df$accuracy[i] <- sum(tuning_set[[w]] == 1)/length(tuning_set[[w]])
      if (sum(tuning_set[[w]] == 0) > sum(tuning_set[[w]] == 1)) {
        df$sensitivity[i] <- 0
        df$specificity[i] <- 1
      }
      else {
        df$sensitivity[i] <- 1
        df$specificity[i] <- 0 
      }
    }
    else {
      df$accuracy[i] <- (evaluator[evaluator[[2]] == 0 & evaluator[[1]] == 0, 3] + 
                           evaluator[evaluator[[2]] == 1 & evaluator[[1]] == 1, 3]) /
        sum(evaluator$Freq)
      if (sum(tuning_set[[w]] == 0) > sum(tuning_set[[w]] == 1)) {
        df$sensitivity[i] <- evaluator[evaluator[[2]] == 0 & evaluator[[1]] == 0, 3] / 
          (evaluator[evaluator[[2]] == 0 & evaluator[[1]] == 0, 3] + 
             evaluator[evaluator[[2]] == 1 & evaluator[[1]] == 0, 3])
        df$specificity[i] <- evaluator[evaluator[[2]] == 1 & evaluator[[1]] == 1, 3] / 
          (evaluator[evaluator[[2]] == 1 & evaluator[[1]] == 1, 3] + 
             evaluator[evaluator[[2]] == 0 & evaluator[[1]] == 1, 3])
      }
      else {
        df$sensitivity[i] <- evaluator[evaluator[[2]] == 0 & evaluator[[1]] == 0, 3] / 
          (evaluator[evaluator[[2]] == 0 & evaluator[[1]] == 0, 3] + 
             evaluator[evaluator[[2]] == 1 & evaluator[[1]] == 0, 3])
        df$specificity[i] <- evaluator[evaluator[[2]] == 1 & evaluator[[1]] == 1, 3] / 
          (evaluator[evaluator[[2]] == 1 & evaluator[[1]] == 1, 3] + 
             evaluator[evaluator[[2]] == 0 & evaluator[[1]] == 1, 3])  
      }
    }
  }
  if (sum(tuning_set[[w]] == 0) > sum(tuning_set[[w]] == 1)) {
    message('successful evaluation - positive class is 0')
  }
  else {
    message('successful evaluation - positive class is 1')
  }
  if (plot == T) {
    print(df %>%
             gather(key, value, accuracy, sensitivity, specificity) %>%
             ggplot(aes(x = cutoff, y = value, color = key)) +
             geom_point() + 
             geom_smooth() +
             ggtitle('Cutoff Relationships for Model'))
  }
  return(df)
}