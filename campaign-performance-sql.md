# Marketing campaign performance with SQL

Which campaigns generate the most sales per rupee after refunds, and where does the distribution of spend differ from the distribution of sales?

This SQLite project models six full weeks (2 March–12 April 2026) for four synthetic e-commerce campaigns across paid search and paid social. The dataset contains 168 campaign-days, 1,307 attributed orders and 1,229 retained orders. The generator is deterministic. No customer records or advertising accounts are involved.

## Findings

- **Cart reminder** had the strongest net ROAS at **4.87×**, with a cost of **₹298.61** per retained order.
- **Short-form prospecting** returned **0.85×** net sales per rupee of spend. Its gross purchase conversion rate was **0.81%**.
- **Cart reminder** produced **43.87%** of net sales on **29.50%** of spend. That gap makes it a candidate for a controlled budget test. Audience intent and the different roles of prospecting and retargeting limit direct comparisons.

## Reproduce

Use SQLite 3.25 or newer. Run these commands from this project folder. Use a dedicated database file because the build script replaces the demo tables on reruns.

```sh
sqlite3 campaign_demo.db < 01_build.sql
sqlite3 -header -column campaign_demo.db < 02_analysis.sql
```

## Method

Daily ad delivery and individual orders have different levels of detail. The `campaign_day` view groups orders by date and campaign before joining them to spend. A left join preserves days with no purchases. Currency is stored in integer paise, and queries convert amounts to rupees for display.

| Metric | Calculation |
| --- | --- |
| CTR | Total clicks ÷ total impressions |
| Purchase conversion | All attributed orders ÷ clicks |
| Cost per retained order | Spend ÷ orders remaining after refunds |
| Net ROAS | Sales after full refunds ÷ ad spend |
| Weekly change | This week’s net ROAS minus the previous week’s net ROAS for the same channel |

The demo attributes each order to one campaign on the same day. It assumes full refunds, excludes product costs and does not measure profit or incremental lift. Weekly results start on Monday.

## Query outputs

[Campaign scorecard](campaign-scorecard.csv) · [Weekly channel trends](weekly-channel-trend.csv) · [Budget diagnostic](budget-diagnostic.csv)
