#-------------------------------------------------------------------------------
#  Electricity Consumption: The Role of Grid Reliability in Appliance Ownership 
#  and Usage in Rwanda
#  						   	
#  Joel Mugyengi, Gabriel Gonzalez Sutil, Vijay Modi		  	
#  
#-------------------------------------------------------------------------------

# Before running this code please run prepare_data_regression.R

# Figure 5: Composition of Tables ----------------------------------------------

# Auxiliary Calculations for Figure
sum(sample$appliances)
vars <- c('radio','analogue','smart','tv','dvd','satellite_dish','decoder',
          'music','computer','printer','camera','hotplate','cooker',
          'fridge','laundry','filter','fan','sewing')
appliances <- data.frame('appliance' = c('Radio','Feature Phones','Smart Phones',
                                         'TV','DVD','Satellite Dish','Decoder',
                                         'Music System','Computer','Printer',
                                         'Camera','Hotplate','Cooker',
                                         'Fridge','Laundry Machine','Water Filter',
                                         'Fan','Sewing Machine'),
                         'value' = colSums(sample[,vars]))
rownames(appliances) <- NULL
appliances$percentage <- round(appliances$value/sum(appliances$value) * 100,2)
aux <- data.frame('appliance' = 'Other',
                  'value' = appliances$value[appliances$appliance == 'Printer'] +
                    appliances$value[appliances$appliance == 'Fan'] +
                    appliances$value[appliances$appliance == 'Camera'] +
                    appliances$value[appliances$appliance == 'Hotplate'] +
                    appliances$value[appliances$appliance == 'Music System'] +
                    appliances$value[appliances$appliance == 'Laundry Machine'],
                    'percentage' = round((appliances$value[appliances$appliance == 'Printer'] +
                                            appliances$value[appliances$appliance == 'Fan'] + 
                                            appliances$value[appliances$appliance == 'Hotplate'] +
                                            appliances$value[appliances$appliance == 'Camera'] +
                                            appliances$value[appliances$appliance == 'Music System'] +
                                            appliances$value[appliances$appliance == 'Laundry Machine'])/sum(appliances$value) * 100,2)) 
  
appliances <- rbind(appliances, aux)
rm(aux)

aux <- c('Radio','Feature Phones','Smart Phones',
         'TV','DVD','Satellite Dish','Decoder',
         'Computer','Cooker','Fridge','Water Filter',
         'Sewing Machine','Other')

png("imgs/figure_5.png")
ggplot(appliances[appliances$appliance %in% aux,]  , aes(area = percentage, fill = appliance,
                       label = paste(appliance, percentage, sep = "\n"))) +
  geom_treemap() +
  geom_treemap_text(colour = "white",
                    place = "centre",
                    size = 15) +
  theme(legend.position = "none")
dev.off()

rm(aux)

# Table 2: Appliance Distribution -------------------------------------------- 

# Auxiliary Calculation
stock <- sample %>% group_by(appliances) %>% tally()
stock$n <- (stock$n/nrow(sample))*100

appliances <- sample[,c('appliances_y','radio_y','analogue_y','smart_y',
                        'tv_y','dvd_y','satellite_dish_y','decoder_y','music_y',
                        'computer_y','printer_y','camera_y','hotplate_y','cooker_y',
                        'fridge_y','laundry_y','filter_y','fan_y','sewing_y')]

aux <- sample[,c('appliances','radio','analogue','smart','tv','dvd',
                 'satellite_dish','decoder','music','computer','printer',
                 'camera','hotplate','cooker','fridge','laundry','filter',
                 'fan','sewing')]

table_2 <- data.frame('appliance' = c("Any","Radio","Feature Phones","Smart Phones", "TV",
                                     "DVD player","Satellite Dish","Decoder",
                                     "Music System","Computer","Printer","Camera",
                                     "Hotplate","Cooker","Fridge",'Laundry Machine',
                                     "Water Filter","Electric Fan","Sewing Machine"),
                     'households' = round(colSums(appliances),2),
                     'percentage' = round((colSums(appliances)/nrow(appliances))*100,2),
                     'mean' = c(mean(aux$appliances[aux$appliances > 0]),
                                mean(aux$radio[aux$radio > 0]),
                                mean(aux$analogue[aux$analogue > 0]),
                                mean(aux$smart[aux$smart > 0]),
                                mean(aux$tv[aux$tv > 0]),
                                mean(aux$dvd[aux$dvd > 0]),
                                mean(aux$satellite_dish[aux$satellite_dish > 0]),
                                mean(aux$decoder[aux$decoder > 0]),
                                mean(aux$music[aux$music > 0]),
                                mean(aux$computer[aux$computer > 0]),
                                mean(aux$printer[aux$printer > 0]),
                                mean(aux$camera[aux$camera > 0]),
                                mean(aux$hotplate[aux$hotplate > 0]),
                                mean(aux$cooker[aux$cooker > 0]),
                                mean(aux$fridge[aux$fridge > 0]),
                                mean(aux$laundry[aux$laundry > 0]),
                                mean(aux$filter[aux$filter > 0]),
                                mean(aux$fan[aux$fan > 0]),
                                mean(aux$sewing[aux$sewing > 0])),
                     'sd' = c(sd(aux$appliances[aux$appliances > 0]),
                              sd(aux$radio[aux$radio > 0]),
                              sd(aux$analogue[aux$analogue > 0]),
                              sd(aux$smart[aux$smart > 0]),
                              sd(aux$tv[aux$tv > 0]),
                              sd(aux$dvd[aux$dvd > 0]),
                              sd(aux$satellite_dish[aux$satellite_dish > 0]),
                              sd(aux$decoder[aux$decoder > 0]),
                              sd(aux$music[aux$music > 0]),
                              sd(aux$computer[aux$computer > 0]),
                              sd(aux$printer[aux$printer > 0]),
                              sd(aux$camera[aux$camera > 0]),
                              sd(aux$hotplate[aux$hotplate > 0]),
                              sd(aux$cooker[aux$cooker > 0]),
                              sd(aux$fridge[aux$fridge > 0]),
                              sd(aux$laundry[aux$laundry > 0]),
                              sd(aux$filter[aux$filter > 0]),
                              sd(aux$fan[aux$fan > 0]),
                              sd(aux$sewing[aux$sewing > 0])),
                     'min' = c(min(aux$appliances[aux$appliances > 0]),
                               min(aux$radio[aux$radio > 0]),
                               min(aux$analogue[aux$analogue > 0]),
                               min(aux$smart[aux$smart > 0]),
                               min(aux$tv[aux$tv > 0]),
                               min(aux$dvd[aux$dvd > 0]),
                               min(aux$satellite_dish[aux$satellite_dish > 0]),
                               min(aux$decoder[aux$decoder > 0]),
                               min(aux$music[aux$music > 0]),
                               min(aux$computer[aux$computer > 0]),
                               min(aux$printer[aux$printer > 0]),
                               min(aux$camera[aux$camera > 0]),
                               min(aux$hotplate[aux$hotplate > 0]),
                               min(aux$cooker[aux$cooker > 0]),
                               min(aux$fridge[aux$fridge > 0]),
                               min(aux$laundry[aux$laundry > 0]),
                               min(aux$filter[aux$filter > 0]),
                               min(aux$fan[aux$fan > 0]),
                               min(aux$sewing[aux$sewing > 0])),
                     'max' = c(max(aux$appliances[aux$appliances > 0]),
                               max(aux$radio[aux$radio > 0]),
                               max(aux$analogue[aux$analogue > 0]),
                               max(aux$smart[aux$smart > 0]),
                               max(aux$tv[aux$tv > 0]),
                               max(aux$dvd[aux$dvd > 0]),
                               max(aux$satellite_dish[aux$satellite_dish > 0]),
                               max(aux$decoder[aux$decoder > 0]),
                               max(aux$music[aux$music > 0]),
                               max(aux$computer[aux$computer > 0]),
                               max(aux$printer[aux$printer > 0]),
                               max(aux$camera[aux$camera > 0]),
                               max(aux$hotplate[aux$hotplate > 0]),
                               max(aux$cooker[aux$cooker > 0]),
                               max(aux$fridge[aux$fridge > 0]),
                               max(aux$laundry[aux$laundry > 0]),
                               max(aux$filter[aux$filter > 0]),
                               max(aux$fan[aux$fan > 0]),
                               max(aux$sewing[aux$sewing > 0])),
                     'share' = c((length(aux$appliances[aux$appliances > 1])/
                                   length(aux$appliances[aux$appliances > 0]))*100,
                                 (length(aux$radio[aux$radio > 1])/
                                    length(aux$radio[aux$radio > 0]))*100,                                 
                                 (length(aux$analogue[aux$analogue > 1])/
                                    length(aux$analogue[aux$analogue > 0]))*100,
                                 (length(aux$smart[aux$smart > 1])/
                                    length(aux$smart[aux$smart > 0]))*100,
                                 (length(aux$tv[aux$tv > 1])/
                                    length(aux$tv[aux$tv > 0]))*100,
                                 (length(aux$dvd[aux$dvd > 1])/
                                    length(aux$dvd[aux$dvd > 0]))*100, 
                                 (length(aux$satellite_dish[aux$satellite_dish > 1])/
                                    length(aux$satellite_dish[aux$satellite_dish > 0]))*100,
                                 (length(aux$decoder[aux$decoder > 1])/
                                    length(aux$decoder[aux$decoder > 0]))*100,
                                 (length(aux$music[aux$music > 1])/
                                    length(aux$music[aux$music > 0]))*100,
                                 (length(aux$computer[aux$computer > 1])/
                                    length(aux$computer[aux$computer > 0]))*100,
                                 (length(aux$printer[aux$printer > 1])/
                                    length(aux$printer[aux$printer > 0]))*100,
                                 (length(aux$camera[aux$camera > 1])/
                                    length(aux$camera[aux$camera > 0]))*100,
                                 (length(aux$hotplate[aux$hotplate > 1])/
                                    length(aux$hotplate[aux$hotplate > 0]))*100,
                                 (length(aux$cooker[aux$cooker > 1])/
                                    length(aux$cooker[aux$cooker > 0]))*100,
                                 (length(aux$fridge[aux$fridge > 1])/
                                    length(aux$fridge[aux$fridge > 0]))*100,
                                 (length(aux$laundry[aux$laundry > 1])/
                                    length(aux$laundry[aux$laundry > 0]))*100,
                                 (length(aux$filter[aux$filter > 1])/
                                    length(aux$filter[aux$filter > 0]))*100,
                                 (length(aux$fan[aux$fan > 1])/
                                    length(aux$fan[aux$fan > 0]))*100,
                                 (length(aux$sewing[aux$sewing > 1])/
                                    length(aux$sewing[aux$sewing > 0]))*100))

table_2$mean <- round(table_2$mean,2)                                  
table_2$sd <- round(table_2$sd,2)                                    
table_2$min <- round(table_2$min,2)
table_2$max <- round(table_2$max,2)
table_2$share <- round(table_2$share,2)
rownames(table_2) <- NULL

table_2 <- table_2[order(table_2$households, decreasing = T),]

stargazer(table_2, type='latex', summary=FALSE, out = "code/output/table_2.tex")

# Figure 6: Ownership Categories -----------------------------------------------

aux <- c('no_appliance','cat_1_y','cat_2_y','cat_3_y','cat_4_y')
aux <- data.frame('appliance' = c('no_appliance','cat_1_y',
                                  'cat_2_y','cat_3_y','cat_4_y'),
                  'value' = colSums(sample[,c(aux)])/nrow(sample) * 100)

png("imgs/figure_6_a.png")
par(mar = c(4, 7, 0.1, 2))  
barplot(aux$value, xlim = c(0,100),col = c("#999999", "#E69F00", "#56B4E9"), 
        names.arg = c('No Appliance','Communication','Entertainment',
                      'Productivity','Convenience'),
        xlab = "% Hoursholed",
        horiz = TRUE, las=2)
dev.off()
par(mar = c(5.1, 4.1, 4.1, 2.1))

aux <- data.frame(sample[, c('cat_1','cat_2','cat_3','cat_4')])

png("imgs/figure_6_b.png")
par(mar = c(4, 7, 0.1, 2))  
aux$cat_1[aux$cat_1 == 0] <- NA
aux$cat_2[aux$cat_2 == 0] <- NA
aux$cat_3[aux$cat_3 == 0] <- NA
aux$cat_4[aux$cat_4 == 0] <- NA
boxplot(aux, names = c('Communication','Entertainment',
                       'Productivity','Convenience'), 
        col = c("#999999", "#E69F00", "#56B4E9"),
        xlab = 'Number of appliances', ylim = c(0,15), horizontal = TRUE,
        las=2 )
dev.off()
par(mar = c(5.1, 4.1, 4.1, 2.1))

# Table 3 --------------------------------------------------------------------

sample <- sample[complete.cases(sample),]

vars <- c(x)
table_3 <- data.frame('Variable' = rep(0,length(vars)),'mean' = rep(0,length(vars)),
                      'sd' = rep(0,length(vars)),'min' = rep(0,length(vars)),
                      'max' = rep(0,length(vars)))

for(i in 1:length(vars)){
  table_3$Variable[i] <- vars[i]
  table_3$mean[i] <- mean(sample[,c(vars[i])])
  table_3$sd[i] <- sd(sample[,c(vars[i])])
  table_3$min[i] <- min(sample[,c(vars[i])])
  table_3$max[i] <- max(sample[,c(vars[i])])
}

table_3$mean <- round(table_3$mean,2)                                  
table_3$sd <- round(table_3$sd,2)                                    
table_3$min <- round(table_3$min,2)
table_3$max <- round(table_3$max,2)

stargazer(table_3, type='latex', summary=FALSE, out = "code/output/table_3.tex")


# Table 3 --------------------------------------------------------------------

sample <- sample[complete.cases(sample),]

vars <- c(lightning)
table_4 <- data.frame('Variable' = rep(0,length(vars)),'mean' = rep(0,length(vars)),
                      'sd' = rep(0,length(vars)),'min' = rep(0,length(vars)),
                      'max' = rep(0,length(vars)))

for(i in 1:length(vars)){
  table_4$Variable[i] <- vars[i]
  table_4$mean[i] <- mean(sample[,c(vars[i])])
  table_4$sd[i] <- sd(sample[,c(vars[i])])
  table_4$min[i] <- min(sample[,c(vars[i])])
  table_4$max[i] <- max(sample[,c(vars[i])])
}

table_4$mean <- round(table_4$mean,2)                                  
table_4$sd <- round(table_4$sd,2)                                    
table_4$min <- round(table_4$min,2)
table_4$max <- round(table_4$max,2)

table_4$Variable <- c('Average Lightning Radiance','Frequency Lightning')

stargazer(table_4, type='latex', summary=FALSE, out = "code/output/table_4.tex")


