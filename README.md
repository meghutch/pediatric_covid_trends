# pediatric_covid_trends
Scripts to process national pediatric cases, hospitalizations, and death trends

This repository contains code to process and plot the national trends of pediatric COVID-19 cases. Data was abstracted from the [**American Academy of Pediatrics's COVID-19 report**](https://services.aap.org/en/pages/2019-novel-coronavirus-covid-19-infections/children-and-covid-19-state-level-data-report/). Specifically, data was abstracted from Appendix Tables 2A:3B from their [**State Data Report 11.12.20 FINAL**](https://downloads.aap.org/AAP/PDF/AAP%20and%20CHA%20-%20Children%20and%20COVID-19%20State%20Data%20Report%2011.12.20%20FINAL.pdf) (also found in this repo's **raw_data** folder).

Additionally, national trends plotted with data publically available from HealthData.gov(https://healthdata.gov/dataset/covid-19-reported-patient-impact-and-hospital-capacity-facility), are plotted in our ```National Pediatric Trends - HealthData.gov.Rmd``` file

**Note about AAP Analysis:**

Attempts to calculate the weekly cumulative hospitalizations (by calculating Cumulative Cases from Week 2 - Cumulative Cases from Week 1) with the AAP dataset proved troublesome as there could have been lags or corrections to data collection efforts that weren't corrected in subsequent weeks, thus leading to negative counts. The R script does not account for this problem. 


## Respository Directory

    ├── raw_data  <- txt files containing the raw count data copied from the AAP's state report 
    
    |── R

        ├── national_data.R <- script to process raw AAP data and plot trends
        
    |── processed_data <- clean csv files of the AAP's pediatric covid data

    ├── README.md  <- README for quick introduction to respository
    
    ├── National Pediatric Trends - HealthData.gov.Rmd <- markdown file to process HealthData.gov pediatric data 

*Note: README directory structure adapted from [Cookiecutter-data-science](https://drivendata.github.io/cookiecutter-data-science/)*
