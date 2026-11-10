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
pacman::p_load('data.table','dplyr','plyr','haven','readxl',
               'stargazer','xtable','ggplot2','treemapify','graphics')
setwd('G:/My Drive/research/rwanda_drive/elec_consumption/')

# Load data
data <- read.csv('data/processed/sample_qsel_11_30_23.csv')
data <- data[data$grid == 1,]

# Define district and province ids

hh <- c('hhid','cluster','district','province')

# Appliances and Electricity ---------------------------------------------------

# Drop missing appliances
data <- data[!is.na(data$TV),]

# Number of appliances
setnames(data, c('Radio','Mobile_phones','smart_phones','TV','dvd_player',
                 'Water_Filter','Sewing_machine','laundry_mach','electric_fan',
                 'music_syst'),
         c('radio','phones','smart','tv','dvd','filter','sewing','laundry',
           'fan','music'))

data$camera <- data$still_camera + data$video_camera
data$analogue <- data$phones - data$smart_phones 

data$appliances <- data$radio + data$phones + data$tv + data$decoder +
  data$satellite_dish + data$cooker + data$fridge + data$dvd + data$music + 
  data$computer + data$printer + data$camera + data$hotplate + data$fan + 
  data$laundry + data$filter + data$sewing

appliance_number <- c('appliances','radio','phones','analogue','smart',
                      'tv','dvd','satellite_dish','decoder','music',
                      'computer','printer','camera','still_camera','video_camera',
                      'hotplate','cooker','fridge','laundry','filter',
                      'fan','sewing','power_stabilizer')

# Presence of Key Appliances
setnames(data, c('Radio_present','Mobile_phones_present','TV_present',
                 'dvd_player_present','smart_phones_present',
                 'satellite_dish_present','decoder_present','music_syst_present',
                 'computer_present','printer_present',
                 'still_camera_present','video_camera_present','hotplate_present',
                 'cooker_present','fridge_present','laundry_mach_present',
                 'electric_fan_present'),
         c('radio_y','phones_y','tv_y','dvd_y','smart_y','satellite_dish_y',
           'decoder_y','music_y','computer_y','printer_y','still_camera_y',
           'video_camera_y','hotplate_y','cooker_y','fridge_y','laundry_y',
           'fan_y'))

data$appliances_y <- 1*(data$appliances > 0)
data$camera_y <- 1*(data$camera > 0)
data$analogue_y <- 1*(data$analogue > 0)
data$sewing_y <- 1*(data$sewing > 0)
data$filter_y <- 1*(data$filter > 0)
data$power_stabilizer_y <- 1*(data$power_stabilizer > 0)

appliance_present  <- c('appliances_y','radio_y','phones_y','analogue_y',
       'smart_y','tv_y','dvd_y','satellite_dish_y','decoder_y','music_y',
       'computer_y','printer_y','camera_y','still_camera_y','video_camera_y',
       'hotplate_y','cooker_y','fridge_y','laundry_y','filter_y','fan_y',
       'sewing_y','power_stabilizer_y')

# Electricity KWH
data$kwh <- NA
for(i in 1:nrow(data)){
  if(!is.na(data$m_electricity_payment[i])){
  if(data$m_electricity_payment[i] >= 7705){
    data$kwh[i] <- (data$m_electricity_payment[i] - 7705)/189 + 50
  }
  if(data$m_electricity_payment[i] < 7705 & data$m_electricity_payment[i] >= 1335){
    data$kwh[i] <- (data$m_electricity_payment[i] - 1335)/182 + 15
  } 
  if(data$m_electricity_payment[i] < 1335 & data$m_electricity_payment[i] >= 0){
    data$kwh[i] <- data$m_electricity_payment[i]/89
  }
  }
}

electricity <- c('kwh','m_electricity_payment')

# Appliance categories 
setnames(data, 'tier_level_numeric','tier_numeric')

data$no_appliance <- 1 * (data$appliances == 0)

data$cat_1 <- data$radio + data$phones 
data$cat_1_y <- 1 * (data$cat_1 > 0) 

data$cat_2 <- data$tv + data$decoder + data$satellite_dish + data$camera +
  data$dvd + data$music 
data$cat_2_y <- 1 * (data$cat_2 > 0) 

data$cat_3 <- data$computer + data$printer+ data$sewing
data$cat_3_y <- 1 * (data$cat_3 > 0) 

data$cat_4 <- data$cooker + data$fridge +  data$hotplate + data$fan + 
  data$laundry + data$filter 
data$cat_4_y <- 1 * (data$cat_4 > 0) 

tiers <- c('tier_numeric','tier_0','tier_1','tier_2','tier_3','tier_4',
           'no_appliance','cat_1', 'cat_1_y', 'cat_2', 'cat_2_y', 'cat_3', 
           'cat_3_y', 'cat_4', 'cat_4_y')

# Store Name
y <- c(appliance_number, appliance_present, tiers, electricity)

# Service Quality ------------------------------------------------------------

# Redefine Names
setnames(data,c('eicv_overall_electricity_availability', 'eicv_evening_electricity_availability',
                'eicv_death_due_electricity','eicv_outage_frequency','eicv_outage_duration',
                'outage_duration_2016','outage_duration_2017','outage_duration_2018',
                'outage_duration_2019','outage_duration_2020','outage_freq_2016',
                'outage_freq_2017','outage_freq_2018','outage_freq_2019',
                'outage_freq_2020'),
         c('availability','evening','death','out_freq','out_duration',
           'saidi_year_2016','saidi_year_2017','saidi_year_2018','saidi_year_2019',
           'saidi_year_2020','saifi_year_2016','saifi_year_2017','saifi_year_2018',
           'saifi_year_2019','saifi_year_2020'))

# Create new variables
data$saifi <- ((data$saifi_year_2016 + data$saifi_year_2017)/2) / 365
data$caidi <- ((data$saidi_year_2016 + data$saidi_year_2017)/
                 (data$saifi_year_2016 + data$saifi_year_2017)) 
data$caidi[data$saifi == 0 & !is.na(data$saifi)] <- 0
data$caidi <- data$caidi * 60
data$saidi <- (data$saidi_year_2016 + data$saidi_year_2017)/2

# Select variables
reliability <- c('saidi','saifi','caidi')

# Income -----------------------------------------------------------------------

setnames(data, c('log_monthly_expenses_qsel','received_income_from_business',
                 'non_permanent_net_salary','Yes_VUP',
                 'yes_small_crops','yes_large_crops',
                 'HH_receives_wage','yes_agric_activity'),
         c('log_exp','business','non_perm_wage','VUP','small_crops',
           'large_crops','wage','agriculture'))

data$total_savings <- data$total_savings / 1000000

data$transfer <- 1 * (data$yes_cash_transfers == 1 & data$yes_food_transfers == 1 &
                        data$VUP == 1)

data$job_instability <- data$job_stability

income <-  c('log_exp','total_savings','business','job_instability')

# Demographics -----------------------------------------------------------------

setnames(data, c('member_count_minus_servants','Children','youth_HoH','Seniors'),
         c('member_net','children','hh_youth','seniors'))

demographics <-  c('female', 'children','seniors','hh_female','hh_youth','hh_rwandese')

# Education --------------------------------------------------------------------

setnames(data, c('hh_higher_School','hh_lower_School',
                 'others_higher_School','others_lower_School',
                 'medium_skill_occupations','high_occupations'), 
         c('hh_higher_ed','hh_lower_ed','ot_higher_ed','ot_lower_ed',
           'medium_skill','high_skill'))

data$hh_higher[data$hh_higher_ed == 1 | data$hh_voc_School == 1] <- 1
data$others_higher[data$ot_higher_ed == 1 | data$others_voc_School == 1] <- 1

data$higher_ed <- data$hh_higher + data$others_higher
data$lower_ed <- data$hh_lower_ed + data$ot_lower_ed

data$hh_ed <- 0
data$hh_ed[data$hh_higher_ed == 1 | data$hh_lower_ed == 1] <- 1

human_capital <- c('hh_ed','high_skill')

# Dwelling ---------------------------------------------------------------------

data$multi_house <- 1 * (data$multiple_hh_multi_house == 1 | 
                           data$single_hh_multi_house == 1)
data$multi_hhs <- 1 * (data$multiple_hh_multi_house == 1 | 
                           data$multiple_hh_single_house == 1)

dwelling <- c('num_rooms','multi_house', 'multi_hhs','num_years_in_dwelling',
              'owner','rural')

# Market Access ----------------------------------------------------------------

data$national_road <- apply(data[,c('national_paved_road_building_dist',
                                    'national_paved_road_building_dist')], 1, FUN = min)

setnames(data, c('dist_2_food_market_or_shop','trade_building_dist',
                 'major_towns_building_dist'),
         c('local_center','trade_center','major_town'))

data$log_town <- log(data$major_town)
data$log_trade <- log(data$trade_center)
data$log_local <- log(data$local_center)
data$log_nation <- log(data$national_road)

distance <-  c('log_town','major_town','log_trade','trade_center')

# Weather ----------------------------------------------------------------------

setnames(data, c('krig_mean_rainfall','IV_exceedance_days'),
         c('rainfall_mean','rainfall_extremes'))

data$rainfall_extremes <- data$rainfall_extremes/44

weather <-  c('rainfall_mean')

# Lightning --------------------------------------------------------------------

setnames(data, c('IV_feeder_lightning_means','IV_feeder_lightning_counts',
                 'IV_feeder_lightning_maximums'), 
         c('lightning_radiance','lightning_number','lightning_max'))
         
data$lightning_number <- data$lightning_number / 3
data$lightning_radiance <- data$lightning_radiance/1000000
data$lightning_max <- data$lightning_max/1000000

lightning <- c('lightning_radiance','lightning_number')

# Sample ----------------------------------------------------------------------

# Define Control Variables
x <- c(reliability, income, demographics,human_capital, dwelling, distance, weather)
sample <- data[,c(hh, y, x, lightning)] 

