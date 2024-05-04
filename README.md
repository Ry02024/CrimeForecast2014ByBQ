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

-- 予測クエリ
#standardSQL
SELECT
  hour_of_day,
  day_of_week,
  primary_type,
  predicted_label
FROM
  ML.PREDICT(MODEL `your_project.your_dataset.crime_prediction_model`,
    (SELECT
      EXTRACT(HOUR FROM TIMESTAMP(timestamp)) AS hour_of_day,
      EXTRACT(DAYOFWEEK FROM TIMESTAMP(timestamp)) AS day_of_week,
      primary_type
     FROM
      `your_dataset.your_crime_table`
     WHERE
      TIMESTAMP(timestamp) BETWEEN '2014-07-01' AND '2014-12-31'
    ))

-- モデル評価のクエリ
WITH predictions AS (
  SELECT
    EXTRACT(HOUR FROM TIMESTAMP(timestamp)) AS hour_of_day,
    EXTRACT(DAYOFWEEK FROM TIMESTAMP(timestamp)) AS day_of_week,
    primary_type,
    predicted_label
  FROM
    ML.PREDICT(MODEL `your_project.your_dataset.crime_prediction_model`,
      (SELECT
        TIMESTAMP(timestamp),
        primary_type
       FROM
        `your_dataset.your_crime_table`
       WHERE
        TIMESTAMP(timestamp) BETWEEN '2014-07-01' AND '2014-12-31'
      ))
),
actual AS (
  SELECT
    EXTRACT(HOUR FROM TIMESTAMP(timestamp)) AS hour_of_day,
    EXTRACT(DAYOFWEEK FROM TIMESTAMP(timestamp)) AS day_of_week,
    primary_type,
    COUNT(*) AS num_crimes,
    IF(COUNT(*) > 10, 1, 0) AS actual_label
  FROM
    `your_dataset.your_crime_table`
  WHERE
    TIMESTAMP(timestamp) BETWEEN '2014-07-01' AND '2014-12-31'
  GROUP BY
    hour_of_day, day_of_week, primary_type
)
SELECT
  a.hour_of_day,
  a.day_of_week,
  a.primary_type,
  p.predicted_label,
  a.actual_label
FROM
  predictions p
JOIN
  actual a ON p.hour_of_day = a.hour_of_day
            AND p.day_of_week = a.day_of_week
            AND p.primary_type = a.primary_type

## コントリビューション

このプロジェクトへの貢献を歓迎します。貢献する前に、以下の手順をお読みください。

1. プロジェクトのフォークを作成します。
2. あなたのフォークで新しいブランチを作成します（`git checkout -b feature`）。
3. 変更をコミットします（`git commit -am 'Add some feature'`）。
4. ブランチにプッシュします（`git push origin feature`）。
5. 新しいプルリクエストを作成します。

貢献する際は、新機能の追加やバグ修正に関するテストが含まれていることを確認してください。また、すべてのコードは既存のコードスタイルに従う必要があります。

## ライセンス

このプロジェクトはMITライセンスのもとで公開されています。これにより、誰でも自由にこのプロジェクトを複製、修正、再配布することができますが、すべてのコピーまたは重要な部分に著作権表示とこの許可表示を含める必要があります。詳細については、[LICENSE](LICENSE) ファイルを参照してください。
