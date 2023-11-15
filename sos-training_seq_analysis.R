################################################################################

# SoS-Training- Sequential analysis

################################################################################

# Load necessary packages ------------------------------------------------------

packages <- c("gsDesign", "pwr")

lapply(packages, library, character.only = TRUE)

# Analysis ---------------------------------------------------------------------

sample_size <- 240

sos_gs <- gsDesign(
  k = 2,         # Two test-points
  test.type = 2, 
  alpha = .05,   # One-tailed alpha level
  beta = .20,    # 80% power
  sfupar = .25,  # As per recommendations of Weigl & Ponocny (2020)
  sfu = "WT"     # Wang-Tsiatis approach
)

sos_gs$n.I[1] # Sample size ratio for Analysis 1

sos_gs$upper$prob[1,1] #Nominal p for Analysis 1

# Should the p value be smaller than the nominal p for Analysis 1, we will stop data collection for efficacy.

