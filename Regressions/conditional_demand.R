#-------------------------------------------------------------------------------
#  Electricity Consumption: The Role of Grid Reliability in Appliance Ownership 
#  and Usage in Rwanda
#  						   	
#  Joel Mugyengi, Gabriel Gonzalez Sutil, Vijay Modi		  	
#  
#-------------------------------------------------------------------------------

# Preliminaries ----------------------------------------------------------------
rstudioapi::writeRStudioPreference("data_viewer_max_columns", 1000L)
rm(list = ls())
pacman::p_load('data.table','dplyr','plyr','haven','readxl','sampleSelection',
               'stargazer','xtable','ggplot2','treemapify','graphics',
               'lmtest','sandwich')
setwd('G:/My Drive/research/rwanda_drive/elec_consumption/')

# Load data ---------------------------------------------------------------
data <- read.csv('data/processed/appliance_consumption_analysis_data_12_05_23_T_13 50.csv')

# Join Data 
aux <- read.csv('data/processed/sample_qsel.csv')
aux <- aux[,c('hhid','province','district','members','hh_male','Children','rural',
              'num_years_in_dwelling','multiple_hh_multi_house',
              'total_savings','major_towns_building_dist')]
data <- merge(data, aux, by = c('hhid'), all.x = T)

# Complete cases
aux <- data[,c('hhid','reg_m_electricity_kWhs')]
data$reg_m_electricity_kWhs <- NULL
data <- data[complete.cases(data),]
data <- merge(data, aux, by = c('hhid'), all.x = T)
data$merge <- 0
data$merge[!is.na(data$reg_m_electricity_kWhs)] <- 1
rm(aux)

# District Dummies
districts <- unique(data$district)
for(i in districts){
  data$aux <- ifelse(data$district == i, 1, 0)
  setnames(data, 'aux', paste0('district_',i))
}

# Province Dummies
provinces <- unique(data$province)
for(i in provinces){
  data$aux <- ifelse(data$province == i, 1, 0)
  setnames(data, 'aux', paste0('province_',i))
}

# Choose variables ----------------------------------------------------------------

# Variables model 1
variables1 <- c('Radio','analogue_phones','smart_phones','TV','music_syst',
                'camera','computer','Sewing_machine','hotplate','cooker',
                'fridge','laundry_mach','Water_Filter','num_rooms')
variables1 <- paste(variables1, collapse = ' + ')

# Variables model 2
variables2 <- c(# Radio:
  'Radio',
  # ANALOGUE PHONES:
  'analogue_phones',
  'outage_freq_2017_analogue_phones_diff',
  "log_monthly_expenses_qsel_analogue_phones_diff",
  # SMART PHONES:
  'smart_phones',
  'outage_freq_2017_smart_phones_diff',
  'log_monthly_expenses_qsel_smart_phones_diff',
  # TV:
  'TV',
  "outage_freq_2017_TV_diff",
  "log_monthly_expenses_qsel_TV_diff",  
  # MUSIC SYSTEM:
  'music_syst',
  # CAMERA:
  'camera',
  # COMPUTER:
  'computer',
  "log_monthly_expenses_qsel_computer_diff",
  # SEWING MACHING:
  'Sewing_machine',
  # HOTPLATE:
  'hotplate',
  "outage_freq_2017_hotplate_diff",
  "log_monthly_expenses_qsel_hotplate_diff" ,
  # COOKER:
  'cooker',
  # FRIDGE:
  'fridge',
  "outage_freq_2017_fridge_diff",
  'log_monthly_expenses_qsel_fridge_diff',
  # LAUNDRY MACHINE:
  'laundry_mach',
  "outage_freq_2017_laundry_mach_diff",
  "log_monthly_expenses_qsel_laundry_mach_diff",
  # WATER FILTER
  'Water_Filter',
  'num_rooms')
variables2 <- paste(variables2, collapse = ' + ')


# Variables model 3
variables3 <- c(# Radio:
                'Radio',
                # ANALOGUE PHONES:
                'analogue_phones',
                'Children_analogue_phones_diff',
                'outage_freq_2017_analogue_phones_diff',
                "log_monthly_expenses_qsel_analogue_phones_diff",
                # SMART PHONES:
                'smart_phones',
                'Children_smart_phones_diff',
                'outage_freq_2017_smart_phones_diff',
                'log_monthly_expenses_qsel_smart_phones_diff',
                # TV:
                'TV',
                "Children_TV_diff",
                'Seniors_TV_diff',
                "outage_freq_2017_TV_diff",
                "log_monthly_expenses_qsel_TV_diff",  
                # MUSIC SYSTEM:
                'music_syst',
                # CAMERA:
                'camera',
                # COMPUTER:
                'computer',
                'members_computer_diff',
                "Children_computer_diff",
                "outage_freq_2017_computer_diff",
                "log_monthly_expenses_qsel_computer_diff",
                # SEWING MACHING:
                'Sewing_machine',
                # HOTPLATE:
                'hotplate',
                'members_hotplate_diff',
                "female_hotplate_diff",
                "outage_freq_2017_hotplate_diff",
                "log_monthly_expenses_qsel_hotplate_diff" ,
                # COOKER:
                'cooker',
                # FRIDGE:
                'fridge',
                "outage_freq_2017_fridge_diff",
                'log_monthly_expenses_qsel_fridge_diff',
                # LAUNDRY MACHINE:
                'laundry_mach',
                "outage_freq_2017_laundry_mach_diff",
                "log_monthly_expenses_qsel_laundry_mach_diff",
                # WATER FILTER
                'Water_Filter',
                'num_rooms')
variables3 <- paste(variables3, collapse = ' + ')

# Regressions ------------------------------------------------------------------

# EICV only appliances
y1 <- as.formula(paste('nisr_m_electricity_kWh ~ ', variables1, sep = ' + '))
mod1 <- lm(y1, data = data)
mod1.r <- coeftest(mod1, vcov=vcovHC(mod1,type="HC0"))

# EICV appliances + income + reliability
y2 <- as.formula(paste('nisr_m_electricity_kWh ~ ', variables2, sep = ' + '))
mod2 <- lm(y2, data = data)
mod2.r <- coeftest(mod2, vcov=vcovHC(mod2,type="HC0"))

# EICV appliances + income + reliability + demographics
y3 <- as.formula(paste('nisr_m_electricity_kWh ~ ', variables3, sep = ' + '))
mod3 <- lm(y3, data = data)
mod3.r <- coeftest(mod3, vcov=vcovHC(mod3,type="HC0"))

stargazer(mod1.r, mod2.r, mod3.r, single.row = TRUE, align=TRUE)
stargazer(mod1, mod2, mod3, mod4)


