#standardSQL
CREATE OR REPLACE MODEL `your_project.your_dataset.crime_prediction_model`
OPTIONS(model_type='logistic_reg') AS
SELECT
  primary_type,
  EXTRACT(HOUR FROM TIMESTAMP(timestamp)) AS hour_of_day,
  EXTRACT(DAYOFWEEK FROM TIMESTAMP(timestamp)) AS day_of_week,
  COUNT(*) AS num_crimes,
  IF(COUNT(*) > 10, 1, 0) AS label
FROM
  `your_dataset.your_crime_table`
WHERE
  TIMESTAMP(timestamp) BETWEEN '2014-01-01' AND '2014-06-30'
GROUP BY
  hour_of_day, day_of_week, primary_type;
