# CrimeForecast2014ByBQ

## プロジェクト概要
CrimeForecast2014は、2014年の犯罪データを用いて犯罪発生の予測モデルを構築し、その予測性能を評価するプロジェクトです。このプロジェクトは、BigQuery MLを利用してロジスティック回帰モデルを作成し、特に時間帯と曜日に焦点を当てています。

## モデルの目的
- 犯罪発生の予測精度を向上させる。
- 犯罪の時間帯と曜日のパターンを明らかにする。

## 使用データ
- 2014年1月から6月までの犯罪データ（訓練データ）
- 2014年7月から12月までの犯罪データ（テストデータ）

## モデルの構築と評価
- BigQuery MLを用いたロジスティック回帰モデルの訓練。
- 予測精度の評価とモデルの調整。

## 使い方
### データの準備
データは `bigquery-public-data` の犯罪データセットから取得しています。

### モデルの訓練と評価
以下のSQLクエリを実行して、モデルの訓練と予測を行います。

```sql
-- モデル訓練のクエリ
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

-- モデル評価のクエリ
SELECT
  hour_of_day,
  day_of_week,
  primary_type,
  predicted_label,
  actual_label
FROM
  ...
