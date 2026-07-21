# Neuroprems 2026

This battery of behavioural tasks assesses reward, effort, delay and social decision-making.
The battery originally is comprised of 24 reward items and 24 effort items. 
However, for 'shortening' purposes 4 reward items (2 food and 2 non-food) and 4 effort items
(2 physical and 2 cognitive) were removed.
Training trials were also removed from all tasks.

# Tasks
- Reward Rating Task (20 trials) --> taskRatingR2_V2023_img
- Effort Rating Task (20 trials) --> taskRatingE2_V2023_img
- Willingness to Work Task (20 trials) --> taskWeightR2E2_V2024_img
- Willingness to Wait Task (20 trials) --> taskChoice_DelayR2_V2024
- Social Disinhibition Task (24 trials) --> taskChoice4D_NR2AS_V2024


# Usage
Ideally, the tasks use the ratings of the participant. However, in case the ratings were skipped it can still run without errors.
The WeightR2E2 task uses the original pairings of items. The DelayR2 task, uses the ratings of 31 control participants from the
cogMotiv study (IDs 20:51). The 4D task also uses the original pairings of items storing NaNs where the item ratings would be
stored in the data table. 

The 31 cogMotiv datasets, are located in the MotiscanV2024 battery in the Prisme data folder. 

# Pairing Specificities
# Willingness To Work Task 
There are 4 types of pairs. 
	A) 5 pairs of a physical effort with a food reward
	B) 5 pairs of a cognitive effort with a non-food reward
	C) 5 pairs of a physical effort with a non-food reward
	D) 5 pairs of a cognitive effort with a food reward

# Willingness To Wait Task
There are 10 pairs of food vs food choices and 10 pairs of non-food vs non-food choices.
Delays range from 1 day to 1 year.


# 4D Task
There are 24 trials. There are 12 social norm violation items, each repeated 2 times, one time with an audience watching, one time without any audience. There is either no-sanction, an explicit sanction or an ambigus sanction for each trial. Each type of sanction appears in 8 trials each.
3 levels of rewards are pre-selected for each social norm violation item, and one is randomly selected at every trial.