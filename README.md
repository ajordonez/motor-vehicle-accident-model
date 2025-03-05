# NYC Motor Vehicle Accident Analysis

## Overview
This project analyzes **NYC motor vehicle accident data** from the last 10 years (Jan 2015- Dec 2024) to identify key factors influencing injury and fatality risks. Using **BigQuery, R, and logistic regression**, the analysis explores the impact of **borough, vehicle type, driver demographics, and license status** on accident outcomes. The findings can help insurers assess risk profiles more effectively.

In addition to the regression model, this project also includes an interactive heat map of collisions in NYC. The link to the heatmap:
https://public.tableau.com/app/profile/alejandro.ordonez/viz/motor_vehicle_heat_map/Sheet1?publish=yes

## Key Findings
- **Motorcycles have the highest injury/fatality risk**, while Manhattan has the lowest accident severity.
- **Sedans, SUVs, and taxis also increase the likelihood of injuries**, while borough-level differences play a role in accident outcomes.
- **Injury risk follows a U-shaped pattern with age**, being highest for younger and older drivers.
- **Unlicensed and permit drivers show lower reported injury rates**

## Technologies Used
- **BigQuery**: Data extraction and preprocessing from NYC Open Data.
- **R (RStudio)**: Data cleaning, transformations, and statistical modeling.
- **Jupyter Notebook**: Documentation, visualization, and final report presentation.

## Data Sources
The dataset comes from **NYC Open Data's motor vehicle accident records**, processed through BigQuery. Due to dataset size constraints (>1GB), the full dataset is not included here, but queries are provided to reproduce the analysis.

## Reproducibility
Due to the large dataset, full execution in Jupyter is not possible. However, the methodology is fully documented, and:
- **BigQuery SQL queries** allow users to extract the necessary data.
- **R scripts** for data cleaning and modeling are included.
- **Key outputs and visualizations** are provided for interpretation.

## Project Structure
```
├── cleaned_data/         #Cleaned CSV files created from the queries listed
├── notebooks/            #Jupyter Notebook with final report
├── scripts/              #R scripts for data processing and modeling
├── queries/              #SQL queries used in BigQuery used to create CSVs in cleaned_data/
├── tableau/              #Data visualization file for the heatmap
├── README.md             #Project documentation
```

## How to Use
1. **Run SQL queries in BigQuery** to extract relevant data.
2. **Process and clean data using the provided R scripts** in RStudio.
3. **Analyze results using logistic regression** to assess risk factors.
4. **Review the final findings in the Jupyter Notebook**.
5. **Interact with the heatmap in Tableau Public**.

## Next Steps
- Expand the model to include additional risk factors like **time of day and brand of vehicle**.
- Explore **interaction effects** between variables for deeper insights.
- Utilize regression model to make predictions
- Compare and contrast NYC post congestion pricing vs pre congestion pricing
- Implement Jupyter notebook and Google Cloud compatability to allow SQL to be used in the notebook

## Author
**Alejandro J. Ordonez** – Junior in Statistics & Quantitative Modeling and aspiring actuary.

---
Feel free to reach out if you have any questions or suggestions!

