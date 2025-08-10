################################################################################

# Effect sizes

################################################################################

packages <- c("readr", "dplyr", "readxl", "tidyr", "compute.es")

lapply(packages, library, character.only = TRUE)

effect_df <- read_csv("data/excell_long.csv")

# 

effect_df$sos_training <- factor(effect_df$sos_training,
                               levels = c(0, 1),
                               labels = c("Basic","SoS"))

effect_df$critical <- factor(effect_df$critical,
                           levels = c(0, 1),
                           labels = c("Non-critical", "Critical"))

crit_desc <- effect_df[complete.cases(effect_df),] %>% filter(critical == "Critical") %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(detail, na.rm = TRUE),
    SD = sd(detail, na.rm = TRUE),
    Median = median(detail, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE),
    n = n()
  )

sum_d_crit <- mes(
  m.1  = crit_desc[crit_desc$sos_training == "SoS", ]$Mean,
  m.2  = crit_desc[crit_desc$sos_training == "Basic", ]$Mean,
  sd.1 = crit_desc[crit_desc$sos_training == "SoS", ]$SD,
  sd.2 = crit_desc[crit_desc$sos_training == "Basic", ]$SD,
  n.1  = crit_desc[crit_desc$sos_training == "SoS", ]$n,
  n.2  = crit_desc[crit_desc$sos_training == "Basic", ]$n
)

gen_desc <- effect_df[complete.cases(effect_df),] %>% 
  group_by(sos_training) %>% 
  summarise(
    Mean = mean(detail, na.rm = TRUE),
    SD = sd(detail, na.rm = TRUE),
    Median = median(detail, na.rm = TRUE),
    SE = SD/sqrt(n()),
    Upper = Mean + (1.96*SE),
    Lower = Mean - (1.96*SE),
    n = n()
  )

sum_d_non_crit <- mes(
  m.1  = gen_desc[gen_desc$sos_training == "SoS", ]$Mean,
  m.2  = gen_desc[gen_desc$sos_training == "Basic", ]$Mean,
  sd.1 = gen_desc[gen_desc$sos_training == "SoS", ]$SD,
  sd.2 = gen_desc[gen_desc$sos_training == "Basic", ]$SD,
  n.1  = gen_desc[gen_desc$sos_training == "SoS", ]$n,
  n.2  = gen_desc[gen_desc$sos_training == "Basic", ]$n
)

effect_df$sum_info <- rowSums(subset(effect_df, select = int1_st1:int1_st6))

