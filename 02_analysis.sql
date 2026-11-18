-- 1. Campaign scorecard. Aggregate numerator and denominator before computing rates.
SELECT c.campaign,c.channel, SUM(impressions) AS impressions,SUM(clicks) AS clicks,
       SUM(gross_orders) AS gross_orders,SUM(retained_orders) AS retained_orders,
       ROUND(SUM(spend_paise)/100.0,2) AS spend_inr,
       ROUND(SUM(net_sales_paise)/100.0,2) AS net_sales_inr,
       ROUND(100.0*SUM(clicks)/NULLIF(SUM(impressions),0),2) AS ctr_pct,
       ROUND(100.0*SUM(gross_orders)/NULLIF(SUM(clicks),0),2) AS conversion_pct,
       ROUND(SUM(spend_paise)/100.0/NULLIF(SUM(retained_orders),0),2) AS cost_per_retained_order_inr,
       ROUND(1.0*SUM(net_sales_paise)/NULLIF(SUM(spend_paise),0),2) AS net_roas
FROM campaign_day JOIN campaigns AS c USING(campaign_id)
GROUP BY c.campaign_id,c.campaign,c.channel ORDER BY net_roas DESC;

-- 2. Weekly channel trend. Weeks begin Monday; the window stays within each channel.
WITH weekly AS (
  SELECT date(day,'-6 days','weekday 1') AS week_start,channel,
         SUM(spend_paise) AS spend,SUM(net_sales_paise) AS net_sales,
         SUM(retained_orders) AS retained_orders
  FROM campaign_day JOIN campaigns USING(campaign_id) GROUP BY week_start,channel
), ratios AS (
  SELECT *,1.0*net_sales/NULLIF(spend,0) AS roas FROM weekly
)
SELECT week_start,channel,retained_orders,ROUND(spend/100.0,2) AS spend_inr,
       ROUND(roas,2) AS net_roas,
       ROUND(roas-LAG(roas) OVER (PARTITION BY channel ORDER BY week_start),2) AS wow_roas_change
FROM ratios ORDER BY week_start,channel;

-- 3. Budget diagnostic. Positive gap means the campaign delivers a greater share
-- of net sales than of spend in this sample. It is not a causal lift estimate.
WITH totals AS (
  SELECT campaign,SUM(spend_paise) AS spend,SUM(net_sales_paise) AS sales
  FROM campaign_day JOIN campaigns USING(campaign_id) GROUP BY campaign
), shares AS (
  SELECT campaign,100.0*spend/NULLIF(SUM(spend) OVER (),0) AS spend_share,
         100.0*sales/NULLIF(SUM(sales) OVER (),0) AS sales_share FROM totals
)
SELECT campaign,ROUND(spend_share,2) AS spend_share_pct,ROUND(sales_share,2) AS sales_share_pct,
       ROUND(sales_share-spend_share,2) AS gap_percentage_points FROM shares
ORDER BY gap_percentage_points DESC;
