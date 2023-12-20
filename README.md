# HR DATA ANALYSIS - SQL SERVER 2022 / POWER BI

HR DATA ANALYSIS - SQL SERVER 2022 / POWER BI

This comprehensive project delves extensively into the domain of data analysis, employing both SQL and Power BI tools to unveil critical insights within the realm of human resources. Through the creation of visually compelling dashboards, the project aims to present essential HR metrics, including but not limited to employee turnover, diversity statistics, recruitment effectiveness, and performance evaluations. These meticulously crafted dashboards serve as invaluable resources for HR professionals, empowering them with the information needed to make well-informed decisions and undertake strategic workforce planning. By leveraging the power of data analytics, this initiative contributes significantly to enhancing the overall efficiency and effectiveness of HR management within the company, fostering a data-driven approach to human resource decision-making.

## Data Cleaning & Analysis:
## Data Cleaning (Excel)
This was done on MySQL and Excel involving
- Data loading & inspection
- Handling missing values
- Data cleaning and analysis
- Adjust the data type in the columns of the data
- Adding new columns based on column calculations of other columns (birthdate and termdate)
``` excel
=IF(ISNUMBER(D2),D2,IF(LEN(D2)=9,DATE(RIGHT(D2,4),LEFT(D2,1),MID(D2,3,2)),DATE(RIGHT(D2,4),LEFT(D2,2),MID(D2,4,2))))
```

## Exploratory Data Analysis (SQL)
### Questions
1. What's the age distribution in the company?
2. What's the gender breakdown in the company?
3. How does gender vary across departments and job titles?
4. What's the race distribution in the company?
5. What's the average length of employment in the company?
6. Which department has the highest turnover rate?
7. What is the tenure distribution for each department?
8. How many employees work remotely for each department?
9. What's the distribution of employees across different states?
10. How are job titles distributed in the company?
11. How have employee hire counts varied over time?
    
### Findings 
1. There are more male employees than female or non-conforming employees.
2. The genders are fairly evenly distributed across departments. There are slightly more male employees overall.
3. Employees 50+ years old are the fewest in the company. Most employees are 31-40 years old. Then continued with the 21-30 and 41-50 age groups which have almost the same number of employees in this company
4. Caucasian employees are the majority in the company, followed by mixed race, black, Asian, Hispanic, and native Americans.
5. The average length of employment is 7 years.
6. Auditing has the highest turnover rate, followed by Legal, Research & Development and Training. Business Development & Marketing have the lowest turnover rates.
7. Employees tend to stay with the company for 6-8 years. Tenure is quite evenly distributed across departments.
8. About 25% of employees work remotely.
9. Most employees are in Ohio (14,788) followed distantly by Pennsylvania (930) and Illinois (730), Indiana (572), Michigan (569), Kentucky (375) and Wisconsin (321).
10. There are 182 job titles in the company, with Research Assistant II taking most of the employees (634) and Assistant Professor, Marketing Manager, Office Assistant IV, Associate Professor and VP of Training and Development taking the just 1 employee each.
11. Employee hire counts have increased over the years


### 1) Create New Schema 
### 2) Import Data to MySQL
- Right click on the schema that was created earlier
- Use import wizard to import data to hr schema
- Verify that the import worked:
```sql
SELECT * FROM hrdata;
```
## Qusetion to answer from the data
### 1) What's the age distribution in the company?
- age distribution
```sql
SELECT
 MIN(age) AS youngest,
 MAX(age) AS OLDEST
FROM hrdata;
```
- age group count
 ```sql
  SELECT age_group, count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age >= 21 AND age <= 30 THEN '21 to 30'
  WHEN age >= 31 AND age <= 40 THEN '31 to 40'
  WHEN age >= 41 AND age <= 50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group
 FROM hrdata
 WHERE year(termdate) > 2023  or termdate is null
 ) AS subquery
GROUP BY age_group
ORDER BY age_group;
```
- age group by gender
```sql
SELECT age_group, gender, count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age >= 21 AND age <= 30 THEN '21 to 30'
  WHEN age >= 31 AND age <= 40 THEN '31 to 40'
  WHEN age >= 41 AND age <= 50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group,
  gender
 FROM hrdata
 WHERE year(termdate) > 2023  or termdate is null
 ) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;
```
### 2) What's the gender breakdown in the company?
```sql
SELECT gender, COUNT(gender) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY gender
ORDER BY gender ASC;
```
### 3) How does gender vary across departments and job titles?
```sql
SELECT department, gender, count(gender) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY department, gender
ORDER BY department, gender ASC;
```

### 4) What is the number of employees in each job title?
```sql
SELECT  department, jobtitle, count(jobtitle) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY department, jobtitle
ORDER BY department, jobtitle ASC;
```
### 5) What's the race distribution in the company?
```sql
SELECT race, count(*) AS count
FROM hrdata
WHERE year(termdate) > curdate()  or termdate is null
GROUP BY race
ORDER BY count DESC;
```
### 6) What's the average length of employment in the company?
```sql
SELECT AVG(timestampdiff(year, newHiredate, termdate)) AS tenure
FROM hrdata
WHERE termdate IS NOT NULL AND termdate <= curdate();
```
### 7) Which department has the highest turnover rate?
- get total count
- get terminated count
- terminated count/total count
```sql
WITH turnover_data AS (
  SELECT 
    department,
    count(*) AS total_count,
    SUM(CASE
      WHEN termdate IS NOT NULL AND termdate <= curdate() 
        THEN 1 
        ELSE 0
    END) AS terminated_count
  FROM hrdata
  GROUP BY department
)
SELECT 
  department,
  total_count,
  terminated_count,
  (ROUND((CAST(terminated_count AS FLOAT) / total_count), 3)) * 100 AS turnover_rate
FROM turnover_data
ORDER BY turnover_rate DESC;
```
### 8) What is the tenure distribution for each department?
```sql
SELECT department, AVG(timestampdiff(year, hire_date, termdate)) AS tenure
FROM hrdata
WHERE termdate IS NOT NULL AND termdate <= curdate() 
GROUP BY department 
order by tenure desc;
```
### 9) How many employees work remotely for each department?
```sql
SELECT location, count(*) as count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY location;
```
### 10) What's the distribution of employees across different states? 
```sql
SELECT  location_state, count(*) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY location_state
ORDER BY count DESC;
```
### 11) How have employee hire counts varied over time?
- calculate hires
- calculate terminations
- (hires-terminations)/hires percent hire change
```sql
WITH hire_data AS (
  SELECT 
    YEAR(newHiredate) AS hire_year,
    COUNT(*) AS hires,
    SUM(CASE
      WHEN termdate IS NOT NULL  THEN 1
      ELSE 0
    END) AS terminations
  FROM hrdata
  GROUP BY YEAR(newHiredate)
)
SELECT
  hire_year,
  hires,
  terminations,
  hires - terminations AS net_change,
  (ROUND(CAST(hires - terminations AS FLOAT) / hires, 3)) * 100 AS percent_hire_change
FROM hire_data
ORDER BY percent_hire_change ASC;
```

  
## Data Visualization(PowerBI): 
- Import the data to PowerBI
- Import the EDA results that were done in MySQL earlier
- Create an age column by calculating with the birthdate column
- Create a measure to calculate total employees, working employees, and retired employees
