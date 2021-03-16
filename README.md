# Backward_Elimination_with_feature_selection
Automated backward elimination for regression models with a selection of four features: AIC, BIC, Adjusted R square and P-value.
The function optimizes the input model based on the feature selected.
Inputs: 
  1, dataset
  2, model of interest
  3, name of the outcome variable in string
  4, choice of feature:
            1-----AIC
            2-----BIC
            3-----Adjusted R square
            4-----P-value
  5, choice of significant level in digits
