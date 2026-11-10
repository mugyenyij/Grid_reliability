# Function ---------------------------------------------------------------

erase_label <- function(data, var){
  # data - eicv data
  # var  -  column names
  for(i in var) attr(data[,c(i)], "label") <- NULL # Cluster erase label
  return(data)
} 


variable <- function(raw, file, condition = NULL, name){
  file[,c(name)] <- NULL
  if(is.null(condition)){
    aux <- raw[,c('hhid','cluster','province','district')] %>% 
      group_by(hhid, cluster, province, district) %>% tally()    
  }else{
    aux <- raw[condition,c('hhid','cluster','province','district')] %>% 
      group_by(hhid, cluster, province, district) %>% tally()    
  }
  setnames(aux, 'n', name)
  file <- merge(file, aux, by = c('hhid','cluster','province','district'), all.x = T)
  if(!is.null(condition)){
    file[is.na(file[,c(name)]),c(name)] <- 0   
  }
  rm(aux)
  return(file)
}

clean_demographics <- function(eicv5){
    aux <- eicv5 %>% select('hhid','clust','province','district','ur',starts_with("s1"),starts_with("s4"),'s0q18y','s0q18m')
    rm(eicv5)
    section1 <- unique(aux[,c('hhid','clust','province','district','s0q18y','s0q18m','ur')])

    # Year and Month
    setnames(section1, c('s0q18y','s0q18m','clust','ur'), c('interview_year','interview_month','cluster','urban_rural'))
    setnames(aux, c('clust'), c('cluster'))

    # Erase Labels
    section1 <- as.data.frame(section1)
    variables <- c('hhid', 'cluster','province','district','interview_year','interview_month','urban_rural')
    section1 <- erase_label(section1, variables)  

    # Demographic Variables -------------------------------------------------------------

    # Number of members in the household
    section1 <- variable(aux, section1, condition = NULL, 'people')
    section1 <- variable(aux, section1, condition = (aux$s1q16 == 1), 'members')

    # Number of members in the household by gender
    section1 <- variable(aux, section1, condition = (aux$s1q1 == 1), 'male')
    section1 <- variable(aux, section1, condition = (aux$s1q1 == 2), 'female')
    section1 <- variable(aux, section1, condition = (aux$s1q2 == 1 & aux$s1q1 == 1), 'hh_male')
    section1 <- variable(aux, section1, condition = (aux$s1q2 == 1 & aux$s1q1 == 2), 'hh_female')

    # Number of members in the household by education
    section1 <- variable(aux, section1, condition = (aux$s1q2 != 1 & aux$s4aq1 == 1 & aux$s4aq5 == 7 & aux$s4bq1 == 3), 'others_lower_School')
    section1 <- variable(aux, section1, condition = (aux$s1q2 == 1 & aux$s4aq1 == 1 & aux$s4aq5 == 7 & aux$s4bq1 == 3), 'hh_lower_School')
    section1 <- variable(aux, section1, condition = (aux$s1q2 != 1 & aux$s4aq1 == 1 & aux$s4aq5 != 7 & aux$s4bq1 == 3), 'others_higher_School')
    section1 <- variable(aux, section1, condition = (aux$s1q2 == 1 & aux$s4aq1 == 1 & aux$s4aq5 != 7 & aux$s4bq1 == 3), 'hh_higher_School')
    section1 <- variable(aux, section1, condition = (aux$s1q2 != 1 & aux$s4aq1 == 1 & aux$s4aq5 == 7 & aux$s4bq1 != 3), 'others_voc_School')
    section1 <- variable(aux, section1, condition = (aux$s1q2 == 1 & aux$s4aq1 == 1 & aux$s4aq5 == 7 & aux$s4bq1 != 3), 'hh_voc_School')

    # Number of members in the household by age range
    section1 <- variable(aux, section1, condition = (aux$s1q3y <= 16), 'Children')
    section1 <- variable(aux, section1, condition = (aux$s1q3y > 16 & aux$s1q3y <= 60), 'Working_age')
    section1 <- variable(aux, section1, condition = (aux$s1q3y > 60), 'Seniors')

   
    section1 <- variable(aux, section1, condition = (aux$s1q2 == 1 & (aux$s1q3y <= 35)), 'HoH_below_35') # youth_HoH
    section1 <- variable(aux, section1, condition = (aux$s1q2 == 1 & aux$s1q3y > 35), 'HoH_above_35') # senoir_HoH

    # Head of Household Culture
    section1$hh_born <- aux$s1q6[aux$s1q2 == 1]
    section1$hh_rwandese <- 1 * (section1$hh_born == 60)
    section1$hh_burundian <- 1 * (section1$hh_born == 61)
    section1$hh_congolese <- 1 * (section1$hh_born == 62)
    section1$hh_ugandan <- 1 * (section1$hh_born == 63)
    section1$hh_tanzanian <- 1 * (section1$hh_born == 64)
    section1$hh_kenyan <- 1 * (section1$hh_born == 65)
    section1$hh_african <- 1 * (section1$hh_born == 66)
    section1$hh_foreign <- 1 * (section1$hh_born == 67)
    section1$hh_born <- NULL

    section1$hh_district <- as.numeric(aux$s1q5[aux$s1q2 == 1])
    section1$hh_district[section1$hh_rwandese == 0] <- 0

    # Effective people in the house
    aux$s1q8[aux$s1q7 == 2] <- 0
    aux$s1q7[aux$s1q7 == 2] <- 0
    aux$absent <- aux$s1q8 * aux$s1q7
    section1 <- variable(aux, section1, condition = (aux$absent > 0), 'absent')
    section1$effective <- round(((section1$members * 12) - section1$absent)/12,2)
    section1$absent <- NULL

    # Order and save
    section1 <- section1 %>% select('hhid', 'interview_month', 'interview_year', 'cluster','province',
                                    'district', 'urban_rural',everything())
    demographics <- section1
    return(demographics)
} 


# Expenditure variables ---------------------------------------------------------------------------

annual_expenditure <- function(expenditure, data, new_var, init, fin){
  # expenditure - unique combination of 'hhid','clust', 'province','district'
  # data  -  eicv5 expenditure dataframe, annual columns 
  # new_var - new variable name
  # init, fin - article codes
  aux <- as.data.frame(data[data$s8a1q0 >= init &  data$s8a1q0 <= fin,]) # s8a1q0- Article
  
  # Calculate total annual household expenditure on "ARTICLE i.e colthing, belongs etc"
  aux <- aux %>%
    group_by(hhid, clust, province, district) %>% 
    dplyr::summarise(new_var = sum(s8a1q3)) 
  setnames(aux, 'new_var', new_var)
  expenditure <- merge(expenditure, aux, 
                       by = c('hhid','clust','province','district'), all.x = T)
  return(expenditure)
} 

month_expenditure <- function(expenditure, data, new_var, init, fin){
  # expenditure - unique combination of 'hhid','clust', 'province','district'
  # data  -  eicv5 expenditure dataframe, annual columns 
  # new_var - new variable name
  # init, fin - article codes
  aux <- as.data.frame(data[data$s8a2q0 >= init &  data$s8a2q0 <= fin,])
  aux <- aux %>%
    group_by(hhid, clust, province, district) %>% 
    dplyr::summarise(new_var = sum(s8a2q3)) 
  setnames(aux, 'new_var', new_var)
  expenditure <- merge(expenditure, aux, 
                       by = c('hhid','clust','province','district'), all.x = T)
  return(expenditure)
} 

freq_expenditure <- function(expenditure, data, new_var, init, fin){
  # expenditure - unique combination of 'hhid','clust', 'province','district'
  # data  -  eicv5 expenditure dataframe, annual columns 
  # new_var - new variable name
  # init, fin - article codes
  aux <- as.data.frame(data[data$s8a3q0 >= init &  data$s8a3q0 <= fin,]) # s8a3q0 - 
  aux <- aux %>%
    group_by(hhid, clust, province, district) %>% 
    dplyr::summarise(new_var = sum(annual_exp)) 
  setnames(aux, 'new_var', new_var)
  expenditure <- merge(expenditure, aux, 
                       by = c('hhid','clust','province','district'), all.x = T)
  return(expenditure)
} 

clean_expenditure <- function(exp){
    annual_exp <- unique(as.data.frame(exp[,c('hhid','clust', 'province','district')])) 
    exp$s8a1q3[is.na(exp$s8a1q3)] <- 0 #set NULL values to zero.  s8a1q3- "Amount spent to purchase article"

    # Expenditure
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_clothing',1,17)
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_belongings',18,28)
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_housing',29,30)
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_furnishings',31,53)
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_appliances_subset_of_a_furnishings',45,49)
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_transport',54,57)
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_leisure',58,61)
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_health',62,67)
    annual_exp <- annual_expenditure(annual_exp, exp, 'a_other',68,69)

    setnames(annual_exp, c('clust'), c('cluster'))
    variables <- c('hhid','cluster','province','district')
    annual_exp <- erase_label(annual_exp, variables)

    # Month expenditure -------------------------------------------------
    exp <- read_sav('eicv5/cs_S8A2_expenditure.sav')
    month_exp <- unique(as.data.frame(exp[,c('hhid','clust', 'province','district')])) 
    exp$s8a2q3[is.na(exp$s8a2q3)] <- 0 # set NULL values to zero. s8a2q3- "Amount spent to purchase article"

    # Expenditure
    month_exp <- month_expenditure(month_exp, exp, 'm_housing',1,9)
    month_exp <- month_expenditure(month_exp, exp, 'm_transport',10,13)
    month_exp <- month_expenditure(month_exp, exp, 'm_leisure',14,24)
    month_exp <- month_expenditure(month_exp, exp, 'm_care',25,35)
    month_exp <- month_expenditure(month_exp, exp, 'm_communication',36,39)
    month_exp <- month_expenditure(month_exp, exp, 'm_health',42,55)
    month_exp <- month_expenditure(month_exp, exp, 'm_other',40,41)

    setnames(month_exp, c('clust'), c('cluster'))
    month_exp <- erase_label(month_exp, variables)

    # Frequent expenditure -------------------------------------------------
    ## Note Frequent expenditure is almost equivalent to monthly expenditure, collected every ~3days over a month
    exp <- read_sav('eicv5/cs_S8A3_expenditure.sav')
    freq_exp <- unique(as.data.frame(exp[,c('hhid','clust', 'province','district')])) 
    exp$s8a3q3[is.na(exp$s8a3q3)] <- 0 #set NULL values to zero. s8a3q3-"Amount spent over the last 7 days" 
    ## summation across 11 separate visits
    exp$month_exp <- exp$s8a3q3 + exp$s8a3q4 + exp$s8a3q5 + exp$s8a3q6 + exp$s8a3q7 + 
    exp$s8a3q8 + exp$s8a3q9 + exp$s8a3q10 + exp$s8a3q11+ exp$s8a3q12 + 
    exp$s8a3q13
    exp$annual_exp <- exp$month_exp # add monthly expenditures to annual dataframe
    # convert to monthly equivalent
    # exp$month_exp[exp$s8a3q2 > 0] <- exp$month_exp[exp$s8a3q2 > 0] / exp$s8a3q2[exp$s8a3q2 > 0]

    # Expenditure
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_leisure',1,5)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_care',6,10)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_petrol',11,11)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_diesel',12,12)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_transport',13,18)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_gas',19,19)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_kerosene',20,20)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_charcoal',21,21)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_wood',22,22)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_energy_materials',23,26)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_fuel_generator',27,27)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_repairs',28,30)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_communication',31,34)
    freq_exp <- freq_expenditure(freq_exp, exp, 'f_other',35,37)

    setnames(freq_exp, c('clust'), c('cluster'))
    freq_exp <- erase_label(freq_exp, variables)

    # Food expenditure -------------------------------------------------
    exp <-read_sav('eicv5/cs_S8B_expenditure.sav')
    exp$month_exp <- exp$s8bq3 + exp$s8bq4 + exp$s8bq5 + exp$s8bq6 + exp$s8bq7 + 
    exp$s8bq8 + exp$s8bq9 + exp$s8bq10 + exp$s8bq11+ exp$s8bq12 + exp$s8bq13
    exp$annual_exp <- exp$month_exp
    # exp$annual_exp[exp$s8bq2 > 0] <- exp$month_exp[exp$s8bq2 > 0] * exp$s8bq2[exp$s8bq2 > 0]

    # Expenditure
    food_exp <- exp %>% group_by(hhid, clust, province, district) %>% 
        dplyr::summarise(food = sum(annual_exp)) 
    setnames(food_exp, c('clust'), c('cluster'))
    food_exp <- erase_label(food_exp, variables)
    rm(exp)

    # Expenditure aggregate ---------------------------------------------
    expenditure <- annual_exp
    expenditure <- merge(expenditure, month_exp, 
                        by = c('hhid','cluster','province','district'), all.x = T)
    expenditure <- merge(expenditure, freq_exp, 
                        by = c('hhid','cluster','province','district'), all.x = T)
    expenditure <- merge(expenditure, food_exp, 
                        by = c('hhid','cluster','province','district'), all.x = T)
    rm(annual_exp, food_exp, freq_exp, month_exp)

    return(expenditure)
}

clean_household_characteristics<- function(section5){
    # household charateristics -------------------------------------------------
    hh_xteristics <- as.data.frame(section5[,c('hhid','clust','province','district',
                                    's5aq1','s5aq2','s5aq3','s5aq5','s5aq6',
                                    's5aq7y','s5aq7m','s5bq2','s5dq1','s5dq2',
                                    's5dq3','s5eq21','s5eq3a' 
                                            )]) 
    setnames(hh_xteristics, c('clust','s5aq1','s5aq2','s5aq3','s5aq5','s5aq6',
                    's5aq7y','s5aq7m','s5bq2','s5dq1','s5dq2','s5dq3','s5eq21','s5eq3a'),
            c('cluster','housing_classfication','dwelling_type','num_hhs_in_dwellings',
            'num_rooms','num_bedrooms','num_years_in_dwelling','num_months_in_dwelling',
            'house_valuation','wall_material','roof_material','floor_material',
            'main_challenge_last_12_months','soln_to_challenge'))
    variables <- c('hhid','cluster','province','district')
    hh_xteristics <- erase_label(hh_xteristics, variables)

    # Roof type
    hh_xteristics$thatch_roof <- 0
    hh_xteristics$thatch_roof [hh_xteristics$roof_material == 1] <- 1
    hh_xteristics$metal_roof <- 0
    hh_xteristics$metal_roof [hh_xteristics$roof_material == 2] <- 1
    hh_xteristics$clay_roof <- 0
    hh_xteristics$clay_roof[hh_xteristics$roof_material == 3 | hh_xteristics$roof_material == 4
                    | hh_xteristics$roof_material == 6 ] <- 1

    hh_xteristics$other_roof <- 0
    hh_xteristics$other_roof[hh_xteristics$roof_material == 5 | hh_xteristics$roof_material == 7] <- 1

    # dwelling type
    hh_xteristics$single_hh_single_house <- 0
    hh_xteristics$single_hh_single_house [hh_xteristics$dwelling_type == 1] <- 1
    hh_xteristics$multiple_hh_single_house <- 0
    hh_xteristics$multiple_hh_single_house[hh_xteristics$dwelling_type == 2] <- 1
    hh_xteristics$single_hh_multi_house <- 0
    hh_xteristics$single_hh_multi_house[hh_xteristics$dwelling_type == 3 | hh_xteristics$dwelling_type == 6] <- 1
    hh_xteristics$multiple_hh_multi_house <- 0
    hh_xteristics$multiple_hh_multi_house[hh_xteristics$dwelling_type == 4 | hh_xteristics$dwelling_type == 5] <- 1
    hh_xteristics$other_hh <- 0
    hh_xteristics$other_hh[hh_xteristics$dwelling_type == 7] <- 1

    # Order variables
    hh_xteristics <- hh_xteristics %>% select(hhid, cluster, district, province,
                                            num_hhs_in_dwellings, num_rooms,num_bedrooms,
                                            num_years_in_dwelling,num_months_in_dwelling,house_valuation,
                                            thatch_roof, metal_roof, clay_roof,single_hh_single_house,
                                            multiple_hh_single_house,single_hh_multi_house,multiple_hh_multi_house,
                                            other_hh
                                            )
    return(hh_xteristics)
}

clean_rent<- function(section5){
    # Rent expenditure -------------------------------------------------
    rent <- as.data.frame(section5[,c('hhid','clust','province','district',
                                    's5aq1','s5aq2','s5aq3','s5aq5','s5aq6',
                                    's5aq7y','s5aq7m','s5bq2',
                                    
                                    's5aq11','s5bq7','s5bq4a','s5bq4b',
                                    's5bq5','s5bq6a','s5bq6b','s5bq9a','s5bq9b')]) 
    setnames(rent, c('clust','s5aq1','s5aq2','s5aq3','s5aq5','s5aq6',
                    's5aq7y','s5aq7m','s5bq2',
                    
                    's5aq11','s5bq7','s5bq4a','s5bq4b', 's5bq5',
                    's5bq6a','s5bq6b','s5bq9a','s5bq9b'),
            c('cluster','housing_classfication','dwelling_type','num_hhs_in_dwellings',
            'num_rooms','num_bedrooms','num_years_in_dwelling','num_months_in_dwelling',
            'house_valuation',
            
            'occupancy','outside','rent_amount','rent_unit',
            'rent_inkind','rent_kind_amount','rent_kind_unit','rent_other_amount',
            'rent_other_unit'))
    variables <- c('hhid','cluster','province','district')
    rent <- erase_label(rent, variables)

    # Payments cash
    rent$rent_amount[is.na(rent$rent_amount)] <- 0
    rent$rent_cash <- 0
    rent$rent_cash[rent$rent_unit == 1 & !is.na(rent$rent_unit)] <- rent$rent_amount[rent$rent_unit == 1 & !is.na(rent$rent_unit)] * 12
    rent$rent_cash[rent$rent_unit == 2 & !is.na(rent$rent_unit)] <- rent$rent_amount[rent$rent_unit == 2 & !is.na(rent$rent_unit)] * 3
    rent$rent_cash[rent$rent_unit == 3 & !is.na(rent$rent_unit)] <- rent$rent_amount[rent$rent_unit == 3 & !is.na(rent$rent_unit)] * 1

    # In kind
    rent$rent_kind_amount[is.na(rent$rent_kind_amount)] <- 0
    rent$rent_kind <- 0
    rent$rent_kind[rent$rent_kind_unit == 1 & !is.na(rent$rent_kind_unit)] <- rent$rent_kind_amount[rent$rent_kind_unit == 1 & !is.na(rent$rent_kind_unit)] * 12
    rent$rent_kind[rent$rent_kind_unit == 2 & !is.na(rent$rent_kind_unit)] <- rent$rent_kind_amount[rent$rent_kind_unit == 2 & !is.na(rent$rent_kind_unit)] * 3
    rent$rent_kind[rent$rent_kind_unit == 3 & !is.na(rent$rent_kind_unit)] <- rent$rent_kind_amount[rent$rent_kind_unit == 3 & !is.na(rent$rent_kind_unit)] * 1

    # Total Rent
    rent$rent_total <- rent$rent_cash + rent$rent_kind 

    # Shared Rent
    rent$rent_other_amount[is.na(rent$rent_other_amount)] <- 0
    rent$rent_other <- 0
    rent$rent_other[rent$rent_other_unit == 1 & !is.na(rent$rent_other_unit)] <- rent$rent_other_amount[rent$rent_other_unit == 1 & !is.na(rent$rent_other_unit)] * 12
    rent$rent_other[rent$rent_other_unit == 2 & !is.na(rent$rent_other_unit)] <- rent$rent_other_amount[rent$rent_other_unit == 2 & !is.na(rent$rent_other_unit)] * 3
    rent$rent_other[rent$rent_other_unit == 3 & !is.na(rent$rent_other_unit)] <- rent$rent_other_amount[rent$rent_other_unit == 3 & !is.na(rent$rent_other_unit)] * 1

    # Ownership
    rent$owner <- 0
    rent$owner[rent$occupancy == 1] <- 1

    # Shared Rent
    rent$rent_alone <- 0
    rent$rent_alone[rent$occupancy == 2 & rent$outside == 2] <- 1
    rent$rent_out <- 0
    rent$rent_out[rent$outside == 1 & (rent$rent_cash == 0 & rent$rent_kind == 0)] <- 1
    rent$rent_shared <- 0
    rent$rent_shared[rent$outside == 1 & (rent$rent_cash != 0 | rent$rent_kind != 0)] <- 1
    rent$rent_no <- 0
    rent$rent_no[rent$owner == 0 & rent$rent_alone == 0 & rent$rent_out == 0 & rent$rent_shared == 0] <- 1
    rent$occupancy <- as.numeric(rent$occupancy)

    rent$rent_subsidy <- 0
    rent$rent_subsidy[rent$rent_no == 1 | rent$out == 1] <- 100
    rent$rent_subsidy[rent$rent_shared == 1] <- round(rent$rent_other[rent$rent_shared == 1] / (rent$rent_total[rent$rent_shared == 1] + rent$rent_other[rent$rent_shared == 1]),2)

    # Order variables
    rent <- rent %>% select(hhid, cluster, district, province, rent_total, rent_cash, 
                            rent_kind, rent_other, owner, rent_subsidy, occupancy, 
                            rent_alone, rent_out, rent_shared, rent_no)
    return(rent)

}

clean_water <- function(section5) {
# Water -------------------------------------------------------------------
water <- as.data.frame(section5[,c('hhid','clust','province','district',
                                         's5cq1','s5cq2','s5cq9a','s5cq9b',
                                         's5cq10','s5cq11','s5cq12','s5cq13',
                                         's5cq14')]) 
setnames(water, c('clust','s5cq1','s5cq2','s5cq9a','s5cq9b', 's5cq10',
                        's5cq11','s5cq12','s5cq13','s5cq14'),
         c('cluster','source','distance','water_unit','water_amount',
           'other_buy','water_priv_amount','water_sold','sold_amount','contribute'))
variables <- c('hhid','cluster','province','district')
water <- erase_label(water, variables)

# Source
water$piped <- 0
water$piped[water$source == 1 | water$source == 2] <- 1
water$private <- 0
water$private[water$other_buy == 1] <- 1
water$distance[is.na(water$distance)] <- 0

# WASAC
water$wasac <- 0
water$wasac[!is.na(water$water_unit) & water$water_unit > 0] <- 12 * (water$water_amount[!is.na(water$water_unit) & water$water_unit > 0] / water$water_unit[!is.na(water$water_unit) & water$water_unit > 0])
   
# Private
water$water_other <- 0
water$water_other[water$private == 1] <- water$water_priv_amount[water$private == 1] * 52.14286

# Private
water$water_source <- 0
water$water_source <- water$contribute * 12
water <- erase_label(water, 'water_source')

# Water sold
water$water_income <- 0
water$water_income[water$water_sold == 1] <- water$sold_amount[water$water_sold == 1] * 365

# Order variables
water <- water %>% select(hhid, cluster, district, province, piped, wasac, private, 
                        water_other, water_source, distance, water_income)
return(water)
}


clean_electricity <- function(section5) {
    # Electricity -------------------------------------------------------------
    electricity <- as.data.frame(section5[,c('hhid','clust','province','district',
                                            's5cq16','s5cq16a1','s5cq16a4','s5cq16a5',
                                            's5cq16a6','s5cq16a8','s5cq16a9','s5cq17',
                                            's5cq18','s5cq18b71','s5cq18b72',
                                            's5cq18b8a','s5cq18b8b')]) 
    setnames(electricity, c('clust','s5cq16','s5cq16a1','s5cq16a4','s5cq16a5',
                            's5cq16a6','s5cq16a8','s5cq16a9','s5cq17','s5cq18',
                            's5cq18b71','s5cq18b72','s5cq18b8a','s5cq18b8b'),
            c('cluster','source','main_source','pay','availability',
            'availability_evening','blackouts','duration_blackouts','m_electricity_payment',
            'source_cooking','fuel1','fuel2','fuel1_cost','fuel2_cost'))
    variables <- c('hhid','cluster','province','district')
    electricity <- erase_label(electricity, variables) 

    # Source electricity
    electricity$pay[electricity$main_source == 7] <- 3 # 7- No electricity, 3- doesn't pay anyone for elec
    electricity$pay_elec <- 0
    electricity$pay_elec[electricity$pay != 3] <- 1 # pays for some form of electricity

    electricity$grid <- 0 
    electricity$grid[electricity$main_source == 1 | electricity$main_source == 2] <- 1 # national or mini grid customers
    electricity$generator <- 0 
    electricity$generator[electricity$main_source == 3] <- 1 # main source is a diesel generator
    electricity$solar <- 0 
    electricity$solar[electricity$main_source == 4] <- 1 # main source is solar home system
    electricity$lantern <- 0 
    electricity$lantern[electricity$main_source == 5] <- 1 # main source is solar latern
    electricity$battery <- 0 
    electricity$battery[electricity$main_source == 6] <- 1 # main source is rechargable batteries
    electricity$other <- 0 
    electricity$other[electricity$main_source == 8] <- 1 # main source is 'other'
    electricity$no_electricity <- 0 
    electricity$no_electricity[electricity$main_source == 7] <- 1 # has no electricity

    electricity$light_grid <- 0 
    electricity$light_grid[electricity$source == 1 | electricity$source == 2] <- 1 # main lighting is grid/mini-grid
    electricity$light_generator <- 0 
    electricity$light_generator[electricity$source == 4] <- 1 # main lighting is generator
    electricity$light_solar <- 0 
    electricity$light_solar[electricity$source == 9] <- 1 # main lighting issolar panel
    electricity$light_battery <- 0 
    electricity$light_battery[electricity$source == 10 | electricity$source == 12] <- 1 # main lighting is batteries
    electricity$light_latern <- 0 
    electricity$light_latern[electricity$source == 8] <- 1 # main lighting is agatadowa
    electricity$light_other <- 0 
    electricity$light_other[electricity$source == 3 | electricity$source == 5 |
                            electricity$source == 6 | electricity$source == 7 |
                            electricity$source == 11 | electricity$source == 13] <- 1 # main lighting is 'other'

    electricity$main_cooking <- 0
    # -TODO remove solar here fuel1 == 4
    electricity$main_cooking[electricity$source_cooking == 6 | 
                            electricity$fuel1 == 11 | electricity$fuel1 == 4] <- 1 #electric cooking/  
    electricity$secondary_cooking <- 0
    electricity$secondary_cooking[electricity$fuel2 == 11 | electricity$fuel2 == 4] <- 1

    # Payment
    electricity$m_electricity_payment[is.na(electricity$m_electricity_payment)] <- 0 
    electricity$m_electricity_payment <- electricity$m_electricity_payment # monthly electricity payment
    electricity <- erase_label(electricity, 'm_electricity_payment')

    # Cooking
    electricity$fuel1_cost[is.na(electricity$fuel1_cost)] <- 0
    electricity$fuel1_cost[electricity$main_cooking == 0] <- 0
    electricity$fuel2_cost[is.na(electricity$fuel2_cost)] <- 0
    electricity$fuel2_cost[electricity$secondary_cooking == 0] <- 0
    electricity$m_cooking_cost <- electricity$fuel1_cost + electricity$fuel2_cost 

    # Not good quality 
    electricity$duration_blackouts[is.na(electricity$duration_blackouts)] <- 0
    electricity$duration_blackouts[electricity$duration_blackouts == 888] <- NA
    electricity$availability[is.na(electricity$availability)] <- 0
    electricity$availability[electricity$availability == 888] <- NA
    electricity$availability_evening[is.na(electricity$availability_evening)] <- 0
    electricity$availability_evening[electricity$availability_evening == 888] <- NA

    # Order variables
    electricity <- electricity %>% select(hhid, cluster, district, province, 
                                        m_electricity_payment, no_electricity, pay_elec, 
                                        grid, generator, solar, lantern, battery, 
                                        other, light_grid, light_generator, 
                                        light_solar, light_battery, light_latern,
                                        light_other, main_cooking, secondary_cooking,
                                        m_cooking_cost)
    return(electricity)
}

clean_cooking<- function(section5){
    # Fuels -------------------------------------------------------------
    cooking <- as.data.frame(section5[,c('hhid','clust','province','district',
                                        's5cq18','s5cq18b71','s5cq18b72',
                                        's5cq18b8a','s5cq18b8b')]) 
    setnames(cooking, c('clust','s5cq18','s5cq18b71','s5cq18b72','s5cq18b8a',
                            's5cq18b8b'), c('cluster','source','fuel1','fuel2',
                                            'fuel1_cost','fuel2_cost'))
    variables <- c('hhid','cluster','province','district')
    cooking <- erase_label(cooking, variables) 

    # Erase electricity
    cooking$fuel1_cost[is.na(cooking$fuel1_cost)] <- 0
    cooking$fuel1_cost[cooking$source == 6 | cooking$fuel1 == 11] <- 0
    cooking$fuel2_cost[is.na(cooking$fuel2_cost)] <- 0
    cooking$fuel2_cost[cooking$fuel2 == 11] <- 0

    # Fuels
    cooking$main_source <- cooking$source
    cooking$primary_source <- cooking$fuel1
    cooking$fuel1[cooking$fuel1 == 1 | cooking$fuel1 == 10] <- 1
    cooking$fuel1[cooking$fuel1 == 2 | cooking$fuel1 == 3 |
                    cooking$fuel1 == 7] <- 2
    cooking$fuel1[cooking$fuel1 == 5 | cooking$fuel1 == 6 |
                    cooking$fuel1 == 8 | cooking$fuel1 == 12] <- 3
    cooking$fuel1[cooking$fuel1 == 9] <- 4
    cooking$fuel1[cooking$fuel1 == 12] <- 5
    cooking$fuel1[cooking$fuel1 == 99] <- 0

    cooking$secondary_source <- cooking$fuel2
    cooking$fuel2[cooking$fuel2 == 1 | cooking$fuel2 == 10] <- 1
    cooking$fuel2[cooking$fuel2 == 2 | cooking$fuel2 == 3 |
                    cooking$fuel2 == 7] <- 2
    cooking$fuel2[cooking$fuel2 == 5 | cooking$fuel2 == 6 |
                    cooking$fuel2 == 8 | cooking$fuel2 == 12] <- 3
    cooking$fuel2[cooking$fuel2 == 9] <- 4
    cooking$fuel2[cooking$fuel2 == 12] <- 5
    cooking$fuel2[cooking$fuel2 == 99] <- 0

    cooking$fuel_fossil <- 0
    cooking$fuel_fossil[cooking$fuel1 == 1] <- cooking$fuel_fossil[cooking$fuel1 == 1] + 
    cooking$fuel1_cost[cooking$fuel1 == 1]
    cooking$fuel_fossil[cooking$fuel2 == 1] <- cooking$fuel_fossil[cooking$fuel2 == 1] + 
    cooking$fuel2_cost[cooking$fuel2 == 1]

    cooking$fuel_coal <- 0
    cooking$fuel_coal[cooking$fuel1 == 2] <- cooking$fuel_coal[cooking$fuel1 == 2] + 
    cooking$fuel1_cost[cooking$fuel1 == 2]
    cooking$fuel_coal[cooking$fuel2 == 2] <- cooking$fuel_coal[cooking$fuel2 == 2] + 
    cooking$fuel2_cost[cooking$fuel2 == 2]

    cooking$fuel_biomass <- 0
    cooking$fuel_biomass[cooking$fuel1 == 3] <- cooking$fuel_biomass[cooking$fuel1 == 3] + 
    cooking$fuel1_cost[cooking$fuel1 == 3]
    cooking$fuel_biomass[cooking$fuel2 == 3] <- cooking$fuel_biomass[cooking$fuel2 == 3] + 
    cooking$fuel2_cost[cooking$fuel2 == 3]

    cooking$fuel_biogas <- 0
    cooking$fuel_biogas[cooking$fuel1 == 4] <- cooking$fuel_biogas[cooking$fuel1 == 4] + 
    cooking$fuel1_cost[cooking$fuel1 == 4]
    cooking$fuel_biogas[cooking$fuel2 == 4] <- cooking$fuel_biogas[cooking$fuel2 == 4] + 
    cooking$fuel2_cost[cooking$fuel2 == 4]

    cooking$fuel_other <- 0
    cooking$fuel_other[cooking$fuel1 == 5] <- cooking$fuel_other[cooking$fuel1 == 5] + 
    cooking$fuel1_cost[cooking$fuel1 == 5]
    cooking$fuel_other[cooking$fuel2 == 5] <- cooking$fuel_other[cooking$fuel2 == 5] + 
    cooking$fuel2_cost[cooking$fuel2 == 5]

    # Order variables
    cooking <- cooking %>% select(hhid, cluster, district, province, 
                                        fuel_fossil, fuel_coal, fuel_biomass, 
                                        fuel_biogas, fuel_other, source, 
                                        primary_source, secondary_source)
    return(cooking)
}

clean_savings<-function(section10C1){
    savings <- as.data.frame(section10C1[,c('hhid','clust','province','district',
                                  's10cq6','s10cq7')]) 
    setnames(savings, c('clust','s10cq6','s10cq7'),
            c('cluster','total_savings','deposited_past_year'))
    variables <- c('hhid','cluster','province','district')
    savings <- erase_label(savings, variables)
    return(savings)
}

clean_loans<-function(section10A2){

    loan <- as.data.frame(section10A2[,c('hhid','clust','province','district',
                                    's10aq7')]) 
    setnames(loan, c('clust','s10aq7'),
            c('cluster','loan_amount'))
    variables <- c('hhid','cluster','province','district')
    loans <- erase_label(loan, variables)
    return(loans)
    
}

clean_furniture<-function(section10B1){
    furniture <- as.data.frame(section10B1[,c('hhid','clust','province','district',
                                    's10b1q1','s10bq2','s10bq3','s10bq4')]) 
    setnames(furniture, c('clust','s10b1q1','s10bq2','s10bq3','s10bq4'),
            c('cluster','item_code','articles_in_HH_count','sold_article','amount_of_item_sold'))
    variables <- c('hhid','cluster','province','district')
    furniture <- erase_label(furniture, variables)
    return(furniture) 
}

clean_appliances<-function(section10B2){

    durables <- as.data.frame(section10B2[,c('hhid','clust','province','district',
                                            's10b2q1','s10b2q2','s10bq5ay','s10bq5am',
                                            's10bq5by','s10bq5bm','s10bq5cy','s10bq5cm',
                                            's10bq6b','s10bq6c','s10bq7a','s10bq7b','s10bq7c')]) 
    setnames(durables, c('clust','s10b2q1','s10b2q2','s10bq5ay','s10bq5am','s10bq5by','s10bq5bm',
                        's10bq5cy','s10bq5cm','s10bq6b','s10bq6c','s10bq7a','s10bq7b','s10bq7c'),
            c('cluster','item_code','articles_in_HH_count','art1_purchase_year','art1_purchase_month',
            'art2_purchase_year','art2_purchase_month','art3_purchase_year','art3_purchase_month',
            'art2_purchase_price','art3_purchase_price','art1_current_value','art2_current_value',
            'art3_current_value'
            ))
    variables <- c('hhid','cluster','province','district')
    durables <- erase_label(durables, variables)

    return(durables)
    
}