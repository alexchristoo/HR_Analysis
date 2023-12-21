select * from hrdata;
select count(distinct id) from hrdata;
select count(id) from hrdata WHERE year(termdate) > 2023  or termdate is null;


SELECT
 MIN(age) AS youngest,
 MAX(age) AS OLDEST
FROM hrdata;

-- age dist 	 	
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

-- age dist by gender
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

-- gender distribution
SELECT gender, COUNT(gender) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY gender
ORDER BY gender ASC;

-- department dist
SELECT department, count(id) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY department
ORDER BY count(id) desc;

-- department and gender dist
SELECT department, gender, count(gender) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY department, gender
ORDER BY department, gender ASC;

-- job title dist
SELECT  department, jobtitle, count(jobtitle) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY department, jobtitle
ORDER BY department, jobtitle ASC;

-- race dist
SELECT race, count(*) AS count
FROM hrdata
WHERE year(termdate) > curdate()  or termdate is null
GROUP BY race
ORDER BY count DESC;

-- avg tenure
SELECT AVG(timestampdiff(year, newHiredate, termdate)) AS tenure
FROM hrdata
WHERE termdate IS NOT NULL AND termdate <= curdate();

-- calculating turnover rate
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

-- tenure dist each department
SELECT department, AVG(timestampdiff(year, hire_date, termdate)) AS tenure
FROM hrdata
WHERE termdate IS NOT NULL AND termdate <= curdate() 
GROUP BY department 
order by tenure desc;

-- location dist
SELECT location, count(*) as count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY location;

-- state dist
SELECT  location_state, count(*) AS count
FROM hrdata
WHERE year(termdate) > 2023  or termdate is null
GROUP BY location_state
ORDER BY count DESC;

-- hire counts rate each year
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
