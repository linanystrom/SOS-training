################################################################################

# Data preparation - Qualtrics

################################################################################

# Basic setup ------------------------------------------------------------------

packages <- c("readr", "dplyr", "readxl")

lapply(packages, library, character.only = TRUE)

# Load and clean data ----------------------------------------------------------

## Qualtrics data

MC1_raw <- read_csv("data/Qualtrics/TrainingStudy_MC1.csv") %>% slice(-1, -2)
MC1_raw <- MC1_raw  %>%
  select(
    -ends_with(c(
        'Click', 'Submit', 'Count')))


MC2_raw <- read_csv("data/Qualtrics/TrainingStudy_MC2.csv") %>% slice(-1, -2)
MC2_raw <- MC2_raw  %>%
  select(
    -ends_with(c(
      'Click', 'Submit', 'Count')))
MC2_raw <- MC2_raw %>% 
  rename(change_strategy = `change_strategy\n`)


MC3_raw <- read_csv("data/Qualtrics/TrainingStudy_MC3.csv") %>% slice(-1, -2)
MC3_raw <- MC3_raw  %>%
  select(
    -ends_with(c(
      'Click', 'Submit', 'Count')))
MC3_raw <- MC3_raw %>% 
  rename(knowledge_before = `knowledge_before\n`,
         strategy = `strategy\n`)


MC4_raw <- read_csv("data/Qualtrics/TrainingStudy_MC4.csv") %>% slice(-1, -2)
MC4_raw <- MC4_raw  %>%
  select(
    -ends_with(c(
      'Click', 'Submit', 'Count')))


MC5_raw <- read_csv("data/Qualtrics/TrainingStudy_MC5.csv") %>% slice(-1, -2)
MC5_raw <- MC5_raw  %>%
  select(
    -ends_with(c(
      'Click', 'Submit', 'Count')))


MC6_raw <- read_csv("data/Qualtrics/TrainingStudy_MC6.csv") %>% slice(-1, -2)
MC6_raw <- MC6_raw  %>%
  select(
    -ends_with(c(
      'Click', 'Submit', 'Count')))


qualtrics_raw <- do.call("rbind", list(MC1_raw,
                                        MC2_raw,
                                        MC3_raw,
                                        MC4_raw,
                                        MC5_raw,
                                        MC6_raw))

qualtrics_raw <- qualtrics_raw %>% 
  rename(response_id = ResponseId)


## Matching interviewer to interviewee

file_list <- list.files("data/Matching", pattern="*.xlsx", full.names=TRUE)
dataset <- data.frame()

for (i in 1:length(file_list)){
  temp_data <- read_excel(file_list[i],
                          range = cell_cols(c("A","G"))) #each file will be read in, specify which columns you need read in to avoid any errors
  temp_data$Class <- sapply(
    strsplit(
      gsub(".xlsx", "", file_list[i]), "_"), function(x){x[2]}) #clean the data as needed, in this case I am creating a new column that indicates which file each row of data came from
  dataset <- rbind(dataset, temp_data) #for each iteration, bind the new data to the building dataset
}

qualtrics_raw <- merge(qualtrics_raw, dataset, by = "response_id")

qualtrics_raw <- qualtrics_raw %>% 
  rename(id = ID)

### Add training column

excell_long <- read_csv("data/excell_long.csv")

merge_data <- excell_long %>% 
  select(c("id","condition", "interview","sos_training")) 

merge_data <- merge_data %>% distinct()

merge_data <- merge_data %>% 
  mutate(
    interview = case_when(
      interview == 0 ~ 1,
      interview == 1 ~ 2,
      interview == 2 ~ 3,
      interview == 3 ~ 4,
      interview == 4 ~ 5,
      interview == 5 ~ 6)
    )

qualtrics_raw <- merge(qualtrics_raw, merge_data, by = c("id", "interview"), na.rm = TRUE)

qualtrics_raw <- (type_convert(qualtrics_raw))


# create composite measures-----------------------------------------------------

qualtrics_clean <- qualtrics_raw %>% 
  mutate(
    interview_adj_2_R = case_when(
      interview_adj_2 == 5 ~ 1,
      interview_adj_2 == 4 ~ 2,
      interview_adj_2 == 3 ~ 3,
      interview_adj_2 == 2 ~ 4,
      interview_adj_2 == 1 ~ 5
    ),
    interview_adj_4_R = case_when(
      interview_adj_4 == 5 ~ 1,
      interview_adj_4 == 4 ~ 2,
      interview_adj_4 == 3 ~ 3,
      interview_adj_4 == 2 ~ 4,
      interview_adj_4 == 1 ~ 5
    ),
    interview_perc = (
      interview_adj_1 + 
        interview_adj_2_R + 
        interview_adj_3 + 
        interview_adj_4_R + 
        interview_adj_5 + 
        interview_adj_6)/6,
    
    ###Interviewer quality
    
    interviewer_adj_2_R = case_when(
      interviewer_adj_2 == 5 ~ 1,
      interviewer_adj_2 == 4 ~ 2,
      interviewer_adj_2 == 3 ~ 3,
      interviewer_adj_2 == 2 ~ 4,
      interviewer_adj_2 == 1 ~ 5
    ),
    interviewer_adj_3_R = case_when(
      interviewer_adj_3 == 5 ~ 1,
      interviewer_adj_3 == 4 ~ 2,
      interviewer_adj_3 == 3 ~ 3,
      interviewer_adj_3 == 2 ~ 4,
      interviewer_adj_3 == 1 ~ 5
    ),
    interviewer_adj_6_R = case_when(
      interviewer_adj_6 == 5 ~ 1,
      interviewer_adj_6 == 4 ~ 2,
      interviewer_adj_6 == 3 ~ 3,
      interviewer_adj_6 == 2 ~ 4,
      interviewer_adj_6 == 1 ~ 5
    ),
    interviewer_perc = (
      interviewer_adj_1 + 
        interviewer_adj_2_R + 
        interviewer_adj_3_R + 
        interviewer_adj_4 + 
        interviewer_adj_5 + 
        interviewer_adj_6_R)/6,
    
    ### Self-assessment of performance
    
    interview_statements_2 = case_when(
      interview_statements_2 == 5 ~ 1,
      interview_statements_2 == 4 ~ 2,
      interview_statements_2 == 3 ~ 3,
      interview_statements_2 == 2 ~ 4,
      interview_statements_2 == 1 ~ 5
    ),
    interview_statements_3 = case_when(
      interview_statements_3 == 5 ~ 1,
      interview_statements_3 == 4 ~ 2,
      interview_statements_3 == 3 ~ 3,
      interview_statements_3 == 2 ~ 4,
      interview_statements_3 == 1 ~ 5
    ),
    self_assessment = (
      interview_statements_1 + 
        interview_statements_2 + 
        interview_statements_3 + 
        interview_statements_4)/4,
  )

write.csv(
  qualtrics_clean,
  "data/qualtrics_clean.csv",
  row.names = FALSE
)


