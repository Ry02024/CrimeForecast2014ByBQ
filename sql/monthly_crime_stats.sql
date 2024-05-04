#standardSQL
SELECT
  EXTRACT(YEAR FROM report_date) AS year,
  EXTRACT(MONTH FROM report_date) AS month,
  category,
  COUNT(*) AS incidents
FROM
  `bigquery-public-data.austin_crime.crime`
GROUP BY
  year, month, category
ORDER BY
  year, month, category;
