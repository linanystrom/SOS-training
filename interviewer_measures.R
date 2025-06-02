################################################################################

# Interviewer behavior

################################################################################

packages <- c("readr", "dplyr", "readxl", "tidyr", "haven")

lapply(packages, library, character.only = TRUE)

# Load data --------------------------------------------------------------------

int_solved <- read_excel("data/interviewer_coding_solved.xlsx") 

cond_info <- read_excel("data/coding_solved.xlsx")

cond_info <- cond_info %>% select(c("ID","condition"))

interviewer_merged <- merge(int_solved, cond_info, by = "ID")

interviewer_merged <- interviewer_merged %>% 
  mutate(sos_training = if_else(condition == "SoS-Delay", case_when(
    Interview_nr == 1 ~ 0,
    Interview_nr == 2 ~ 0,
    Interview_nr == 3 ~ 1,
    Interview_nr == 4 ~ 1
  ),
  ifelse(condition == "Basic", case_when(
    Interview_nr == 1 ~ 0,
    Interview_nr == 2 ~ 0,
    Interview_nr == 3 ~ 0,
    Interview_nr == 4 ~ 0
  ),
  ifelse(condition == "SoS", case_when(
    Interview_nr == 1 ~ 1,
    Interview_nr == 2 ~ 1,
    Interview_nr == 3 ~ 1,
    Interview_nr == 4 ~ 1
  ), NA))))

# Comparing use of measures, untrained vs. trained. ----------------------------

interviewer_merged <- interviewer_merged %>% type_convert()

#INT

t.test(Introduction ~ sos_training, data = interviewer_merged)

#FR

FR_data <- table(interviewer_merged$sos_training, interviewer_merged$Free_recall)

chisq.test(interviewer_merged$sos_training, interviewer_merged$Free_recall,
           correct=FALSE)

#GP

t.test(Guilt_presumption ~ sos_training, data = interviewer_merged)

#FS

t.test(Funnel_structure ~ sos_training, data = interviewer_merged)

#CI

t.test(Challenge_inconsistencies ~ sos_training, data = interviewer_merged)

#RE

t.test(Request_explanation ~ sos_training, data = interviewer_merged)

#RT

t.test(Reinforce_truth ~ sos_training, data = interviewer_merged)

#ST

t.test(`Supportive transistions` ~ sos_training, data = interviewer_merged)

#LQ

t.test(Leading_questions ~ sos_training, data = interviewer_merged)


# Measures predicting information disclosure -----------------------------------


detail_data <- read_excel("data/coding_solved.xlsx")

detail_data <- detail_data %>% 
  mutate(int_sum_1 = int1_st1+int1_st2+int1_st3+int1_st4+int1_st5+int1_st6,
         int_sum_2 = int2_st1+int2_st2+int2_st3+int2_st4+int2_st5+int2_st6,
         int_sum_3 = int3_st1+int3_st2+int3_st3+int3_st4+int3_st5+int3_st6,
         int_sum_4 = int4_st1+int4_st2+int4_st3+int4_st4+int4_st5+int4_st6,
         int_sum_5 = int5_st1+int5_st2+int5_st3+int5_st4+int5_st5+int5_st6,
         int_sum_6 = int6_st1+int6_st2+int6_st3+int6_st4+int6_st5+int6_st6,
         crit_sum_1 = int1_st5+int1_st6,
         crit_sum_2 = int2_st5+int2_st6,
         crit_sum_3 = int3_st5+int3_st6,
         crit_sum_4 = int4_st5+int4_st6,
         crit_sum_5 = int5_st5+int5_st6,
         crit_sum_6 = int6_st5+int6_st6)

detail_data <- detail_data %>% 
  select(c(ID,
           condition,
           mc_sequence,
           int_sum_1,
           int_sum_2,
           int_sum_3,
           int_sum_4,
           int_sum_5,
           int_sum_6,
           crit_sum_1,
           crit_sum_2,
           crit_sum_3,
           crit_sum_4,
           crit_sum_5,
           crit_sum_6))

detail_data <- detail_data %>%
  pivot_longer(
    cols = c("int_sum_1",
             "int_sum_2",
             "int_sum_3",
             "int_sum_4",
             "int_sum_5",
             "int_sum_6",
             "crit_sum_1",
             "crit_sum_2",
             "crit_sum_3",
             "crit_sum_4",
             "crit_sum_5",
             "crit_sum_6"),
    names_to = "interview_sum",
    values_to = "detail")




detail_data <- detail_data %>%
  mutate(interview =  case_when(
    endsWith(interview_sum, "1") ~ 1,
    endsWith(interview_sum, "2") ~ 2,
    endsWith(interview_sum, "3") ~ 3,
    endsWith(interview_sum, "4") ~ 4,
    endsWith(interview_sum, "5") ~ 5,
    endsWith(interview_sum, "6") ~ 6
  ))

detail_data <- detail_data %>%
  mutate(detail_type =  case_when(
    startsWith(interview_sum, "int") ~ "overall_sum",
    startsWith(interview_sum, "crit") ~ "critical_sum"
  ))

detail_data <- detail_data %>%
  select(c(ID, condition, mc_sequence, interview, detail_type, detail))


test <- detail_data %>%
  pivot_wider(names_from = detail_type, values_from = detail)

test$mc_sequence<- gsub(" ", "", test$mc_sequence)

test <- test %>%
  filter(!interview %in% c(5, 6))

detail_data <- test %>%
  mutate(mc_list = str_split(mc_sequence, "")) %>%
  rowwise() %>%
  mutate(MC = mc_list[[interview]]) %>%
  ungroup() %>%
  select(-mc_list)

int_solved <- int_solved %>% 
  rename(
    interview = Interview_nr
  )

detail_merged <- merge(int_solved, detail_data, by = c("ID", "interview"))

detail_merged <- detail_merged %>%type_convert()

# Predicting overall details ---------------------------------------------------

## Model created to assess variance attributed to random effects

M0 <- lmer(overall_sum 
           ~ 1
           + (1|ID) #interviewer
           + (1|MC),
           data=detail_merged,
           REML=TRUE)

summary(M0)

## Assessing variance associated with random effects, effects with ICC below 0.05 will be excluded from models below

performance::icc(M0, by_group = TRUE)

cormat_details <- 
cor(
  select(detail_merged,
         overall_sum,
         critical_sum,
         Introduction,
         Free_recall,
         Guilt_presumption,
         Funnel_structure,
         Challenge_inconsistencies,
         Request_explanation,
         Reinforce_truth,
         `Supportive transistions`,
         Leading_questions),
  use = "pairwise.complete"
)

## Main effects

simple_model <- lmer(overall_sum
                     ~ Introduction
                     + Free_recall
                     + Guilt_presumption
                     + Funnel_structure
                     + Challenge_inconsistencies
                     + Request_explanation
                     + Reinforce_truth
                     + `Supportive transistions`
                     + Leading_questions
                     + (1|ID) #interviewer
                     + (1|MC), 
                     data=detail_merged,
                     REML=FALSE)

summary(simple_model)

# Predicting critical details --------------------------------------------------

## Model created to assess variance attributed to random effects

M0_crit <- lmer(critical_sum 
           ~ 1
           + (1|ID) #interviewer
           + (1|MC),
           data=detail_merged,
           REML=TRUE)

summary(M0_crit)

## Assessing variance associated with random effects, effects with ICC below 0.05 will be excluded from models below

performance::icc(M0_crit, by_group = TRUE)


## Main effects

simple_model_crit <- lmer(critical_sum 
                     ~ Introduction
                     + Free_recall
                     + Guilt_presumption
                     + Funnel_structure
                     + Challenge_inconsistencies
                     + Request_explanation
                     + Reinforce_truth
                     + `Supportive transistions`
                     + Leading_questions
                     + (1|ID) #interviewer
                     + (1|MC), 
                     data=detail_merged,
                     REML=FALSE)

summary(simple_model_crit)





