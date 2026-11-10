# Data Cleaning and Processing

The code to clean and process data is contained in the "clean_data" directory. In this 
directory, there are two sub-directories "cleaning_scripts" and "notebooks". "cleaning_scripts"
contains scripts with helper functions used in the notebooks in the "notebooks" sub-directory. 

## Notebooks
### Cleaning EICV Survey data
The "EICV_clean.ipynb" notebook cleans and processes the eicv5 survey data. Details about this
survey are provided in the paper submission. The notebook using helper functions from 
"clean_eicv_script" in the "cleaning_scripts" sub-directory organizes household survey 
data in a format that we can eventually easily use in our econometrics models. 

#### notebook: "EICV_clean"
1. Importing Libraries
Python libraries pandas, numpy, and seaborn are imported for data manipulation and visualization.
R code is also executed within the Python environment using rpy2, allowing integration of R-based data cleaning scripts.
2. Loading R Scripts and Setting Paths
The R script for cleaning EICV5 data is sourced to process raw survey data files.
Paths to directories containing raw data files (.sav files from SPSS) are specified, allowing the script to locate and import relevant files.
3. Cleaning and Preparing Data
Multiple datasets are loaded into R using read_sav() from various sections of the EICV5 survey. These include:
- Demographics (cs_S1_S2_S3_S4_S6A_S6E_Person.sav)
- Household characteristics, rent, water, electricity, and cooking data (cs_S0_S5_Household.sav)
- Savings and loans data (cs_S10C1_Savings.sav and cs_S10A2_Listing_of_credits.sav)
- Appliance and durable goods data (cs_S10B1_Durable_household_goods.sav and cs_S10B2_Durable_household_goods.sav)
- Expenditure data (cs_S8A1_expenditure.sav)
Cleaning functions (e.g., clean_demographics, clean_rent, clean_electricity) from
helper scripts are applied to standardize and filter each dataset.

4. Merging and Processing Data
Cleaned datasets are merged using unique household identifiers (hhid), allowing integration
 of various data types (e.g., demographics, income, appliance ownership).
Calculations include:
Household-level appliance ownership: Aggregates ownership counts for key appliances 
such as televisions, fridges, and mobile phones.
Appliance tier classification: Groups appliances into categories like entertainment 
(TVs, music systems) or heavy-duty (fridges, cookers) to analyze ownership patterns 
and consumption tiers.
Annual household expenditure and poverty metrics: Summarized to identify economic 
characteristics.
5. Additional Features
Tier Assignment: Households are categorized into tiers based on appliance ownership,
with checks for consistency and overlaps.
Education Costs: Processes detailed educational expenditures, including tuition,
uniforms, and other school-related costs.
Employment and Business Income: Extracts salary data, business turnover, and 
agricultural income for household-level income analysis.
Service Access: Calculates proximity and accessibility to essential services 
like roads, health centers, and schools.
6. Python Integration
Key processed datasets are exported back to Python for further analysis.
Python-specific operations include grouping, summarizing, and applying conditional logic 
(e.g., assigning appliance ownership indicators for smartphones or computers).
7. Output and Save Processed Data
Final cleaned and aggregated datasets are saved to specified directories in .csv format for subsequent analysis.
Purpose
This script is designed to:

Clean and harmonize complex survey data for analysis.
Enable detailed exploration of electricity consumption, appliance ownership, and household socio-economic characteristics.
Support modeling and policy insights on energy access and poverty in Rwanda.
This approach combines Python’s flexibility with R’s statistical capabilities
 to handle diverse data sources efficiently.

#### notebook: "EICV_clean"

1. Importing Libraries and Data
Libraries: Python libraries such as pandas, numpy, and matplotlib are imported for
data manipulation and visualization.
Data Loading:
Several pre-processed datasets (.csv files) related to demographics, household characteristics, 
socio-economic metrics, electricity usage, appliance ownership, loans, savings, and more are loaded.

2. Data Cleaning and Renaming
Data columns are renamed to ensure clear identification of variables, 
such as electricity consumption and payment data.
Columns unrelated to the analysis (e.g., geographic cluster information) are dropped
to simplify the dataset.
Variables for monthly electricity consumption (kWh) are computed using pre-defined 
utility functions from in the "cleaning_scripts" sub-directory.
3. Merging Datasets
The datasets are merged using the unique household identifier (hhid) to consolidate information
across different dimensions:
Demographics, socio-economic characteristics, Electricity Usage: Monthly and annual payments and consumption.
, Building and infrastructure data, Appliance Ownership: Number and types of appliances owned (electric and non-electric).
, Financial Metrics: Loans, savings, rent, poverty indicators, and agricultural income, Instrumental Variables: Data on lightning, rainfall, and distance to electrical grids for potential econometric modeling.
4. Handling Missing Data
Missing values in key variables have those rows dropped, or replaced with zero as appropriate
5. Expense Conversion
Annual to Monthly Conversion: Annual expenditures (e.g., housing, transport, education)
are divided by 12 to create monthly estimates.
Log Transformations: log-transformed monthly expenses are created to normalize the
distribution of expenditure data.
6. Instrumental Variables
Instrumental variables such as feeder line lightning metrics, rainfall,
and proximity to substations are integrated to account for endogeneity in subsequent analyses.
7. District and Province Mapping
A dictionary maps district and province names to numeric codes for easier
categorization and potential regression modeling.
8. Saving Processed Data
The final consolidated dataset, including 356 variables and information on 14,580 households,
is saved as a .csv file for further analysis. This dataset includes detailed socio-economic and
electricity usage information, as well as computed metrics for expenditures and 
appliance ownership.
Key Purpose
This pipeline prepares a comprehensive dataset for regression analysis. It is 
structured to support robust statistical and econometric modeling.


#### Notebook: reliability.ipynb
This code implements  data processing and analysis pipeline to examine 
electricity reliability, with a focus on outage patterns and household-level 
impacts in Rwanda. The pipeline integrates spatial, survey, and administrative datasets,
applying  cleaning and analytical techniques to produce meaningful outputs. 
Below is a description of each major component of the code:
1. Library Imports
Core Python libraries (pandas, numpy, matplotlib) are used for data manipulation, 
numerical calculations, and visualizations.
Geospatial libraries (geopandas) handle spatial data like district boundaries and 
electrical lines.
Custom utility functions (reliability_utils and infrastructure_utils) provide 
domain-specific data processing methods.
2. Household Survey Data Cleaning
EICV Reliability Data:
Survey data (cs_S0_S5_Household.sav) on household electricity experiences is imported and key reliability metrics
are extracted, including:
Overall electricity availability.
Evening electricity availability.
Outage frequency and duration.
Reports of damaged appliances and fatalities due to electricity.
Responses such as "Don't know" are converted to numerical indicators or replaced with
NaN.
Numerical transformations (e.g., converting durations to hours) 
are applied to standardize the data.
(This data has a lot of missing values and is there not utilized)
3. Administrative Data Cleaning
Reliability Data:
Medium Voltage (MV) outage data from 2016–2020 is processed to analyze the 
frequency and duration of outages by feeder line.
Spatial datasets such as line shapefiles (lv_lines.shp) and district boundaries (District_Boundaries.geojson) 
are cleaned and converted to a consistent coordinate reference system (CRS).
Outage causes are standardized (e.g., combining synonyms like "Planned works" and "Works").
Grouped statistics by feeder line are calculated for outage frequency and duration 
across years.
4. Matching Survey data to administrative data
Outage and reliability data for electrical feeders are merged with spatial data on
line locations, allowing for geospatial analysis.
Household survey data is matched with the nearest feeder lines 
(within a 600-meter distance), assigning outage metrics to households based on 
proximity to feeder lines.
5. Data Integration
All relevant datasets are merged using the household identifier (hhid), including:
- Survey reliability data.
- Administrative feeder-level reliability metrics.
- Household-level electricity and socio-economic metrics.
- Outage frequency and duration means are computed across all available years.
6. Data Export
Processed data is saved to .csv files for further use, including:
7. Visualization
Outage Causes:
A pie chart visualizes the distribution of outage causes, 
highlighting key drivers like planned works, load shedding, and emergencies.
Spatial Data:
Household survey data and feeder reliability metrics are visualized on maps 
to explore spatial patterns of reliability.

#### Notebook: lightning.ipynb

This code processes and analyzes satellite-based lightning observation data 
to generate geospatial insights, particularly focusing on lightning activity within 
Rwanda. The analysis involves extracting lightning data from satellite files, 
spatial filtering to focus on Rwanda, and geospatial aggregation with infrastructure 
features (e.g., electrical feeders). Here’s a breakdown of what the code does:
1. Import Required Libraries
Libraries such as netCDF4 and pandas handle satellite data and dataframes.
matplotlib is used for plotting, while geopandas manages geospatial data.
Utility modules (reliability_utils, shapely.geometry, etc.) help with custom functions
and geometric operations.
2. ISS LIS Lightning Data Extraction
Load Satellite Data:
Identifies and reads NetCDF files containing lightning data from the 
International Space Station Lightning Imaging Sensor (ISS LIS).
Extract Orbit Metadata:
Loops through files to extract orbit start and end times.
Converts these times to human-readable dates (num2date).
Extract Flash Locations:
Latitude and longitude of lightning flashes are extracted for each file.
Errors during data extraction are caught and logged.
Filter by Rwanda’s Bounding Box:
Filters lightning data to retain flashes occurring within Rwanda's geographical 
boundaries.
3. TRMM LIS Lightning Data Extraction
Similar processing is applied to TRMM LIS (Tropical Rainfall Measuring Mission) files:
Extracts latitude, longitude, and flash radiance (brightness) values.
Handles errors in files with missing or corrupted data.
4. Spatial Processing
Load Rwanda’s Administrative Boundaries:
District-level boundaries are read from a GeoJSON file.
Ensures consistency in projection systems (e.g., EPSG:32735 for projected CRS).
Filter Lightning Data by Districts:
Converts lightning data into a geospatial dataframe.
Filters lightning flashes to only include points within Rwanda’s districts using 
spatial joins.
5. Visualization
Plot Lightning Flash Locations:
Creates a heat map of lightning activity over Rwanda, color-coded by flash intensity.
Enhances visualization with geographic features like coastlines and district 
boundaries.
6. Aggregation with Feeder Boundaries
Load Infrastructure Data:
Reads shapefiles representing electrical feeders and other infrastructure.
Cleans and processes feeder line geometries.
Calculate Lightning Metrics by Feeder:
For each feeder area, calculates:
Average lightning radiance.
Total number of flashes.
Maximum observed radiance.
Aggregates these metrics at the feeder level.
7. Save Processed Data
Export Metrics:
Outputs the aggregated feeder-level lightning metrics (mean, count, and max radiance) 
to a CSV file for further use.
Save Lightning Locations:
Saves filtered lightning data to a separate CSV for future analysis.

#### Notebook: kriging.ipynb
This code uses geostatistical techniques (specifically, Ordinary Kriging)
to interpolate and predict spatially distributed variables such as rainfall 
over Rwanda. It integrates rainfall with 
geospatial information for analysis and visualization, producing predictions 
for points not directly observed (e.g., survey locations). 
1. Import Required Libraries
Standard Python libraries (numpy, pandas, matplotlib) handle data manipulation 
and visualization.
Geospatial libraries (geopandas) process spatial data, while pykrige 
performs Kriging interpolation.
Utility functions from infrastructure_utils facilitate specific tasks such as 
converting survey data into geospatial formats.
2. Data Import
Rainfall Data: (Please note rainfall data is priopertary. How to request the data is 
detailed in our paper submission)
Loads rainfall station data  containing 
locations and measurements such as mean rainfall, variance, and exceedance days.
Combines these measurements into a unified dataset (station_gps_rain).
District and Regional Boundaries:
Imports geographic boundary files for Rwanda and neighboring 
countries to aid in spatial plotting and context.
3. Ordinary Kriging for Spatial Interpolation
Purpose:
Interpolate rainfall metrics at unobserved locations using the spatial relationships 
in the data.
Inputs:
Coordinates (longitude, latitude) and the variable to interpolate (e.g., mean rainfall).
Kriging Setup:
Defines a variogram model (e.g., "exponential", "linear") to estimate spatial correlations.
Creates OrdinaryKriging models for:
Mean rainfall (OK_mean).
Rainfall variance (OK_var).
Rainfall exceedance days (OK_exceedance).
4. Grid-Based Predictions
Generate Grid:
Defines a geographic grid for Rwanda using longitudes and latitudes with a 
0.01-degree resolution.
Execute Kriging:
Predicts variable values at grid points using Kriging (execute("grid")).
Visualization:
Produces heat maps to visualize the spatial distribution of rainfall predictions over Rwanda.
Overlay district boundaries and highlight rainfall station locations for reference.
5. Point-Based Predictions
Survey Locations:
Loads survey household data, extracting their geospatial coordinates.
Kriging Predictions:
Computes predicted rainfall (mean and variance) at each survey household location.
Visualization:
Generates histograms to show the distribution of predicted values.
Integration:
Merges Kriging predictions with the survey dataset for further analysis.
6. Data Aggregation and Export
Combine Outputs:
Integrates predicted rainfall metrics with survey data and geospatial information.
Save Results:
Exports final datasets (survey_instrument_vars) for use in downstream analyses.

#### Notebook: infrastructure.ipynb
This code creates a geospatial dataset of socio-economic metrics by combining 
household survey data with distances to various infrastructure facilities and 
road density/quality metrics. 
1. Libraries and File Paths
Libraries:
Standard Python libraries for data manipulation (pandas, numpy) and 
visualization (matplotlib, seaborn).
geopandas for handling geospatial data and spatial operations.
infrastructure_utils for custom utility functions related to survey data processing.
Projection Systems:
geo_crs: Geographic coordinate system (EPSG:4326).
project_crs: Projected coordinate system for Rwanda (EPSG:32735).
2. Import Data
EICV Survey Data: Loads household survey data  and prepares it for spatial analysis.
Geospatial Datasets: Loads various infrastructure datasets, including: Schools, 
health centers, trade centers, coffee washing stations, tourism centers, 
industrial parks, district offices, religious centers, sports centers, 
and bus stations.
Roads: National paved and unpaved roads, district roads, and the entire road network.
Towns: Major towns, including Kigali and provincial capitals.
Cell Towers: Locations of cell towers in Rwanda.
Geometries and Projections: Converts all datasets to a common projection (project_crs) for spatial operations.
3. Infrastructure Distance Calculations
For each household in the survey dataset:
Calculates the nearest distance to each type of facility and road.
Uses gpd.sjoin_nearest to efficiently compute distances between household locations 
and facility points or road networks.
Adds distance metrics for:
Schools, health centers, trade centers, coffee centers, tourism centers, 
industrial parks, district offices, religious centers, sports centers, 
major towns, and bus stations.
4. Road Network Analysis
Road Density:
Buffers each household by a specified distance (200 meters).
Counts the number of road segments within this buffer.
Road Quality:
Evaluates the distribution of road types and their status 
(e.g., "Paved" or "Unpaved").
5. Data Processing and Aggregation
Combines distance metrics and road density metrics into a unified dataframe
(socio_econ_metrics).
Converts distances to kilometers for easier interpretation.
Prioritizes selected columns for final output:
Includes distances to key facilities, roads, and major towns.
Adds road density and classification metrics.
6. Visualization and Summary
Uses histograms and summary statistics to inspect road statuses and 
socio-economic metrics.
7. Saving the Final Dataset
Saves the combined socio-economic metrics dataset to a CSV file 
(socio_econ_metrics.csv) for use in subsequent analysis.

#### Notebook: visualization.ipynb
This code is focused on integrating, analyzing, and visualizing various household, 
infrastructure, socio-economic, and reliability metrics using geographic and 
tabular data. 
1. Libraries and File Loading
Imported Libraries:
pandas and numpy: For data manipulation and numerical analysis.
geopandas: For geospatial data operations.
matplotlib and seaborn: For plotting and visualizing data distributions.
Custom utilities (reliability_utils, infrastructure_utils, visual_utils): 
For specific data transformations and visualizations.
Loaded Files:
Demographic, household, appliance, financial, and reliability data.
Geographic files (district boundaries, infrastructure locations, roads, etc.).
Combined survey data and electricity metrics.
2. Preprocessing
Data Transformation:
Computes electricity's share in household expenses 
(elec_share_qsel and elec_share_nisr).
Categorizes purchases for visualization (purchase_categories).
Geospatial Data Preparation:
Administrative boundaries (admns) are cleaned and standardized for district, 
sector, cell, and village levels.
District boundaries and major town coordinates are converted to appropriate 
projections for mapping.
3. Analysis
Electricity Access:
Calculates the percentage of households with electricity access in each district 
and merges this with geographic data.
Urban-Rural Breakdown:
Computes the share of urban and rural households per district for visualization.
Appliance Ownership:
Calculates average appliance ownership per household for each district.
4. Reliability Analysis
Household Reliability Metrics:
Uses data on household proximity to feeder lines and outage data to compute:
mean_outage_duration: Average outage duration.
duration_per_outage: Outage duration per occurrence.
outages_per_day: Frequency of outages per day.
Visualizes outage distributions using kernel density plots (KDE) 
for each year and geographic heatmaps for key metrics.
5. Visualization
Geospatial Plots:
Electricity Access:
Maps the percentage of households with electricity access across districts.
Urban-Rural Distribution:
Visualizes rural household percentages by district.
Appliance Ownership:
Displays the percentage of appliance ownership geographically.
Reliability Metrics:
Maps reliability metrics (e.g., outage duration, outages per day) spatially.
Highlights feeders and feeder lines with distinct colors to represent 
their geographic distribution.
6. Infrastructure
Road and Infrastructure Mapping:
Plots roads, feeder lines, and associated geographic boundaries to understand 
spatial relationships with household metrics.
Feeder Visualization:
Uses a distinct color palette to differentiate feeders and overlays feeder lines 
and bounding boxes on a map.

#### Notebook: appliance_usage.ipynb
This code analyzes household appliance usage, electricity consumption, and 
reliability impacts. It processes appliance ownership data, computes electricity consumption, 
compares consumption across income groups, and visualizes the impact of grid reliability on 
electricity usage.

1. Import Libraries:
pandas and numpy: For data manipulation.
matplotlib and seaborn: For visualization.
plotly.express: For interactive visualizations (e.g., pie charts).
regression_utils and kWh_consumption: Custom modules for additional analysis and 
computation.
Import Data:
Household appliance data (appliance_count, non_electric_count, appliance_presence).
A comprehensive dataset (sample_qsel_11_21_23.csv) containing household-level monthly expenditures, 
outage data, demographic characteristics, and appliance ownership.
2. Electricity Consumption Calculation
Assign Monthly Consumption Values:
Maps electricity consumption (in kWh) to specific appliances based on standard usage 
values.
Computes the total monthly electricity consumption per household (monthly_hh_kWhs) by 
summing individual appliance contributions.
3. Aggregate Consumption:
Summarizes total consumption across all households for key appliances like TVs, 
fridges, and lights.
Visualizes the share of each appliance's contribution using a pie chart.
4. Analysis of Income Groups
Identify Low-Income Households:
Median monthly expenditure (monthly_expenses_qsel) is used to classify households 
into low- and high-income groups.
4. Reliability Impact on Appliance Consumption
Analyze Reliability Effects:
Compares electricity consumption for selected appliances (e.g., fridges, smartphones) 
under:
Unreliable Grid: Current consumption levels.
Reliable Grid: Estimated consumption under improved grid reliability.
Uses predefined reliability multipliers to simulate the increase in consumption under 
a reliable grid.
Visualize Reliability Impact:
Creates horizontal bar charts showing:
Current consumption levels (unreliable grid) in red.
Additional consumption potential (under a reliable grid) with hatched patterns in 
green.
5. Key Visualizations
Pie Chart:
Displays the percentage contribution of different appliances to aggregate household 
electricity consumption.
Bar Charts:
Highlights the consumption gap for selected appliances (e.g., fridges, smartphones) 
between unreliable and reliable grid scenarios.
