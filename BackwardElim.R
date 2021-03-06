
# We start by creating some helper functions which will be called in 
# the main functions:


# dropCol drops a specific column by its column name from the 
# dataframe, it returns the updated dataframe
dropCol <- function(dataframe,colname) {
  drops <- c(colname)
  dataframe1 <- dataframe[ , !(names(dataframe) %in% drops)]
  return(dataframe1)
}


# getCol finds the column index of a specific variable
getCol <- function(dataframe, varname) {
  k <- which(names(dataframe) %in% varname)
  return(k)
}

# Main function
backwardElim <- function(dataframe, Mfull, outcome, critiria, alpha){
  
  ###############################
  # access selection critiria:  #
  # 1: AIC                      #
  # 2: BIC                      #
  # 3: Adjusted r square        #
  # 4: P-Value                  #
  ###############################
  
  Mback <- Mfull
  k <- getCol(dataframe, outcome)
  
  # Eliminate by AIC
  if (critiria == 1) {
    
    # Set up the parameters
    dataframe1 <- dataframe
    p <- length(dataframe1)
    AICList <- rep(0,p-1)
    MinAIC <- AIC(Mback)
    
    # The outer loop will be a while loop conditioning on the value of p
    # if p reaches 1 then it means we have reached M0 and eliminated all 
    # of the covariates except for the outcome itself.
    while (p>1) {
      
      # The inner loop is a for loop to drop every column (covariate) in the   
      # dataframe and record the AIC of the model without that covariate.
      # The value of that particular AIC is stored in AICList.
      for (i in c(1:p)) {
        
        # Exclude the column of the outcome (y).
        if (i == k){
          next
        } else { 
          
          # obtain a trial lm by dropping the ith column.
          Mtrial <- update(Mback, data = dataframe1[,-i])
          # record its AIC into the ith slot of the AICList
          AICList[i] <- AIC(Mtrial)
        }
      } 
      # Once we have all the AICs we check if the minimum is less 
      # than the AIC of the current model
      if (min(AICList) < MinAIC) {
        j <- which.min(AICList)
        dataframe1 <- dataframe1[,-j]
        Mback <- update(Mback, data = dataframe1)
        AICList <- AICList[-j]
        MinAIC <- AIC(Mback)
        p = p-1
        
        # if the minimum of all the AICs is greater than the current model 
        # we break the loop and return that model as a result
      } else {
        break
        return(Mback)
      }
    }
    return(Mback)   
    
  } ###############################################################################
  
  # Eliminate by BIC. The process for BIC and Adjusted R square
  # are exactly the same as AIC
  else if (critiria == 2) {
    
    dataframe2 <- dataframe
    p <- length(dataframe2)
    BICList <- rep(0,p-1)
    MinBIC <- BIC(Mback)
    
    while (p>1) {
      
      for (i in c(1:p)) {
        if (i == k){
          next
        } else { 
          Mtrial <- update(Mback, data = dataframe2[,-i])
          BICList[i] <- BIC(Mtrial)
        }
      }
      
      if (min(BICList) < MinBIC) {
        j <- which.min(BICList)
        dataframe2 <- dataframe2[,-j]
        Mback <- update(Mback, data = dataframe2)
        BICList <- BICList[-j]
        MinBIC <- BIC(Mback)
        p = p-1
      } else {
        break
        return(Mback)
      }
    }
    return(Mback)
  } ###############################################################################
  
  # Eliminate by adjusted R squared
  else if (critiria == 3) {
    
    dataframe3 <- dataframe
    p <- length(dataframe3)
    RsqrList <- rep(0,p-1)
    MaxRsqr <- summary(Mback)$adj.r.squared
    
    while (p>1) {
      
      for (i in c(1:p)) {
        if (i == k){
          next
        } else { 
          Mtrial <- update(Mback, data = dataframe3[,-i])
          RsqrList[i] <- summary(Mtrial)$adj.r.squared
        }
      }
      
      # Note that we prefer higher adj R square unlike AIC and BIC
      if (max(RsqrList) > MaxRsqr) {
        j <- which.max(RsqrList)
        dataframe2 <- dataframe3[,-j]
        Mback <- update(Mback, data = dataframe3)
        RsqrList <- RsqrList[-j]
        MaxRsqr <- summary(Mback)$adj.r.squared
        p = p-1
      } else {
        break
        return(Mback)
      }
    }
    return(Mback)
  }############################################################################### 
  
  # Lastly, elimination based on p-value
  else {
    
    dataframe4 <- dataframe
    repeat{
      
      # create a table based on the drop1() function 
      # with F test results:
      FTable <- drop1(Mback, test = "F")
      
      # If the maximum value in the list of Pr(>F) is less than
      # alpha, stop the loop and return the current model
      if (max(FTable$'Pr(>F)', na.rm = TRUE) < alpha)  {
        break
      } 
      
      # else drop the covariate with the highest p-value
      else {
        rname <- rownames(FTable)[which.max(FTable$'Pr(>F)')]
        dataframe4 <- dropCol(dataframe4, rname)
        Mback <- update(Mback, data = dataframe4)
      }
    }
    return(Mback)
  } 
}



