# Project 2: NDA HbA1c Analyser Issue, England, Jan 2024 - Mar 2025

Exploratory SQL and Power BI analysis of a National Diabetes Audit (NDA) file
on newly diagnosed type 2 diabetes or non-diabetic hyperglycaemia counts, in
practices served by laboratories affected by an HbA1c analyser calibration
issue and in a control group.

## What it shows
- Change in newly diagnosed counts versus the same month a year earlier,
  affected versus control practices (national, regional and ICB level)
- A SQL workflow: import, cleaning, conversion of text to numbers, grouped
  queries and export to Power BI
- Earlier dashboard pages labelled "all practice groups" are kept as a
  record of my first look at the data and are not for comparison

## Tools
SQL Server Management Studio and Microsoft Power BI

## Limitations
- Values are counts of newly diagnosed people, rounded to the nearest 5,
  not HbA1c results or measures of care quality
- Small ICBs have very small counts, so their percentages are unstable
- 2025 covers January to March only
- Descriptive only; no causal claims, and individual misdiagnoses cannot
  be identified
- A deprivation link covers only 21 of 42 ICBs and is exploratory

## Data source
NHS England, National Diabetes Audit HbA1c Analyser Issue Detailed Analysis
File (published 9 July 2026); English Indices of Deprivation 2025 (MHCLG).
Raw data are not included.
