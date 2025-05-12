################################################################################

# SoS - Training, Interrater Reliability Analysis

################################################################################

packages <- c("tidyverse", "readxl", "lme4", "boot", "irrCAC")

lapply(packages, library, character.only = TRUE)

source("icc_func.r")
set.seed(666)

## Load data -------------------------------------------------------------------

LN <- read_xlsx("./data/ICC/LN.xlsx") 

TL <- read_xlsx("./data/ICC/TL.xlsx") 

EN <- read_xlsx("./data/ICC/EN.xlsx") 

AK <- read_xlsx("./data/ICC/AK.xlsx") %>% 
  filter(!is.na(Introduction))

AT <- read_xlsx("./data/ICC/AT.xlsx") %>% 
  filter(!is.na(Introduction))

GS <- read_xlsx("./data/ICC/GS.xlsx") %>% 
  filter(!is.na(Introduction))

BB <- read_xlsx("./data/ICC/BB.xlsx") %>% 
  filter(!is.na(Introduction))

# Introduction ----------------------------------------------------------------

LN_intro <- LN %>% 
  filter(!is.na(Introduction))

LN_intro <- LN_intro %>% select(ID, Interview_nr, Introduction) %>% mutate(
  coded_by = "LN",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

TL_intro <- TL %>% 
  filter(!is.na(Introduction))

TL_intro <- TL_intro %>% select(ID, Interview_nr, Introduction) %>% mutate(
  coded_by = "TL",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

EN_intro <- EN %>% 
  filter(!is.na(Introduction))

EN_intro <- EN_intro %>% select(ID, Interview_nr, Introduction) %>% mutate(
  coded_by = "EN",
  intro_id = paste(ID, Interview_nr, sep = "_")
) 

AK_intro <- AK %>% select(ID, Interview_nr, Introduction) %>% mutate(
  coded_by = "AK",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

AT_intro <- AT %>% select(ID, Interview_nr, Introduction) %>% mutate(
  coded_by = "AT",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

GS_intro <- GS %>% select(ID, Interview_nr, Introduction) %>% mutate(
  coded_by = "GS",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

BB_intro <- BB %>% select(ID, Interview_nr, Introduction) %>% mutate(
  coded_by = "BB",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

coded_stages_intro <- bind_rows(LN_intro,
                                TL_intro,
                                EN_intro,
                                AK_intro,
                                AT_intro,
                                GS_intro,
                                BB_intro)

## Intro ICC -------------------------------------------------------------------

intro_model <- lmer(Introduction ~ (1|intro_id) + (1|coded_by),
                    data = coded_stages_intro)

intro_icc <- ICC_func(intro_model)

intro_boot_icc <- bootMer(intro_model, ICC_func, nsim = 1000)

intro_ci_icc <- boot.ci(intro_boot_icc, index = 1, type = "perc")

# Free Recall ------------------------------------------------------------------

LN_FR <- LN %>% 
  filter(!is.na(Introduction)) %>% select(ID,
                                          Interview_nr,
                                          Free_recall) %>% mutate(
    coded_by = "LN",
    intro_id = paste(ID, Interview_nr, sep = "_")
  )

TL_FR <- TL %>% 
  filter(!is.na(Introduction)) %>% select(ID,
                                          Interview_nr,
                                          Free_recall) %>% mutate(
    coded_by = "TL",
    intro_id = paste(ID, Interview_nr, sep = "_")
  )

EN_FR <- EN %>% 
  filter(!is.na(Introduction)) %>% select(ID,
                                          Interview_nr,
                                          Free_recall) %>% mutate(
    coded_by = "EN",
    intro_id = paste(ID, Interview_nr, sep = "_")
  )

AK_FR <- AK %>% select(ID,
                       Interview_nr,
                       Free_recall) %>% mutate(
  coded_by = "AK",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

AT_FR <- AT %>% select(ID,
                       Interview_nr,
                       Free_recall) %>% mutate(
  coded_by = "AT",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

GS_FR <- GS %>% select(ID,
                       Interview_nr,
                       Free_recall) %>% mutate(
  coded_by = "GS",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

BB_FR <- BB %>% select(ID,
                       Interview_nr,
                       Free_recall) %>% mutate(
  coded_by = "BB",
  intro_id = paste(ID, Interview_nr, sep = "_")
)

coded_stages_FR <- bind_rows(LN_FR,
                             TL_FR,
                             EN_FR,
                             AK_FR,
                             AT_FR,
                             GS_FR,
                             BB_FR)

FR_wide <- coded_stages_FR %>%
  pivot_wider(names_from = coded_by, values_from = Free_recall) %>% select(
    LN, TL, EN, AK, AT, GS, BB
  )

gwet.ac1.raw(FR_wide)

# Guilt presumption ------------------------------------------------------------

LN_GS <- LN %>% 
  filter(!is.na(Guilt_presumption)) %>% select(ID,
                                               Interview_nr,
                                               Guilt_presumption) %>% mutate(
                                            coded_by = "LN",
                                            intro_id = paste(ID,
                                                             Interview_nr,
                                                             sep = "_")
                                               )

TL_GS <- TL %>% 
  filter(!is.na(Guilt_presumption)) %>% select(ID,
                                          Interview_nr,
                                          Guilt_presumption) %>% mutate(
                                            coded_by = "TL",
                                            intro_id = paste(ID,
                                                             Interview_nr,
                                                             sep = "_")
                                          )

EN_GS <- EN %>% 
  filter(!is.na(Guilt_presumption)) %>% select(ID,
                                          Interview_nr,
                                          Guilt_presumption) %>% mutate(
                                            coded_by = "EN",
                                            intro_id = paste(ID,
                                                             Interview_nr,
                                                             sep = "_")
                                          )


coded_stages_GS <- bind_rows(LN_GS,
                             TL_GS,
                             EN_GS)

## GS ICC ----------------------------------------------------------------------

GS_model <- lmer(Guilt_presumption ~ (1|intro_id) + (1|coded_by),
                    data = coded_stages_GS)

GS_icc <- ICC_func(GS_model)

GS_boot_icc <- bootMer(GS_model, ICC_func, nsim = 1000)

GS_ci_icc <- boot.ci(GS_boot_icc, index = 1, type = "perc")


# Funnel Structure -------------------------------------------------------------

LN_FS <- LN %>% 
  filter(!is.na(Funnel_structure)) %>% select(ID,
                                               Interview_nr,
                                               Funnel_structure) %>% mutate(
                                                 coded_by = "LN",
                                                 intro_id = paste(ID,
                                                                  Interview_nr,
                                                                  sep = "_")
                                               )

TL_FS <- TL %>% 
  filter(!is.na(Funnel_structure)) %>% select(ID,
                                               Interview_nr,
                                               Funnel_structure) %>% mutate(
                                                 coded_by = "TL",
                                                 intro_id = paste(ID,
                                                                  Interview_nr,
                                                                  sep = "_")
                                               )

EN_FS <- EN %>% 
  filter(!is.na(Funnel_structure)) %>% select(ID,
                                               Interview_nr,
                                               Funnel_structure) %>% mutate(
                                                 coded_by = "EN",
                                                 intro_id = paste(ID,
                                                                  Interview_nr,
                                                                  sep = "_")
                                               )


coded_stages_FS <- bind_rows(LN_FS,
                             TL_FS,
                             EN_FS)

## FS ICC ----------------------------------------------------------------------

FS_model <- lmer(Funnel_structure ~ (1|intro_id) + (1|coded_by),
                 data = coded_stages_FS)

FS_icc <- ICC_func(FS_model)

FS_boot_icc <- bootMer(FS_model, ICC_func, nsim = 1000)

FS_ci_icc <- boot.ci(FS_boot_icc, index = 1, type = "perc")


# Challenging inconsistencies --------------------------------------------------

LN_CI <- LN %>% 
  filter(!is.na(Challenge_inconsistencies)) %>% select(ID,
                                          Interview_nr,
                                          Challenge_inconsistencies) %>% mutate(
                                            coded_by = "LN",
                                            intro_id = paste(ID, Interview_nr, sep = "_")
                                          )

TL_CI <- TL %>% 
  filter(!is.na(Challenge_inconsistencies)) %>% select(ID,
                                          Interview_nr,
                                          Challenge_inconsistencies) %>% mutate(
                                            coded_by = "TL",
                                            intro_id = paste(ID, Interview_nr, sep = "_")
                                          )

EN_CI <- EN %>% 
  filter(!is.na(Challenge_inconsistencies)) %>% select(ID,
                                          Interview_nr,
                                          Challenge_inconsistencies) %>% mutate(
                                            coded_by = "EN",
                                            intro_id = paste(ID, Interview_nr, sep = "_")
                                          )

AK_CI <- AK %>% select(ID,
                       Interview_nr,
                       Challenge_inconsistencies) %>% mutate(
                         coded_by = "AK",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

AT_CI <- AT %>% select(ID,
                       Interview_nr,
                       Challenge_inconsistencies) %>% mutate(
                         coded_by = "AT",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

GS_CI <- GS %>% select(ID,
                       Interview_nr,
                       Challenge_inconsistencies) %>% mutate(
                         coded_by = "GS",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

BB_CI <- BB %>% select(ID,
                       Interview_nr,
                       Challenge_inconsistencies) %>% mutate(
                         coded_by = "BB",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

coded_stages_CI <- bind_rows(LN_CI,
                             TL_CI,
                             EN_CI,
                             AK_CI,
                             AT_CI,
                             GS_CI,
                             BB_CI)


## CI ICC ----------------------------------------------------------------------

CI_model <- lmer(Challenge_inconsistencies ~ (1|intro_id) + (1|coded_by),
                 data = coded_stages_CI)

CI_icc <- ICC_func(CI_model)

CI_boot_icc <- bootMer(CI_model, ICC_func, nsim = 1000)

CI_ci_icc <- boot.ci(CI_boot_icc, index = 1, type = "perc")
# Request explanation ----------------------------------------------------------


LN_RE <- LN %>% 
  filter(!is.na(Request_explanation)) %>% select(ID,
                                                 Interview_nr,
                                                 Request_explanation) %>% mutate(
                                                         coded_by = "LN",
                                                         intro_id = paste(ID, Interview_nr, sep = "_")
                                                       )

TL_RE <- TL %>% 
  filter(!is.na(Request_explanation)) %>% select(ID,
                                                 Interview_nr,
                                                 Request_explanation) %>% mutate(
                                                         coded_by = "TL",
                                                         intro_id = paste(ID, Interview_nr, sep = "_")
                                                       )

EN_RE <- EN %>% 
  filter(!is.na(Request_explanation)) %>% select(ID,
                                                 Interview_nr,
                                                 Request_explanation) %>% mutate(
                                                         coded_by = "EN",
                                                         intro_id = paste(ID, Interview_nr, sep = "_")
                                                       )

AK_RE <- AK %>% select(ID,
                       Interview_nr,
                       Request_explanation) %>% mutate(
                         coded_by = "AK",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

AT_RE <- AT %>% select(ID,
                       Interview_nr,
                       Request_explanation) %>% mutate(
                         coded_by = "AT",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

GS_RE <- GS %>% select(ID,
                       Interview_nr,
                       Request_explanation) %>% mutate(
                         coded_by = "GS",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

BB_RE <- BB %>% select(ID,
                       Interview_nr,
                       Request_explanation) %>% mutate(
                         coded_by = "BB",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

coded_stages_RE <- bind_rows(LN_RE,
                             TL_RE,
                             EN_RE,
                             AK_RE,
                             AT_RE,
                             GS_RE,
                             BB_RE)


## RE ICC ----------------------------------------------------------------------

RE_model <- lmer(Request_explanation ~ (1|intro_id) + (1|coded_by),
                 data = coded_stages_RE)

RE_icc <- ICC_func(RE_model)

RE_boot_icc <- bootMer(RE_model, ICC_func, nsim = 1000)

RE_ci_icc <- boot.ci(RE_boot_icc, index = 1, type = "perc")

# Reinforce truth --------------------------------------------------------------

LN_RT <- LN %>% 
  filter(!is.na(Reinforce_truth)) %>% select(ID,
                                             Interview_nr,
                                             Reinforce_truth) %>% mutate(
                                                   coded_by = "LN",
                                                   intro_id = paste(ID, Interview_nr, sep = "_")
                                                 )

TL_RT <- TL %>% 
  filter(!is.na(Reinforce_truth)) %>% select(ID,
                                             Interview_nr,
                                             Reinforce_truth) %>% mutate(
                                                   coded_by = "TL",
                                                   intro_id = paste(ID, Interview_nr, sep = "_")
                                                 )

EN_RT <- EN %>% 
  filter(!is.na(Reinforce_truth)) %>% select(ID,
                                             Interview_nr,
                                             Reinforce_truth) %>% mutate(
                                                   coded_by = "EN",
                                                   intro_id = paste(ID, Interview_nr, sep = "_")
                                                 )

AK_RT <- AK %>% select(ID,
                       Interview_nr,
                       Reinforce_truth) %>% mutate(
                         coded_by = "AK",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

AT_RT <- AT %>% select(ID,
                       Interview_nr,
                       Reinforce_truth) %>% mutate(
                         coded_by = "AT",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

GS_RT <- GS %>% select(ID,
                       Interview_nr,
                       Reinforce_truth) %>% mutate(
                         coded_by = "GS",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

BB_RT <- BB %>% select(ID,
                       Interview_nr,
                       Reinforce_truth) %>% mutate(
                         coded_by = "BB",
                         intro_id = paste(ID, Interview_nr, sep = "_")
                       )

coded_stages_RT <- bind_rows(LN_RT,
                             TL_RT,
                             EN_RT,
                             AK_RT,
                             AT_RT,
                             GS_RT,
                             BB_RT)


## RT ICC ----------------------------------------------------------------------

RT_model <- lmer(Reinforce_truth ~ (1|intro_id) + (1|coded_by),
                 data = coded_stages_RT)

RT_icc <- ICC_func(RT_model)

RT_boot_icc <- bootMer(RT_model, ICC_func, nsim = 1000)

RT_ci_icc <- boot.ci(RT_boot_icc, index = 1, type = "perc")


# Supportive transitions -------------------------------------------------------

LN_ST <- LN %>% 
  filter(!is.na(`Supportive transistions`)) %>% select(ID,
                                              Interview_nr,
                                              `Supportive transistions`) %>% mutate(
                                                coded_by = "LN",
                                                intro_id = paste(ID,
                                                                 Interview_nr,
                                                                 sep = "_")
                                              )

TL_ST <- TL %>% 
  filter(!is.na(`Supportive transistions`)) %>% select(ID,
                                              Interview_nr,
                                              `Supportive transistions`) %>% mutate(
                                                coded_by = "TL",
                                                intro_id = paste(ID,
                                                                 Interview_nr,
                                                                 sep = "_")
                                              )

EN_ST <- EN %>% 
  filter(!is.na(`Supportive transistions`)) %>% select(ID,
                                              Interview_nr,
                                              `Supportive transistions`) %>% mutate(
                                                coded_by = "EN",
                                                intro_id = paste(ID,
                                                                 Interview_nr,
                                                                 sep = "_")
                                              )


coded_stages_ST <- bind_rows(LN_ST,
                             TL_ST,
                             EN_ST)

## ST ICC ----------------------------------------------------------------------

ST_model <- lmer(`Supportive transistions` ~ (1|intro_id) + (1|coded_by),
                 data = coded_stages_ST)

ST_icc <- ICC_func(ST_model)

ST_boot_icc <- bootMer(ST_model, ICC_func, nsim = 1000)

ST_ci_icc <- boot.ci(ST_boot_icc, index = 1, type = "perc")

# Leading questions ------------------------------------------------------------

LN_LQ <- LN %>% 
  filter(!is.na(Leading_questions)) %>% select(ID,
                                               Interview_nr,
                                               Leading_questions) %>% mutate(
                                                         coded_by = "LN",
                                                         intro_id = paste(ID,
                                                                          Interview_nr,
                                                                          sep = "_")
                                                       )

TL_LQ <- TL %>% 
  filter(!is.na(Leading_questions)) %>% select(ID,
                                               Interview_nr,
                                               Leading_questions) %>% mutate(
                                                         coded_by = "TL",
                                                         intro_id = paste(ID,
                                                                          Interview_nr,
                                                                          sep = "_")
                                                       )

EN_LQ <- EN %>% 
  filter(!is.na(Leading_questions)) %>% select(ID,
                                               Interview_nr,
                                               Leading_questions) %>% mutate(
                                                         coded_by = "EN",
                                                         intro_id = paste(ID,
                                                                          Interview_nr,
                                                                          sep = "_")
                                                       )


coded_stages_LQ <- bind_rows(LN_LQ,
                             TL_LQ,
                             EN_LQ)

## LQ ICC ----------------------------------------------------------------------

LQ_model <- lmer(Leading_questions ~ (1|intro_id) + (1|coded_by),
                 data = coded_stages_LQ)

LQ_icc <- ICC_func(LQ_model)

LQ_boot_icc <- bootMer(LQ_model, ICC_func, nsim = 1000)

LQ_ci_icc <- boot.ci(LQ_boot_icc, index = 1, type = "perc")

