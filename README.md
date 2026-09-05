# Workforce Planning & Attrition Analytics Dashboard

## Project Overview

This project is an end-to-end **Workforce Analytics solution** built using **SQL, Python, and Power BI**. It analyzes employee attrition, customer deployments, resource rotations, bench status, and customer budget utilization.

The goal of this project is to help leadership and resource managers make data-driven decisions around:

- Employee retention
- Workforce planning
- Bench reduction
- Customer deployment efficiency
- Budget monitoring
- Proactive staffing actions

This project uses **synthetic data** created to simulate a real-world consulting/IT services workforce environment.

---

## Business Problem

In a services-based organization, leadership needs visibility into workforce health and customer delivery operations.

Key business questions include:

- Which employees are leaving the organization?
- Which customers, grades, skills, or locations have higher attrition?
- Which employees are currently deployed versus on bench?
- How long have employees been on bench?
- Which employees have not been rotated recently?
- Which assignments are ending soon and may increase bench count?
- Which customers are close to budget overrun?
- Which employees are at higher attrition risk?

This project answers these questions through SQL-based analysis, Python feature engineering, and an interactive Power BI dashboard.

---

## Key Features

- Attrition analysis by grade, skill, customer, location, and tenure
- Monthly attrition trend analysis
- Deployment status tracking across customers and projects
- Bench count and bench aging analysis
- Rotation frequency analysis
- Upcoming assignment ending analysis
- Customer budget utilization and burn rate tracking
- Project-level budget overrun analysis
- Employee attrition risk scoring using Python
- Interactive Power BI dashboard for leadership reporting

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| SQL | Data modeling, storage, and analytical queries |
| Python | Data cleaning, feature engineering, and insight generation |
| Pandas | Data manipulation and transformation |
| Matplotlib / Seaborn | Exploratory data visualization |
| Power BI | Interactive dashboard and reporting |
| GitHub | Version control and project documentation |

---

## Project Architecture

```text
Raw Data
   |
   v
SQL Database
   |
   v
SQL Queries for KPIs and Analysis
   |
   v
Python for Cleaning, Feature Engineering, and Risk Scoring
   |
   v
Power BI Data Model
   |
   v
Interactive Workforce Analytics Dashboard

workforce-analytics-dashboard/
│
├── data/
│   ├── employees.csv
│   ├── customers.csv
│   ├── projects.csv
│   ├── assignments.csv
│   ├── bench_history.csv
│   ├── budgets.csv
│   └── processed/
│       ├── employee_features.csv
│       ├── current_bench.csv
│       ├── budget_summary.csv
│       ├── utilization.csv
│       └── recent_rotations.csv
│
├── sql/
│   ├── create_tables.sql
│   ├── insert_data.sql
│   └── workforce_queries.sql
│
├── notebooks/
│   └── workforce_analysis.ipynb
│
├── powerbi/
│   └── workforce_dashboard.pbix
│
├── docs/
│   ├── data_dictionary.md
│   └── screenshots/
│       ├── executive_summary.png
│       ├── attrition_analysis.png
│       ├── deployment_bench_analysis.png
│       └── customer_budget_analysis.png
│
├── README.md
└── requirements.txt
