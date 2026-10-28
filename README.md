

# Medical Appointment No-Shows Analysis
![Dashboard Overview](Dashboard/Dashboard.png)
## Project Overview

Medical appointment no-shows are an important operational challenge for healthcare providers. Missed appointments can reduce the effective use of healthcare resources and make appointment scheduling less efficient.

This project uses SQL and healthcare appointment data to investigate no-show patterns, analyze patient appointment history, and develop rule-based risk categories that can support further investigation and operational decision-making.

The project demonstrates practical skills in data cleaning, exploratory data analysis, SQL querying, window functions, and healthcare analytics.

## Business Questions

This project explores the following questions:

- How frequently do patients miss their scheduled appointments?
- How is appointment lead time associated with no-show behavior?
- How can appointment patterns be analyzed across patient groups, dates, and neighborhoods?
- What information can previous appointment history provide about patient attendance?
- How can SQL-based business rules categorize appointments into different risk groups?

## Dataset

**Source:** [Medical Appointment No Shows — Kaggle](https://www.kaggle.com/datasets/joniarroba/noshowappointments/data)

The original dataset contains 110,527 appointment records and 14 columns describing appointment dates, patient characteristics, medical conditions, SMS reminders, and attendance status.

The cleaned dataset contains 110,521 records after removing six records that met the project's data-cleaning exclusion criteria.

## Tools and Technologies

- **MySQL:** Data cleaning, exploratory analysis, aggregations, window functions, and risk classification.
- **SQL:** Data transformation, validation, and analytical queries.
- **CSV / Excel:** Reviewing and organizing the datasets and exported analysis results.
- **GitHub:** Project documentation, version control, and portfolio presentation.
- **Power BI:** Dashboard visualization.

## Project Workflow

### 1. Data Cleaning

The cleaning process included:

- Renaming columns for improved consistency and readability.
- Converting date fields into appropriate data types.
- Calculating appointment lead time in days.
- Removing records with an invalid age of `-1`.
- Removing records with negative appointment lead time.

The resulting cleaned dataset contains 110,521 records.

### 2. Exploratory Data Analysis

SQL queries were used to investigate appointment attendance patterns across different dimensions, including:

- Appointment dates and scheduling lead time.
- Patient age groups.
- SMS reminder status.
- Neighborhoods.
- Other available patient and appointment characteristics.

Aggregations were used to compare attendance outcomes across categories.

### 3. Patient Appointment History

Window functions were used to derive historical appointment features for individual patients, including:

- Number of previous appointments.
- Number of previous no-shows.
- Historical no-show rate.

These features provide additional context for analyzing appointments beyond the current appointment's characteristics.

### 4. Rule-Based Risk Classification

A SQL view named `v_appointment_risk` was created to categorize appointments into four groups:

- **High Risk**
- **Medium Risk**
- **Low Risk**
- **New Patient - Monitor**

The resulting risk-analysis dataset was exported to `V_Appointment_Risk.csv`.

These categories are based on the SQL rules defined in the project. They represent a rule-based analytical classification, not a trained or validated machine learning prediction model.

## Key Findings

- The cleaned dataset contains **110,521 appointments**.
- There are **22,314 no-show records**, representing approximately **20.19%** of the cleaned dataset.
- There are **88,207 attended appointments**.
- Appointment lead time ranges from 0 to 179 days in the cleaned dataset.
- The risk-analysis output contains four appointment categories and covers all 110,521 cleaned records.

### Risk Category Distribution

| Risk Category | Appointments |
|---|---:|
| New Patient - Monitor | 62,298 |
| High Risk | 22,188 |
| Low Risk | 17,184 |
| Medium Risk | 8,851 |
| **Total** | **110,521** |

## Recommendations

Based on the project's analytical approach:

1. Investigate whether longer appointment lead times are associated with higher no-show rates.
2. Review attendance patterns across patient groups and neighborhoods to identify areas that may need further investigation.
3. Consider patient appointment history when designing attendance-monitoring workflows.
4. Evaluate reminder and follow-up strategies using observed attendance patterns and measurable outcomes.
5. Validate the rule-based risk categories against actual attendance outcomes before using them to guide operational interventions.

These recommendations are intended to support further analysis. The risk categories should not be interpreted as clinically validated predictions.

## Project Structure

```text
medical-appointment-no-shows-analysis/
│
├── README.md
├── SQL/
│   └── Medical_Appointment_MySQL.sql
├── Data/
│   ├── Medical_Appointment.csv
│   └── V_Appointment_Risk.csv
└── Dashboard/
    ├── Hospital_No_Show_Dashboard.pbix
    └── Dashboard_Screenshot.png
```

- **`SQL/`** — SQL scripts for data cleaning, exploratory analysis, patient history analysis, and risk classification.
- **`Data/`** — Cleaned appointment data and exported risk-analysis results.
- **`Dashboard/`** — The Power BI dashboard file (`.pbix`) and a screenshot of the project.


## How to Explore the Project

1. Download the original dataset from Kaggle and review its terms of use.
2. Import the dataset into MySQL.
3. Review the SQL script before executing it.
4. Run the cleaning and analysis queries on a copy of the original data.
5. Review the patient-history calculations and the `v_appointment_risk` view.
6. Explore the exported risk-analysis results and dashboard.

**Requirements:** MySQL 8.0 or later is recommended because the script uses common table expressions and window functions.

**Important:** The SQL script includes data-modification statements such as `ALTER TABLE` and `DELETE`. Run it on a working copy of the dataset rather than your only copy of the original data.

## Limitations

- The analysis identifies associations and patterns; it does not establish causation.
- The risk categories are based on manually defined SQL rules and have not been established as a validated prediction model.
- Historical appointment features should be calculated carefully to avoid using information that would not have been available at the time of the appointment.
- Data redistribution must comply with the original dataset's licensing terms.

## Author

**Loay Mohamed**

This project is part of my portfolio in healthcare analytics, with a focus on applying data analysis and SQL to real-world healthcare operational questions.
