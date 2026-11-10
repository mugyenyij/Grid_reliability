#-------------------------------------------------------------------------------
#  Project:				APPLIANCE OWNERSHIP
#  PURPOSE:  			CONSUMPTION ANALYSIS						   	
#  WRITEN BY:  		GABRIEL GONZALEZ SUTIL (gg2718@columbia.edu)		  	
#  Last time modified:  12-07-2023											
#-------------------------------------------------------------------------------

# Preliminaries ----------------------------------------------------------------
rstudioapi::writeRStudioPreference("data_viewer_max_columns", 1000L)
rm(list = ls())
pacman::p_load('data.table','dplyr','plyr','haven','readxl','sampleSelection',
               'stargazer','xtable','ggplot2','treemapify','graphics',
               'lmtest','sandwich')
setwd('G:/My Drive/research/rwanda_drive/elec_consumption/')

# Load data -------------------------------------------------------------------
data <- read.csv('data/processed/appliance_consumption_analysis_data_12_05_23_T_13 50.csv')
data$reg_m_electricity_kWhs <- NULL
aux <- read.csv('data/sample_qsel.csv')

aux <- aux[,c('hhid',"appliances_y","radio_y","phones_y","analogue_y","smart_y",
              "tv_y","dvd_y","satellite_dish_y","decoder_y","music_y","computer_y",
              "printer_y","camera_y","hotplate_y","cooker_y","fridge_y","laundry_y",
              "filter_y","fan_y","sewing_y","log_exp",'saifi','seniors',
              "num_rooms")]

# Income Dummies
data <- merge(data, aux, by = c('hhid'), all.x = T)
data <- data[!is.na(data$log_exp),]

data$low_income <- 1 * (data$log_exp < median(data$log_exp))
data$high_income <- 1 - data$low_income
rm(aux)

# Add group means
aux <- read.csv('data/processed/appliance_consumption_analysis_data_grp_mean_12_06_23_T_13 26.csv')

aux <- aux[,c("laundry_mach","outage_freq_2017_laundry_mach.grp_mean",
             "log_monthly_expenses_qsel_laundry_mach.grp_mean", "TV",
             "outage_freq_2017_TV.grp_mean","Children_TV.grp_mean",
             "Seniors_TV.grp_mean","log_monthly_expenses_qsel_TV.grp_mean",
             "computer","Children_computer.grp_mean","members_computer.grp_mean",
             "outage_freq_2017_computer.grp_mean","log_monthly_expenses_qsel_computer.grp_mean",
             "Mobile_phones","members_Mobile_phones.grp_mean","Seniors_Mobile_phones.grp_mean",
             "outage_duration_2016_Mobile_phones.grp_mean",
             "outage_duration_2017_Mobile_phones.grp_mean",
             "outage_freq_2016_Mobile_phones.grp_mean",
             "outage_freq_2017_Mobile_phones.grp_mean","Children_Mobile_phones.grp_mean",
             "log_monthly_expenses_qsel_Mobile_phones.grp_mean","hotplate",
             "outage_freq_2017_hotplate.grp_mean","female_hotplate.grp_mean",
             "log_monthly_expenses_qsel_hotplate.grp_mean", "members_hotplate.grp_mean",
             "fridge","outage_freq_2017_fridge.grp_mean","log_monthly_expenses_qsel_fridge.grp_mean",
             "smart_phones","outage_freq_2017_smart_phones.grp_mean",
             "Children_smart_phones.grp_mean","log_monthly_expenses_qsel_smart_phones.grp_mean",
             "analogue_phones","outage_freq_2017_analogue_phones.grp_mean",
             "Children_analogue_phones.grp_mean","log_monthly_expenses_qsel_analogue_phones.grp_mean")]

# Analogue Phones
data$outage_mean_analogue <- unique(aux$outage_freq_2017_analogue_phones.grp_mean[aux$analogue_phones == 1 & !is.na(aux$analogue_phones)])
data$income_mean_analogue <- unique(aux$log_monthly_expenses_qsel_analogue_phones.grp_mean[aux$analogue_phones == 1 & !is.na(aux$analogue_phones)])
data$children_analogue <- unique(aux$Children_analogue_phones.grp_mean[aux$analogue_phones == 1 & !is.na(aux$analogue_phones)])

# Smart Phones
data$outage_mean_smart <- unique(aux$outage_freq_2017_smart_phones.grp_mean[aux$smart_phones == 1 & !is.na(aux$smart_phones)])
data$income_mean_smart <- unique(aux$log_monthly_expenses_qsel_smart_phones.grp_mean[aux$smart_phones == 1 & !is.na(aux$smart_phones)])
data$children_smart <- unique(aux$Children_smart_phones.grp_mean[aux$smart_phones == 1 & !is.na(aux$smart_phones)])

# TV
data$outage_mean_tv <- unique(aux$outage_freq_2017_TV.grp_mean[aux$TV == 1 & !is.na(aux$TV)])
data$income_mean_tv <- unique(aux$log_monthly_expenses_qsel_TV.grp_mean[aux$TV == 1 & !is.na(aux$TV)])
data$children_mean_tv <- unique(aux$Children_TV.grp_mean[aux$TV == 1 & !is.na(aux$TV)])
data$senior_mean_tv <- unique(aux$Seniors_TV.grp_mean[aux$TV == 1 & !is.na(aux$TV)])

# Computer
data$outage_mean_computer <- unique(aux$outage_freq_2017_computer.grp_mean[aux$computer == 1 & !is.na(aux$computer)])
data$income_mean_computer <- unique(aux$log_monthly_expenses_qsel_computer.grp_mean[aux$computer == 1 & !is.na(aux$computer)])
data$member_mean_computer <- unique(aux$members_computer.grp_mean[aux$computer == 1 & !is.na(aux$computer)])
data$children_mean_computer <- unique(aux$Children_computer.grp_mean[aux$computer == 1 & !is.na(aux$computer)])

# Hotplate
data$outage_mean_hotplate <- unique(aux$outage_freq_2017_hotplate.grp_mean[aux$hotplate == 1 & !is.na(aux$hotplate)])
data$income_mean_hotplate <- unique(aux$log_monthly_expenses_qsel_hotplate.grp_mean[aux$hotplate == 1 & !is.na(aux$hotplate)])
data$member_mean_hotplate <- unique(aux$members_hotplate.grp_mean[aux$hotplate == 1 & !is.na(aux$hotplate)])
data$females_mean_hotplate <- unique(aux$female_hotplate.grp_mean[aux$hotplate == 1 & !is.na(aux$hotplate)])

# Fridge
data$outage_mean_fridge <- unique(aux$outage_freq_2017_fridge.grp_mean[aux$fridge == 1 & !is.na(aux$fridge)])
data$income_mean_fridge <- unique(aux$log_monthly_expenses_qsel_fridge.grp_mean[aux$fridge == 1 & !is.na(aux$fridge)])

# Laundry Machine
data$outage_mean_laundry <- unique(aux$outage_freq_2017_laundry_mach.grp_mean[aux$laundry_mach == 1 & !is.na(aux$laundry_mach)])
data$income_mean_laundry <- unique(aux$log_monthly_expenses_qsel_laundry_mach.grp_mean[aux$laundry_mach == 1 & !is.na(aux$laundry_mach)])

# Adjust Data
data$num_rooms.x <- NULL
setnames(data,'num_rooms.y','num_rooms')

# Baseline Consumption ---------------------------------------------------------

data$consumption_communication <- 1 * (data$radio_y == 1) * 0 * data$Radio + 
  1 * (data$analogue_y == 1) * (0.595 * data$analogue_phones 
                                - 0.003 * data$outage_freq_2017_analogue_phones_diff 
                                + 0.792 * data$ log_monthly_expenses_qsel_analogue_phones_diff) + 
  1 * (data$smart_y == 1) * (2.148 * data$smart_phones 
                             - 0.004 * data$outage_freq_2017_smart_phones_diff 
                             + 1.390 * data$ log_monthly_expenses_qsel_smart_phones_diff)
data$consumption_communication[data$consumption_communication < 0] <- 0


data$consumption_entertaintment <- 1 * (data$tv_y == 1) * (5.209 * data$TV 
                                                           + 2.144 * data$log_monthly_expenses_qsel_TV_diff 
                                                           + 4.005 * data$Seniors_TV_diff) + 
  1 * (data$music_y == 1) * 0 * data$music_syst + 
  1 * (data$camera_y == 1) * 0 * data$camera
data$consumption_entertaintment[data$consumption_entertaintment < 0] <- 0

data$consumption_productivity <- 1 * (data$computer_y == 1) * (0 * data$computer 
                                                               + 0.014 * data$outage_freq_2017_computer_diff) + 
  1 * (data$sewing_y == 1) * 0 * data$Sewing_machine
data$consumption_productivity[data$consumption_productivity < 0] <- 0

data$consumption_convenience <- 1 * (data$hotplate_y == 1) * 
  (15.601 * data$hotplate + 29.402 * data$log_monthly_expenses_qsel_hotplate_diff) + 
  1 * (data$cooker_y == 1) * 0 * data$cooker + 
  1 * (data$fridge_y == 1) * (19.585 * data$fridge + 11.079 * data$log_monthly_expenses_qsel_fridge_diff) +
  1 * (data$laundry_y == 1) * (36.675 * data$laundry_mach + 43.082 * data$log_monthly_expenses_qsel_laundry_mach_diff)
data$consumption_convenience[data$consumption_convenience < 0] <- 0

data$consumption_other <- 4.363 + 0.713 * data$num_rooms

data$consumption_total <- data$consumption_communication + data$consumption_convenience +
  data$consumption_entertaintment + data$consumption_productivity + 
  data$consumption_other

data <- data[!is.na(data$consumption_total),]

#  Ownership Matrix ------------------------------------------------------------

# Select Scenario
scenario_low <- c(1,0,1)
scenario_high <- c(1,1,0)


for(j in 1:3){
  adjust_reliability_low <- scenario_low[j]
  adjust_reliability_high <- scenario_high[j]
  
  simulations <- data.frame(matrix(0,10000,6))
  
  for(i in 1:10000){
  
    # Analogue Phones
    data$outage_freq_2017_analogue_phones_diff_adj[data$low_income == 1] <- data$outage_freq_2017_analogue_phones_diff[data$low_income == 1] - adjust_reliability_low 
    data$outage_freq_2017_analogue_phones_diff_adj[data$low_income == 0] <- data$outage_freq_2017_analogue_phones_diff[data$low_income == 0] - adjust_reliability_high 
    
    # Smart Phone
    data$smart_y_adj <- data$smart_y
    data$smart_adj <- data$smart_phones
    
    smart_pool_low <- data$hhid[data$smart_y == 0 & data$low_income == 1]
    smart_pool_high <- data$hhid[data$smart_y == 0 & data$high_income == 1]
    
    smart_low <- (6.5/100) * adjust_reliability_low
    smart_high <- (6.4/100) * adjust_reliability_high
    
    hhid_low <- sample(smart_pool_low, smart_low * length(data$hhid[data$low_income == 1]))
    hhid_high <- sample(smart_pool_high, smart_high * length(data$hhid[data$high_income == 1]))
    
    data$smart_y_adj[data$hhid %in% data$hhid %in% hhid_low |
                       data$hhid %in% hhid_high] <- 1
    data$smart_adj[data$hhid %in% data$hhid %in% hhid_low |
                     data$hhid %in% hhid_high] <- 1

    data$outage_freq_2017_smart_phones_diff[data$hhid %in% hhid_low |
                                              data$hhid %in% hhid_high] <- data$saifi[data$hhid %in% hhid_low |
                                                                                        data$hhid %in% hhid_high] - data$outage_mean_smart[data$hhid %in% hhid_low |
                                                                                                                                          data$hhid %in% hhid_high]
    data$log_monthly_expenses_qsel_smart_phones_diff[data$hhid %in% hhid_low |
                                                       data$hhid %in% hhid_high] <- data$log_exp[data$hhid %in% hhid_low |
                                                                                                   data$hhid %in% hhid_high] - data$income_mean_smart[data$hhid %in% hhid_low |
                                                                                                                                                     data$hhid %in% hhid_high]
    data$outage_freq_2017_smart_phones_diff_adj[data$low_income == 1] <- data$outage_freq_2017_smart_phones_diff[data$low_income == 1] - adjust_reliability_low
    data$outage_freq_2017_smart_phones_diff_adj[data$low_income == 0] <- data$outage_freq_2017_smart_phones_diff[data$low_income == 0] - adjust_reliability_high
    
    # Computer
    data$outage_freq_2017_computer_diff_adj[data$low_income == 1] <- data$outage_freq_2017_computer_diff[data$low_income == 1] -  adjust_reliability_low
    data$outage_freq_2017_computer_diff_adj[data$low_income == 0] <- data$outage_freq_2017_computer_diff[data$low_income == 0] -  adjust_reliability_high
    
    # TV Low Income
    data$tv_y_adj <- data$tv_y
    data$tv_adj <- data$TV
    
    tv_pool_low <- data$hhid[data$tv_y == 0 & data$low_income == 1]
    
    tv_low <- (6.4/100) * adjust_reliability_low
    
    hhid_low <- sample(tv_pool_low, tv_low * length(data$hhid[data$low_income == 1]))
    
    data$tv_y_adj[data$hhid %in% hhid_low] <- 1
    data$tv_adj[data$hhid %in% hhid_low] <- 1
    
    data$log_monthly_expenses_qsel_TV_diff[data$hhid %in% hhid_low] <- data$log_exp[data$hhid %in% hhid_low] - data$income_mean_tv[data$hhid %in% hhid_low]
    data$Seniors_TV_diff[data$hhid %in% hhid_low] <- data$seniors[data$hhid %in% hhid_low] - data$senior_mean_tv[data$hhid %in% hhid_low]

    
    # Decoder Low Income
    data$decoder_y_adj <- data$decoder_y
    data$decoder_adj <- data$decoder
    
    decoder_pool_low <- data$hhid[data$decoder_y == 0 & data$low_income == 1]
    
    decoder_low <- (5.4/100) * adjust_reliability_low 
    
    hhid_low <- sample(decoder_pool_low, decoder_low * length(data$hhid[data$low_income == 1]))
    
    data$decoder_y_adj[data$hhid %in% hhid_low] <- 1
    data$decoder_adj[data$hhid %in% hhid_low] <- 1
    
    # Fridge High Income
    data$fridge_y_adj <- data$fridge_y
    data$fridge_adj <- data$fridge
    
    fridge_pool_high <- data$hhid[data$fridge_y == 0 & data$high_income == 1]
    
    fridge_high <- (6.9/100) * adjust_reliability_high
    
    hhid_high <- sample(fridge_pool_high, fridge_high * length(data$hhid[data$high_income == 1]))
    
    data$fridge_y_adj[data$hhid %in% hhid_high] <- 1
    data$fridge_adj[data$hhid %in% hhid_high] <- 1
    
    data$log_monthly_expenses_qsel_fridge_diff[data$hhid %in% hhid_low] <- data$log_exp[data$hhid %in% hhid_low] - data$income_mean_fridge[data$hhid %in% hhid_low]

    # Cooker High Income
    data$cooker_y_adj <- data$cooker_y
    data$cooker_adj <- data$cooker
    
    cooker_pool_high <- data$hhid[data$cooker_y == 0 & data$high_income == 1]
    
    cooker_high <- (6.9/100) * adjust_reliability_high
    
    hhid_high <- sample(cooker_pool_high, cooker_high * length(data$hhid[data$high_income == 1]))
    
    data$cooker_y_adj[data$hhid %in% hhid_high] <- 1
    data$cooker_adj[data$hhid %in% hhid_high] <- 1
    
    # Simulated Consumption
    
    data$simulated_communication <- 1 * (data$radio_y == 1) * 0 * data$Radio + 
      1 * (data$analogue_y == 1) * (0.595 * data$analogue_phones 
                                    - 0.003 * data$outage_freq_2017_analogue_phones_diff_adj
                                    + 0.792 * data$log_monthly_expenses_qsel_analogue_phones_diff) + 
      1 * (data$smart_y_adj == 1) * (2.148 * data$smart_adj 
                                     - 0.004 * data$outage_freq_2017_smart_phones_diff_adj 
                                     + 1.390 * data$log_monthly_expenses_qsel_smart_phones_diff)
    data$simulated_communication[data$simulated_communication < 0 | 
                                   is.na(data$simulated_communication)] <- 0
    
    data$simulated_entertaintment <- 1 * (data$tv_y_adj == 1) * (5.209 * data$tv_adj 
                                                                 + 2.144 * data$log_monthly_expenses_qsel_TV_diff 
                                                                 + 4.005 * data$Seniors_TV_diff) + 
      1 * (data$music_y == 1) * 0 * data$music_syst + 
      1 * (data$camera_y == 1) * 0 * data$camera
    data$simulated_entertaintment[data$simulated_entertaintment < 0 | 
                                    is.na(data$simulated_entertaintment)] <- 0
    
    data$simulated_productivity <- 1 * (data$computer_y == 1) * (0 * data$computer 
                                                                 + 0.014 * data$outage_freq_2017_computer_diff) + 
      1 * (data$sewing_y == 1) * 0 * data$Sewing_machine
    data$simulated_productivity[data$simulated_productivity < 0 | 
                                  is.na(data$simulated_productivity)] <- 0
    
    
    data$simulated_convenience <- 1 * (data$hotplate_y == 1) * 
      (15.601 * data$hotplate + 29.402 * data$log_monthly_expenses_qsel_hotplate_diff) + 
      1 * (data$cooker_y_adj == 1) * 0 * data$cooker_adj + 
      1 * (data$fridge_y_adj == 1) * (19.585 * data$fridge_adj + 11.079 * data$log_monthly_expenses_qsel_fridge_diff) +
      1 * (data$laundry_y == 1) * (36.675 * data$laundry_mach + 43.082 * data$log_monthly_expenses_qsel_laundry_mach_diff)
    data$simulated_convenience[data$simulated_convenience < 0 | 
                                 is.na(data$simulated_convenience)] <- 0
    
    data$simulated_other <- 4.363 + 0.713 * data$num_rooms
    
    data$simulated_total <- data$simulated_communication + data$simulated_convenience +
      data$simulated_entertaintment + data$simulated_productivity + data$simulated_other
    
    simulations[i,1] <- sum(data$simulated_communication)
    simulations[i,2] <- sum(data$simulated_entertaintment)
    simulations[i,3] <- sum(data$simulated_productivity)
    simulations[i,4] <- sum(data$simulated_convenience)
    simulations[i,5] <- sum(data$simulated_other)
    simulations[i,6] <- sum(data$simulated_total)
  }
  
  assign(paste0('simulations_',j), simulations)
  rm(simulations)
}



# Described ---------------------------------------------------------------------

aux <- data.table('Sector' = c('Communication','Entertainment','Productivity',
                               'Covenience','Other','Total'),
                  'Predicted' = c(sum(data$consumption_communication), 
                                  sum(data$consumption_entertaintment),
                                  sum(data$consumption_productivity),
                                  sum(data$consumption_convenience),
                                  sum(data$consumption_other),
                                  sum(data$consumption_total)),
                  'Lower1' = c(quantile(simulations_1$X1, 0.025),
                              quantile(simulations_1$X2, 0.025),
                              quantile(simulations_1$X3, 0.025),
                              quantile(simulations_1$X4, 0.025),
                              quantile(simulations_1$X5, 0.025),
                              quantile(simulations_1$X6, 0.025)),
                  'Expected1' = c(mean(simulations_1$X1), mean(simulations_1$X2),
                                 mean(simulations_1$X3), mean(simulations_1$X4),
                                 mean(simulations_1$X5), mean(simulations_1$X6)),
                  'Upper1' = c(quantile(simulations_1$X1, 0.975),
                               quantile(simulations_1$X2, 0.975),
                               quantile(simulations_1$X3, 0.975),
                               quantile(simulations_1$X4, 0.975),
                               quantile(simulations_1$X5, 0.975),
                               quantile(simulations_1$X6, 0.975)),
                  'Lower2' = c(quantile(simulations_2$X1, 0.025),
                               quantile(simulations_2$X2, 0.025),
                               quantile(simulations_2$X3, 0.025),
                               quantile(simulations_2$X4, 0.025),
                               quantile(simulations_2$X5, 0.025),
                               quantile(simulations_1$X6, 0.975)),
                  'Expected2' = c(mean(simulations_2$X1), mean(simulations_2$X2),
                                  mean(simulations_2$X3), mean(simulations_2$X4),
                                  mean(simulations_2$X5), mean(simulations_2$X6)),
                  'Upper2' = c(quantile(simulations_2$X1, 0.975),
                               quantile(simulations_2$X2, 0.975),
                               quantile(simulations_2$X3, 0.975),
                               quantile(simulations_2$X4, 0.975),
                               quantile(simulations_2$X5, 0.975),
                               quantile(simulations_2$X6, 0.975)),
                  'Lower3' = c(quantile(simulations_3$X1, 0.025),
                               quantile(simulations_3$X2, 0.025),
                               quantile(simulations_3$X3, 0.025),
                               quantile(simulations_3$X4, 0.025),
                               quantile(simulations_3$X5, 0.025),
                               quantile(simulations_3$X6, 0.025)),
                  'Expected3' = c(mean(simulations_3$X1), mean(simulations_3$X2),
                                  mean(simulations_3$X3), mean(simulations_3$X4),
                                  mean(simulations_3$X5), mean(simulations_3$X6)),
                  'Upper3' = c(quantile(simulations_3$X1, 0.975),
                               quantile(simulations_3$X2, 0.975),
                               quantile(simulations_3$X3, 0.975),
                               quantile(simulations_3$X4, 0.975),
                               quantile(simulations_3$X5, 0.975),
                               quantile(simulations_3$X6, 0.975)))


# Plots ----------------------------------------------------------------------


png("imgs/sim_1.png")
hist((simulations_1$per -  mean(data$consumption_total))/mean(data$consumption_total)*100, breaks=25, col = 'lightblue',
     xlab = 'Consumption Change (%)', ylab = 'Count',main = "", ylim = c(0,2100))
     abline(v = mean((simulations_1$per -  mean(data$consumption_total))/mean(data$consumption_total)*100), col = "red", lty = "dashed",lwd = 5)
     text(x = mean((simulations_1$per -  mean(data$consumption_total))/mean(data$consumption_total)*100) + 0.065, 
          y = 2000, paste0('Average Change:', 
                           round(mean((simulations_1$per -  mean(data$consumption_total))/mean(data$consumption_total)*100),2), '%'))
     text(x = 5.45,y = 2000, 
          paste0('Baseline:', round(mean(data$consumption_total),2), ' kWh/mth/hh'))
dev.off()

png("imgs/sim_2.png")
hist((simulations_2$per -  mean(data$consumption_total))/mean(data$consumption_total)*100, breaks=25, col = 'lightblue',
          xlab = 'Consumption Change (%)', ylab = 'Count',main = "", ylim = c(0,2100))
     abline(v = mean((simulations_2$per -  mean(data$consumption_total))/mean(data$consumption_total)*100), col = "red", lty = "dashed",lwd = 5)
     text(x = mean((simulations_2$per -  mean(data$consumption_total))/mean(data$consumption_total)*100) + 0.04, 
          y = 2000, paste0('Average Change:', 
                           round(mean((simulations_2$per -  mean(data$consumption_total))/mean(data$consumption_total)*100),2), '%'))
     text(x = 5.02,y = 2000, 
          paste0('Baseline:', round(mean(data$consumption_total),2), ' kWh/mth/hh'))
dev.off()
     
png("imgs/sim_3.png")
hist((simulations_3$per -  mean(data$consumption_total))/mean(data$consumption_total)*100, breaks=25, col = 'lightblue',
          xlab = 'Consumption Change (%)', ylab = 'Count',main = "", ylim = c(0,2100))
     abline(v = mean((simulations_3$per -  mean(data$consumption_total))/mean(data$consumption_total)*100), col = "red", lty = "dashed",lwd = 5)
     text(x = mean((simulations_3$per -  mean(data$consumption_total))/mean(data$consumption_total)*100) + 0.05, 
          y = 2000, paste0('Average Change:', 
                           round(mean((simulations_3$per -  mean(data$consumption_total))/mean(data$consumption_total)*100),2), '%'))
     text(x = 0.25,y = 2000, 
          paste0('Baseline:', round(mean(data$consumption_total),2), ' kWh/mth/hh'))
dev.off()