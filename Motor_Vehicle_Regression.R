#This is the data accumulation for the motor vehicle data, first we will get
#tidyverse and read the CSV file as "vehicle_data"
library(tidyverse)

vehicle_data <- read_csv("/Users/alexordonez/Documents/Motor_Vehicle_Project/clean_motor_vehicle_table.csv")

#We will now convert the following fields into factors for easier analysis

vehicle_data$BOROUGH <- as.factor(vehicle_data$BOROUGH)
vehicle_data$BOROUGH <- relevel(factor(vehicle_data$BOROUGH), ref = "STATEN ISLAND")
vehicle_data$PERSON_INJURY <- as.factor(vehicle_data$PERSON_INJURY)
vehicle_data$PERSON_SEX <- as.factor(vehicle_data$PERSON_SEX)
vehicle_data$DRIVER_LICENSE_STATUS <- factor(vehicle_data$DRIVER_LICENSE_STATUS, 
                                           levels = c("Unlicensed", "Permit", "Licensed"), 
                                           ordered = TRUE)
vehicle_data$TYPE_OF_VEHICLE <- as.factor(vehicle_data$TYPE_OF_VEHICLE)

#Make sure that for drivers license status it is ordered
levels(vehicle_data$DRIVER_LICENSE_STATUS)


#Make sure for age, no values fall out of reasonable driver age
max(vehicle_data$PERSON_AGE)
min(vehicle_data$PERSON_AGE)

#We can see that the minimum is 1 and maximum is 145. This is not realistic and was probably due
#to data entry error. We will make the minimum value 12 and maximum 100 for this analysis

vehicle_data <- vehicle_data %>% filter(PERSON_AGE > 12, PERSON_AGE < 100)


#Makes a seperate field so that we can check if the collision cause any injuries or fatalities
vehicle_data <- vehicle_data %>%
  mutate(INJURY_OR_FATALITY = ifelse(PERSON_INJURY %in% c("Injured", "Killed"), TRUE, FALSE))
vehicle_data <- vehicle_data %>%
  mutate(FATALITY = ifelse(PERSON_INJURY %in% "Killed", TRUE, FALSE))

#After a quick check on the count of TYPE_OF_VEHICLES with our newly created INJURY_OR_FATALITY 
#column we see that one of the 

table(vehicle_data$TYPE_OF_VEHICLE, vehicle_data$INJURY_OR_FATALITY)


#We will combine taxi and livery (limos) together because of its low frequency (it may disrupt the model)


library(forcats)
vehicle_data <- vehicle_data %>%
  mutate(TYPE_OF_VEHICLE = fct_collapse(TYPE_OF_VEHICLE,
                                        "Taxi/Livery" = c("Livery", "Taxi")))

#Making a logistic regression analysis for if there is an injury or fatality for the driver of the motor vehicle

mod1 <- glm(INJURY_OR_FATALITY ~ BOROUGH+TYPE_OF_VEHICLE+PERSON_SEX+DRIVER_LICENSE_STATUS+PERSON_AGE, data = vehicle_data, family = "binomial")
summary(mod1)

#Multicollinearity is not an issue as we can see from the VIF 

alias(mod1)

#Above shows the way we can check to see if the logistic regression model is significant, we can
#use a Chi-Square test to test expected observations (null) and our model to see if p>0.05.
#We find out it is indeed below 0.05, meaning the model is signficant

null_mod1 <- glm(INJURY_OR_FATALITY ~ 1, data = vehicle_data, family = "binomial")
anova(null_mod1, mod1, test = "Chisq")


#Testing now to see how well the model fits with the data

install.packages("ResourceSelection")
library(ResourceSelection)
hoslem.test(vehicle_data$INJURY_OR_FATALITY, fitted(mod1))

#Because the model is significant but it does not really overlap well with the data well we
#will make some adjustments to the model. We will try to overlap borough with vehicle type

#However, first we will condense the other non-significant vehicles into "Larger Vehicles"
#As they all seem to be Vans, Trucks, Buses, etc...

vehicle_data$TYPE_OF_VEHICLE <- fct_collapse(vehicle_data$TYPE_OF_VEHICLE,
                                             "Large Vehicles" = c("Truck", "Pickup Truck", "Van", "Emergency Vehicle"))


mod2 <- glm(INJURY_OR_FATALITY ~ BOROUGH + TYPE_OF_VEHICLE + PERSON_SEX + 
              DRIVER_LICENSE_STATUS + PERSON_AGE, 
            data = vehicle_data, family = "binomial")
summary(mod2)


#We see that unidentified gender "U" and larger Vehicles are not significant in our model
#As a results, we will filter them out and try the new model again

vehicle_data <- vehicle_data %>% 
  filter(TYPE_OF_VEHICLE != "Large Vehicles")
vehicle_data <- vehicle_data %>% 
  filter(PERSON_SEX != "U")
vehicle_data <- vehicle_data %>%
  mutate(DRIVER_LICENSE_STATUS = ifelse(DRIVER_LICENSE_STATUS == "Permit", "Unlicensed", DRIVER_LICENSE_STATUS)) %>%
  mutate(DRIVER_LICENSE_STATUS = as.factor(DRIVER_LICENSE_STATUS))


mod3 <- glm(INJURY_OR_FATALITY ~ BOROUGH + TYPE_OF_VEHICLE + PERSON_SEX + 
              DRIVER_LICENSE_STATUS + PERSON_AGE, 
            data = vehicle_data, family = "binomial")
summary(mod3)


hoslem.test(vehicle_data$INJURY_OR_FATALITY, fitted(mod3))

#Still does not seem like it is accurately fitting the data, since Age is the only
#numerical data in the model, we will try to see if it might be possible that younger drivers
#and older drivers have a more disproportionate likelihood of injury/fatality. We can do that
#using the poly() function in the model to see if the relationship might be curved.

mod4 <- glm(INJURY_OR_FATALITY ~ BOROUGH + TYPE_OF_VEHICLE + PERSON_SEX + 
              DRIVER_LICENSE_STATUS + poly(PERSON_AGE,2), 
            data = vehicle_data, family = "binomial")

summary(mod4)

hoslem.test(vehicle_data$INJURY_OR_FATALITY, fitted(mod4))


#This is for Jupyter notebook, will make it easier to show the data

library(broom)
final_model_summary <- tidy(mod4)
print(final_model_summary)


#END OF ANALYSIS



#DATA VISUALIZATIONS:

#We will make a graphic that shows the injuries and fatalities per 100,000 residents
#per Borough. We have to make a separate data frame and then mutate onto vehicle_data
#to do that 
borough_pop <- data.frame(
  BOROUGH = c("BRONX", "BROOKLYN", "MANHATTAN", "QUEENS", "STATEN ISLAND"),
  POPULATION = c(1379946, 2590516, 1596273, 2278029, 491133)
)

borough_pop$BOROUGH <- as.factor(borough_pop$BOROUGH)
vehicle_data <- merge(vehicle_data, borough_pop, by = "BOROUGH")

injury_or_fatality_summary <- vehicle_data %>%
  group_by(BOROUGH) %>% summarise(INJURY_OR_FATALITY_COUNT = sum(INJURY_OR_FATALITY),
                                  POPULATION = first(POPULATION)) %>%
  mutate(RATE_PER_100K = (INJURY_OR_FATALITY_COUNT / POPULATION) * 100000)

ggplot(injury_or_fatality_summary, aes(x = BOROUGH, y = RATE_PER_100K, fill = BOROUGH)) +
  geom_bar(stat = "identity") + labs(title = "Injuries or Fatalities per 100,000 Residents by Borough",
                                     x = "Borough", y = "Rate per 100,000 Residents") + theme_minimal() + theme(legend.position = "none")



#We will make now a graph that shows the relationship between age and the likelihood of
#a injury or fatality occurring. We would need to first do something very similar to what we did
#for the borough graph, adding a new column to vehicle_data.
age_summary <- vehicle_data %>%
  group_by(PERSON_AGE) %>%  
  summarise(TOTAL_CASES = n(), INJURY_OR_FATALITY_COUNT = sum(INJURY_OR_FATALITY)) %>%
  mutate(PROBABILITY_PER_AGE = INJURY_OR_FATALITY_COUNT / TOTAL_CASES)  

ggplot(age_summary, aes(x = PERSON_AGE, y = PROBABILITY_PER_AGE)) +
  geom_point(color = "red", size = 2) +  
  labs(title = "Likelihood of Injury or Fatality by Age", x = "Age", y = "Likelihood of Injury or Fatality") + theme_minimal()
