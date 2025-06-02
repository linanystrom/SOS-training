################################################################################

# Select Random subset for interviewer coding

################################################################################

packages <- c("readr", "dplyr")

lapply(packages, library, character.only = TRUE)

### Seed

set.seed(540)

### Study set up

nr_int        <- 4          #Number interviews
sample        <- 31         #Sample size
id            <- 1:sample



# Set up basic data structure---------------------------------------------------

my_df <- expand.grid(id = id, interview = 1:nr_int)

my_df <-my_df %>% add_row(id = 4, interview = 5)

my_df <-my_df %>% add_row(id = 8, interview = 5)

my_df <-my_df %>% add_row(id = 8, interview = 6)

my_df <-my_df %>% filter(id !='6')
my_df <-my_df %>% add_row(id = 6, interview = 1)
my_df <-my_df %>% add_row(id = 6, interview = 2)

my_df$case <- paste(my_df$id, "-", my_df$interview)

sel <- nrow(my_df)*0.2

rand_df <- my_df[sample(nrow(my_df), size = sel), ]

write.csv(
  rand_df,
  "./code_interviewers.csv",
  row.names = FALSE
)



