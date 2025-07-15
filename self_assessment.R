################################################################################

# Exploratory self-assessment

################################################################################

# Load data --------------------------------------------------------------------

interviewee_df <- read_csv("data/qualtrics_clean.csv")

excell_raw <- read_excel("data/coding_solved.xlsx")

# Wrangle data -----------------------------------------------------------------

## Interviewee data 

interviewee_df <- interviewee_df %>% 
  mutate(
    interviewee = paste(as.character(id), as.character(interview), sep = "_"))


interviewee_df <- interviewee_df %>% dplyr::select(c("interviewee",
                                                     "mc",
                                                     "self_assessment",
                                                     "sos_training",
                                                     "interview",
                                                     "id",
                                                     "change_strategy"))


interviewee_df<- interviewee_df %>% mutate(interview=recode(interview,
                                           '1'='0',
                                           '2'='1',
                                           '3'='2',
                                           '4'='3',
                                           '5'='4',
                                           '6'='5'))


merge_data <- interviewee_df %>% dplyr::select(c("interviewee", "self_assessment"))

## Info data 

excell_raw <- read_excel("data/coding_solved.xlsx")

excell_raw <- excell_raw %>% 
  rename(
    id  = ID
  )

excell_raw <- excell_raw %>% 
  mutate(sum_1 = int1_st1 +
           int1_st2 +
           int1_st3 +
           int1_st4 +
           int1_st5 +
           int1_st6,
         sum_2 = int2_st1 +
           int2_st2 +
           int2_st3 +
           int2_st4 +
           int2_st5 +
           int2_st6,
         sum_3 = int3_st1 +
           int3_st2 +
           int3_st3 +
           int3_st4 +
           int3_st5 +
           int3_st6,
         sum_4 = int4_st1 +
           int4_st2 +
           int4_st3 +
           int4_st4 +
           int4_st5 +
           int4_st6,
         sum_5 = int5_st1 +
           int5_st2 +
           int5_st3 +
           int5_st4 +
           int5_st5 +
           int5_st6,
         sum_6 = int6_st1 +
           int6_st2 +
           int6_st3 +
           int6_st4 +
           int6_st5 +
           int6_st6)


excell_raw <- excell_raw  %>% dplyr::select(c("id",
                                              "sum_1",
                                              "sum_2",
                                              "sum_3",
                                              "sum_4",
                                              "sum_5",
                                              "sum_6"))

excell_raw <- excell_raw  %>% 
  pivot_longer(
    cols = c("sum_1",
             "sum_2",
             "sum_3",
             "sum_4",
             "sum_5",
             "sum_6"),
    names_to = "interview",
    values_to = "sum")


excell_raw <- excell_raw %>% 
  mutate(
    interview = case_when(
      interview ==  "sum_1" ~ 1,
      interview ==  "sum_2" ~ 2,
      interview ==  "sum_3" ~ 3,
      interview ==  "sum_4" ~ 4,
      interview ==  "sum_5" ~ 5,
      interview ==  "sum_6" ~ 6))


excell_raw <- excell_raw %>% 
  mutate(
    interviewee = paste(as.character(id), as.character(interview), sep = "_"))


# Merge data

self_assessment <- merge(excell_raw, interviewee_df, by = c("interviewee"), na.rm = FALSE)


self_model <- lmer(sum
                     ~ sos_training 
                     + self_assessment
                     + (1|id.x)                  #interviewer
                     #+ (1|mc:interviewee) #interviewee nested in MC
                     + (1|mc), #removed to simplify model if applicable
                     data=self_assessment,
                     REML=FALSE)

summary(self_model)

self_model_int <- lmer(sum
                   ~ sos_training 
                   + self_assessment
                   + sos_training*self_assessment
                   + (1|id.x)                  #interviewer
                   #+ (1|mc:interviewee) #interviewee nested in MC
                   + (1|mc), #removed to simplify model if applicable
                   data=self_assessment,
                   REML=FALSE)

summary(self_model_int)

### Compare model fit

anova(self_model, self_model_int, refit=FALSE) 

