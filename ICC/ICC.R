################################################################################

# Interrater Reliability Analysis

################################################################################

# Basic setup ------------------------------------------------------------------

packages <- c("readxl", "lme4", "boot")

lapply(packages, library, character.only = TRUE)

source("./ICC/icc_func.R")
set.seed(666)

# Load data --------------------------------------------------------------------

A <- read_xlsx("./ICC/data/coding_A.xlsx") %>% 
  filter(!is.na(int1_st1))

A2 <- read_xlsx("./ICC/data/coding_A2.xlsx")

B <- read_xlsx("./ICC/data/coding_B.xlsx") %>% 
  filter(!is.na(int1_st1))

K <- read_xlsx("./ICC/data/coding_K.xlsx") %>% 
  filter(!is.na(int1_st1))

L <- read_xlsx("./ICC/data/coding_L.xlsx") %>% 
  filter(!is.na(int1_st1))

L2 <- read_xlsx("./ICC/data/coding_L2.xlsx")

P <- read_xlsx("./ICC/data/coding_P.xlsx") %>% 
  filter(!is.na(int1_st1))

# Reshape data -----------------------------------------------------------------

A_long <- A %>% 
  pivot_longer(
    cols = starts_with("int"),
    names_to = "stage",
    values_to = "disclosure"
  ) %>% 
  mutate(
    stage_id = paste(stage, ID, sep = "_"),
    coded_by = "A"
  ) %>% 
  select(ID, stage_id, stage, disclosure, coded_by)

A2_long <- A2 %>% 
  pivot_longer(
    cols = starts_with("int"),
    names_to = "stage",
    values_to = "disclosure"
  ) %>% 
  mutate(
    stage_id = paste(stage, ID, sep = "_"),
    coded_by = "A2"
  ) %>% 
  select(ID, stage_id, stage, disclosure, coded_by)

B_long <- B %>% 
  pivot_longer(
    cols = starts_with("int"),
    names_to = "stage",
    values_to = "disclosure"
  ) %>% 
  mutate(
    stage_id = paste(stage, ID, sep = "_"),
    coded_by = "B"
  ) %>% 
  select(ID, stage_id, stage, disclosure, coded_by)

K_long <- K %>% 
  pivot_longer(
    cols = starts_with("int"),
    names_to = "stage",
    values_to = "disclosure"
  ) %>% 
  mutate(
    stage_id = paste(stage, ID, sep = "_"),
    coded_by = "K"
  ) %>% 
  select(ID, stage_id, stage, disclosure, coded_by)


L_long <- L %>% 
  pivot_longer(
    cols = starts_with("int"),
    names_to = "stage",
    values_to = "disclosure"
  ) %>% 
  mutate(
    stage_id = paste(stage, ID, sep = "_"),
    coded_by = "L"
  ) %>% 
  select(ID, stage_id, stage, disclosure, coded_by)

L2_long <- L2 %>% 
  pivot_longer(
    cols = starts_with("int"),
    names_to = "stage",
    values_to = "disclosure"
  ) %>% 
  mutate(
    stage_id = paste(stage, ID, sep = "_"),
    coded_by = "L2"
  ) %>% 
  select(ID, stage_id, stage, disclosure, coded_by)

P_long <- P %>% 
  pivot_longer(
    cols = starts_with("int"),
    names_to = "stage",
    values_to = "disclosure"
  ) %>% 
  mutate(
    stage_id = paste(stage, ID, sep = "_"),
    coded_by = "P"
  ) %>% 
  select(ID, stage_id, stage, disclosure, coded_by)

coded_stages <- bind_rows(A_long, A2_long, B_long, K_long, L_long, L2_long, P_long)

coded_stages_no_NA <- na.omit(coded_stages)

# Analysis ---------------------------------------------------------------------

disclosure_model <- lmer(disclosure ~ (1|stage_id) + (1|coded_by) + (1|ID), data = coded_stages_no_NA)

icc_test <- icc(disclosure_model, by_group = TRUE)

icc_coder_realiability <- icc_test$ICC[[1]]

disclosure_boot_icc <- bootMer(disclosure_model, icc_boot, nsim = 1000)

disclosure_ci_icc <- boot.ci(disclosure_boot_icc, index = 1, type = "perc")
