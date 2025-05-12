ICC_func <- function(x) {
  
  model <- x
  model_vcov <- summary(model)$varcor %>%  as.data.frame()
  model_icc <- model_vcov$vcov/sum(model_vcov$vcov)
  return(model_icc)
}

icc_boot <- function(x) {
  
  icc_test <- icc(x, by_group = TRUE)
  
  return(icc_test$ICC[[1]])
  
}
