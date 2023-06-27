#Generating random assignment

## Set up ----------------------------------------------------------------------

### Packages

packages <- c("gtools", "readr", "tibble", "dplyr", "data.table", "tidyr", "randomizr")

lapply(packages, library, character.only = TRUE)

### Seed

set.seed(414)

### Study set up

nr_mcs        <- 6          #Number of mock crimes
nr_cond       <- 3          #Number of conditions
sample        <- 60         #Sample size
dc_units      <- sample/ 15 #Number of 15 participant sessions required
day           <- 1:dc_units
id            <- 1:sample
mcs           <- c("1", "2", "3", "4", "5", "6")

## Random assignment -----------------------------------------------------------

### Create permutations for mock crime order

perm_list <- permutations(n = nr_mcs, r = nr_mcs, v = mcs)

colnames(perm_list) <- c("int_1","int_2", "int_3", "int_4", "int_5", "int_6")

perm_list <- data.frame(perm_list)

perm_list$sequence <-
  paste(
    perm_list$int_1,
    perm_list$int_2,
    perm_list$int_3,
    perm_list$int_4,
    perm_list$int_5,
    perm_list$int_6
  )

### Create data frame for random assignment

random_assignment <- expand.grid(ID = id)

random_assignment <- random_assignment %>% mutate(
  day = case_when(
    id == (1:15)  ~ 1,
    id == (16:30) ~ 2,
    id == (31:45) ~ 3,
    id == (46:60) ~ 4
  )
) 

random_assignment$sequence <- sample(perm_list$sequence, sample, replace=TRUE)

## long form

### Separate data into sessions to ensure 5 participants are placed in each condition, each session.

random_assignment1 <- random_assignment[random_assignment$day == 1, ]
random_assignment2 <- random_assignment[random_assignment$day == 2, ]
random_assignment3 <- random_assignment[random_assignment$day == 3, ]
random_assignment4 <- random_assignment[random_assignment$day == 4, ]


random_assignment1$cond <- complete_ra(N = nrow(random_assignment1),
                        m_each = c(5,5,5),
                        conditions = c("Basic",
                                       "SoS",
                                       "SoS-Delay"))

random_assignment2$cond <- complete_ra(N = nrow(random_assignment2),
                        m_each = c(5,5,5),
                        conditions = c("Basic",
                                       "SoS",
                                       "SoS-Delay"))

random_assignment3$cond <- complete_ra(N = nrow(random_assignment3),
                        m_each = c(5,5,5),
                        conditions = c("Basic",
                                       "SoS",
                                       "SoS-Delay"))

random_assignment4$cond <- complete_ra(N = nrow(random_assignment4),
                        m_each = c(5,5,5),
                        conditions = c("Basic",
                                       "SoS",
                                       "SoS-Delay"))

### Bind data

random_assignment <- bind_rows(random_assignment1,
                               random_assignment2,
                               random_assignment3,
                               random_assignment4)

### Sanity check

overall_count <- count(random_assignment, cond, day)

## Export random assignment document

write.csv(random_assignment,
          "./random_assignment.csv",
          row.names = FALSE)