-- SQLite 3.25 or later. Run in a new database or rerun on this demo database.
PRAGMA foreign_keys = ON;
BEGIN;
DROP VIEW IF EXISTS campaign_day;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS delivery;
DROP TABLE IF EXISTS campaigns;

CREATE TABLE campaigns (
  campaign_id INTEGER PRIMARY KEY,
  campaign TEXT NOT NULL UNIQUE,
  channel TEXT NOT NULL
);
CREATE TABLE delivery (
  day TEXT NOT NULL,
  campaign_id INTEGER NOT NULL REFERENCES campaigns,
  impressions INTEGER NOT NULL CHECK (impressions >= 0),
  clicks INTEGER NOT NULL CHECK (clicks BETWEEN 0 AND impressions),
  spend_paise INTEGER NOT NULL CHECK (spend_paise >= 0),
  PRIMARY KEY (day, campaign_id)
);
CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  day TEXT NOT NULL,
  campaign_id INTEGER NOT NULL,
  value_paise INTEGER NOT NULL CHECK (value_paise > 0),
  refunded INTEGER NOT NULL CHECK (refunded IN (0,1)),
  FOREIGN KEY (day,campaign_id) REFERENCES delivery(day,campaign_id)
);

INSERT INTO campaigns VALUES
 (1,'High-intent search','Paid search'), (2,'Category discovery','Paid search'),
 (3,'Short-form prospecting','Paid social'), (4,'Cart reminder','Paid social');

-- Six weeks of illustrative daily delivery. All monetary amounts are integer paise.
WITH RECURSIVE calendar(n) AS (
  VALUES(0) UNION ALL SELECT n+1 FROM calendar WHERE n<41
), traffic AS (
  SELECT n,campaign_id,
         3200 + campaign_id*890 + ((n*379 + campaign_id*127)%1900) AS impressions,
         CASE campaign_id WHEN 1 THEN 43 WHEN 2 THEN 26 WHEN 3 THEN 16 ELSE 32 END AS ctr_per_mille,
         CASE campaign_id WHEN 1 THEN 2200 WHEN 2 THEN 1800 WHEN 3 THEN 1200 ELSE 1500 END AS cpc
  FROM calendar CROSS JOIN campaigns
), clicks_by_day AS (
  SELECT *, CAST(impressions*(ctr_per_mille + n%5 - 2)/1000 AS INTEGER) AS clicks
  FROM traffic
)
INSERT INTO delivery
SELECT date('2026-03-02','+'||n||' days'),campaign_id,impressions,clicks,
       clicks*(cpc+((n*17)%150))
FROM clicks_by_day;

-- A click can generate at most one attributed order in this dataset. Keep zero-order days.
WITH RECURSIVE slots(k) AS (
  VALUES(1) UNION ALL SELECT k+1 FROM slots WHERE k<24
), daily_orders AS (
  SELECT day,campaign_id, CAST(julianday(day)-julianday('2026-03-02') AS INTEGER) AS n,
         CAST(clicks * (CASE campaign_id WHEN 1 THEN 63 WHEN 2 THEN 27
                        WHEN 3 THEN 14 ELSE 58 END) /1000 AS INTEGER) AS demand
  FROM delivery
)
INSERT INTO orders(day,campaign_id,value_paise,refunded)
SELECT day,campaign_id, (650 + ((n*73+k*97+campaign_id*337)%1600))*100,
       ((n+3*k+campaign_id)%17=0)
FROM daily_orders JOIN slots ON k<=demand
WHERE NOT (n%13=0 AND campaign_id=3)
ORDER BY day,campaign_id,k;

-- Reduce the orders to the delivery grain BEFORE joining so spend is counted once.
CREATE VIEW campaign_day AS
WITH attributed AS (
  SELECT day,campaign_id,COUNT(*) AS gross_orders,
         SUM(1-refunded) AS retained_orders,
         SUM(CASE WHEN refunded=0 THEN value_paise ELSE 0 END) AS net_sales_paise
  FROM orders GROUP BY day,campaign_id
)
SELECT d.*,COALESCE(a.gross_orders,0) AS gross_orders,
       COALESCE(a.retained_orders,0) AS retained_orders,
       COALESCE(a.net_sales_paise,0) AS net_sales_paise
FROM delivery AS d LEFT JOIN attributed AS a USING(day,campaign_id);
COMMIT;
