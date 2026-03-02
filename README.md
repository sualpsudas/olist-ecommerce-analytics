# Olist E-Commerce Analytics — SQL + Python

End-to-end business analytics on a real Brazilian e-commerce dataset.
**30 business questions across 3 difficulty levels**, answered with SQL and visualized with Python.

---

## Dataset

[Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — Kaggle &nbsp;·&nbsp; ~100,000 orders &nbsp;·&nbsp; 9 relational tables &nbsp;·&nbsp; 2016–2018

| Table | Description |
|-------|-------------|
| `orders` | Order lifecycle and timestamps |
| `order_items` | Products, prices, sellers per order |
| `order_payments` | Payment type and value |
| `order_reviews` | Customer review scores and comments |
| `customers` | Customer location data |
| `products` | Product dimensions and category |
| `sellers` | Seller location data |
| `geolocation` | Brazilian zip code coordinates |
| `product_category_name_translation` | PT → EN category names |

---

## Project Structure

```
olist-ecommerce-analytics/
├── sql/
│   ├── 01_basic.sql           # Q1–Q10  — GROUP BY, JOIN, DISTINCT, subquery, UNION
│   ├── 02_intermediate.sql    # Q11–Q20 — CTE, window functions, ROW_NUMBER, LEAD, moving avg
│   └── 03_advanced.sql        # Q21–Q30 — RFM, cohort, gaps & islands, duplicate detection, CLV
├── notebooks/
│   ├── 00_setup.ipynb         # Download data + build SQLite DB
│   ├── 01_basic_analysis.ipynb
│   ├── 02_intermediate_analysis.ipynb
│   └── 03_advanced_analysis.ipynb
├── images/                    # 28 charts generated from all 30 questions
├── src/
│   └── db_utils.py            # SQLite connection + query helpers
└── requirements.txt
```

---

## 30 Business Questions

### Basic — `GROUP BY · JOIN · DISTINCT · LEFT JOIN · HAVING · Subquery · UNION`

| # | Business Question | SQL Concept |
|---|-------------------|-------------|
| Q1 | What are the top product categories by order volume? | `GROUP BY`, `ORDER BY` |
| Q2 | What is the distribution of order statuses? | `GROUP BY`, window `COUNT` |
| Q3 | Which Brazilian states have the most customers? | `COUNT DISTINCT`, `GROUP BY` |
| Q4 | How does average order value vary by payment type? | `AVG`, `SUM`, `GROUP BY` |
| Q5 | Which categories have the highest customer review scores? | Multi-table `JOIN`, `HAVING` |
| Q6 | How many customers are repeat buyers? | `DISTINCT` + scalar subquery |
| Q7 | What percentage of orders are missing a review? | `LEFT JOIN`, `NULL` check |
| Q8 | Which categories have both high volume AND high satisfaction? | `HAVING` with multiple conditions |
| Q9 | Which products are priced above their category average? | Correlated subquery |
| Q10 | Which states appear as both customer and seller locations? | `UNION ALL`, `IN` subquery |

### Intermediate — `CTE · RANK · DENSE_RANK · ROW_NUMBER · LEAD · Cumulative Sum · Moving Average`

| # | Business Question | SQL Concept |
|---|-------------------|-------------|
| Q11 | What does monthly revenue look like — best and worst months? | `CTE`, `RANK()` |
| Q12 | How does actual delivery time compare to estimated? | `JULIANDAY`, `CASE WHEN` |
| Q13 | What are the top 3 best-selling products in each category? | `RANK()`, `PARTITION BY` |
| Q14 | Do the top 10% of sellers drive a disproportionate share of revenue? | `NTILE()`, `CTE` |
| Q15 | Do customers order more on weekdays or weekends? | `STRFTIME`, window `COUNT` |
| Q16 | What is the first order per customer? (deduplication pattern) | `ROW_NUMBER()` |
| Q17 | What is the difference between RANK and DENSE_RANK in practice? | `RANK()` vs `DENSE_RANK()` |
| Q18 | What does cumulative revenue look like over time? | `SUM() OVER (ORDER BY)` |
| Q19 | How does each month's revenue compare to the next month? | `LEAD()` |
| Q20 | What is the 3-month moving average of order volume? | `AVG() OVER (ROWS BETWEEN)` |

### Advanced — `RFM · Cohort · Gaps & Islands · YoY · Pivot · CLV · Duplicate Detection`

| # | Business Question | SQL Concept |
|---|-------------------|-------------|
| Q21 | How can we segment customers using RFM scoring? | `CTE` chain, `NTILE`, `CASE WHEN` |
| Q22 | What does customer retention look like across monthly cohorts? | Cohort `CTE`, `JOIN` |
| Q23 | Does late delivery significantly impact review scores? | `CASE WHEN`, Python t-test |
| Q24 | How can we rank sellers with a composite performance score? | `NTILE`, weighted scoring |
| Q25 | Which product categories show the strongest MoM revenue growth? | `LAG()`, `PARTITION BY` |
| Q26 | Which orders have duplicate reviews? How do we clean them? | `ROW_NUMBER` deduplication |
| Q27 | Which customers churned (60+ day gap) and came back? | Gaps & Islands, `LAG()` |
| Q28 | What is the year-over-year revenue growth by category? | `LAG()`, YoY pattern |
| Q29 | How does payment method usage break down by month? (pivot) | Conditional aggregation pivot |
| Q30 | Who are the highest-value customers by CLV score? | Multi-CTE, `NTILE`, CLV |

---

## Visualizations

### Basic Analysis

| | |
|---|---|
| ![Q1](images/q1_top_categories.png) | ![Q2](images/q2_order_status.png) |
| **Q1** — Top 15 product categories by order volume | **Q2** — 96.5% of orders are successfully delivered |
| ![Q4](images/q4_payment_analysis.png) | ![Q5](images/q5_review_by_category.png) |
| **Q4** — Credit card dominates both volume and total revenue | **Q5** — Category satisfaction: green = above 4.0, red = below |
| ![Q8](images/q8_high_vol_high_sat.png) | ![Q6](images/q6_repeat_buyers.png) |
| **Q8** — Only 21 categories have both high volume AND high scores | **Q6** — Just 3.1% of customers placed more than one order |

**Key insights:**
- **Q1** — Bed & bath leads on volume, but don't confuse volume with value — electronics has fewer orders yet a much higher average ticket price.
- **Q2** — 97% delivery success rate; the 0.6% cancellation rate skews toward boleto payments that expire before fulfilment.
- **Q3** — São Paulo alone accounts for ~42% of all customers. The top 3 states (SP, RJ, MG) cover ~66% of total demand.
- **Q4** — Credit card orders average R$163 — 2.5× more than voucher orders (R$66). Brazilian installment payments (parcelamento) unlock larger purchases on credit.
- **Q5** — Commodity categories (books, tools) consistently outscore fashion and electronics. Expectation mismatch — not product quality — is the main driver of low ratings.
- **Q6** — Only ~3% of customers ever place a second order. Repeat purchase rate is the single most important growth lever the platform hasn't cracked.
- **Q7** — Just 0.8% of orders are missing a review — Olist's automated request emails are unusually effective.
- **Q8** — Very few categories land in the top quartile for both volume *and* satisfaction. That intersection is the sweet spot for marketplace expansion.
- **Q9** — Products priced 2× their category average aren't necessarily overpriced — they often serve a niche. Low score + high price is the flag to investigate.
- **Q10** — SP, RJ, MG dominate both buyer and seller rankings. Geographic concentration creates efficiency but also fragility — disruptions in SP hit both supply and demand.

---

### Intermediate Analysis

| | |
|---|---|
| ![Q11](images/q6_monthly_revenue.png) | ![Q18](images/q18_cumulative_revenue.png) |
| **Q11** — Revenue peaked in November 2017 ($1.15M) — Black Friday effect | **Q18** — Cumulative revenue crossed $15M by end of dataset |
| ![Q20](images/q20_moving_average.png) | ![Q17](images/q17_rank_vs_dense_rank.png) |
| **Q20** — 3-month moving average smooths out seasonal spikes | **Q17** — RANK() vs DENSE_RANK(): how tie handling differs in practice |
| ![Q19](images/q19_lead_mom_change.png) | ![Q14](images/q9_seller_concentration.png) |
| **Q19** — Month-on-month expected change using LEAD() | **Q14** — Top 10% of sellers generate 67.6% of all revenue |

**Key insights:**
- **Q11** — November 2017 is the single highest revenue month (R$1.15M) — Black Friday. Seasonality is predictable: Q4 spikes, Q1 dips.
- **Q12** — ~8% of orders arrive later than estimated. Those late orders average a score of **2.57** vs **4.29** for on-time — a 1.7-point gap on a 5-point scale.
- **Q13** — Within most categories, the top 3 products capture a disproportionate share of orders. A handful of SKUs drive most category revenue.
- **Q14** — The top 10% of sellers (just ~310 out of 3,095) generate **67.6% of total revenue** — more extreme than the classic 80/20 rule. Losing a few top sellers has outsized consequences.
- **Q15** — 77% of orders are placed on weekdays, peaking at lunchtime and early evening. Direct implications for ad scheduling and support staffing.
- **Q16** — ROW_NUMBER() deduplication is one of the most common SQL interview patterns. In Olist, customer_id and customer_unique_id can diverge — always clarify grain before aggregating.
- **Q17** — RANK() leaves gaps after ties (1, 2, 2, 4); DENSE_RANK() doesn't (1, 2, 2, 3). Use DENSE_RANK() for top-N labelling; RANK() when position should reflect how many records scored higher.
- **Q18** — The cumulative revenue curve accelerates through 2017 and starts flattening in early 2018 — visible evidence of growth phase followed by market maturation.
- **Q19** — LEAD() compares each row to its successor without a self-join. November's spike makes December's MoM look negative even though December was a healthy month in absolute terms.
- **Q20** — A 3-month moving average smooths out seasonal spikes and makes the underlying trend visible. The right window balances responsiveness with smoothness.

---

### Advanced Analysis

| | |
|---|---|
| ![Q22](images/q12_cohort_retention.png) | ![Q21](images/q11_rfm_segmentation.png) |
| **Q22** — Cohort retention heatmap: most customers don't return after month 0 | **Q21** — RFM segmentation: 14,311 Champions vs 3,697 Lost customers |
| ![Q23](images/q13_delivery_vs_score.png) | ![Q27](images/q27_order_gaps.png) |
| **Q23** — Late delivery cuts avg score from 4.29 → 2.57 (p < 0.0001) | **Q27** — Gaps & Islands: 1,192 purchase gaps over 60 days detected |
| ![Q29](images/q29_payment_pivot.png) | ![Q30](images/q30_clv_quartiles.png) |
| **Q29** — SQL pivot: credit card usage grows consistently month over month | **Q30** — CLV quartiles: top 25% of repeat customers are worth 3× more |

**Key insights:**
- **Q21** — Most customers land in the low-R, low-F, low-M bucket — bought once, a while ago, spent little. The Champions segment is small but drives outsized revenue. RFM tells you *where* to focus retention spend.
- **Q22** — Month-2 retention is under 5%. Cohort analysis makes this visible in a way aggregate metrics hide — overall order volume can look healthy even as retention deteriorates.
- **Q23** — Late deliveries generate a disproportionate share of 1-star reviews. Fixing the 8.1% of late orders is the **highest-ROI lever** for improving the overall platform rating.
- **Q24** — A composite score (volume + satisfaction + speed) surfaces sellers that excel across all dimensions. Top composite scorers are candidates for premium placement; bottom scorers for intervention.
- **Q25** — Category-level MoM growth separates seasonal spikes from structural acceleration. Categories with *consistent* positive MoM growth are the ones worth expanding seller supply in.
- **Q26** — In payment data, the same order_id intentionally has multiple rows (installments). Always understand *why* duplicates exist before removing them.
- **Q27** — True customer reactivation after a 60+ day gap is rare on Olist, confirming the low repeat-purchase rate from Q6. The Gaps & Islands pattern is reusable for any inactive-then-active detection problem.
- **Q28** — 2017 vs 2016 YoY growth looks enormous because 2016 covers only H2 — the platform was newer. 2018 data is truncated at mid-year. Always validate date range completeness before reporting YoY figures.
- **Q29** — Credit card consistently represents 70%+ of monthly payment volume. Conditional aggregation (CASE WHEN inside SUM/COUNT) is more portable than database-specific PIVOT syntax.
- **Q30** — The top CLV quartile averages R$382 vs R$43 for the bottom — a 9× gap. CLV scoring lets you prioritise who gets discounts or win-back campaigns rather than spending retention budget uniformly.

---

## SQL Techniques Demonstrated

| Technique | Questions |
|-----------|-----------|
| `GROUP BY` + `ORDER BY` + `HAVING` | Q1–Q5, Q8 |
| Multi-table `JOIN` | Q1, Q5, Q12, Q21–Q25 |
| `LEFT JOIN` + `NULL` check | Q7 |
| `DISTINCT` | Q3, Q6 |
| Scalar / correlated subquery | Q6, Q9, Q10 |
| `UNION` / `UNION ALL` | Q10 |
| `CASE WHEN` | Q2, Q15, Q23, Q29 |
| `CTE` (Common Table Expressions) | Q11, Q14, Q16–Q30 |
| `RANK()` | Q11, Q13 |
| `DENSE_RANK()` | Q17 |
| `ROW_NUMBER()` | Q16, Q26 |
| `NTILE()` | Q14, Q21, Q24, Q30 |
| `LAG()` | Q25, Q27, Q28 |
| `LEAD()` | Q19 |
| `SUM() OVER` (cumulative) | Q18 |
| `AVG() OVER ROWS BETWEEN` (moving avg) | Q20 |
| `JULIANDAY()` date arithmetic | Q12, Q22, Q27, Q30 |
| `STRFTIME()` date formatting | Q11, Q15, Q22, Q25 |
| Conditional aggregation (SQL pivot) | Q29 |
| Gaps & Islands pattern | Q27 |
| YoY comparison pattern | Q28 |
| Customer Lifetime Value (CLV) | Q30 |
| Statistical significance test (Python) | Q23 |

---

## Key Findings

| Finding | Value |
|---------|-------|
| Top product category | `bed_bath_table` |
| Order fulfillment rate | 96.5% |
| Revenue peak | Nov 2017 — $1,153,528 (Black Friday) |
| Total cumulative revenue | $15,422,462 |
| Avg delivery vs estimate | Arrives **11.2 days early** (actual: 12.6d vs estimated: 23.7d) |
| Repeat customer rate | **3.1%** of customers placed more than one order |
| Seller concentration | Top **10%** of sellers → **67.6%** of total revenue |
| Late delivery score impact | On Time: **4.29** vs Late: **2.57** (p < 0.0001) |
| RFM — Champions | **14,311** customers identified |
| Customers with 60+ day gaps | **1,192** churn-and-return events |
| CLV top quartile vs bottom | Top 25% worth **~3×** more than bottom 25% |

---

## Tech Stack

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-SQLite-lightgrey?logo=sqlite&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.2-150458?logo=pandas&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-3.9-orange)
![Seaborn](https://img.shields.io/badge/Seaborn-0.13-4C72B0)
![SciPy](https://img.shields.io/badge/SciPy-1.13-8CAAE6?logo=scipy&logoColor=white)

---

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/sualpsudas/olist-ecommerce-analytics.git
cd olist-ecommerce-analytics

# 2. Install dependencies
pip install -r requirements.txt

# 3. Set up Kaggle API token
# Get kaggle.json from kaggle.com/settings → API → Create New Token
# Place at: ~/.kaggle/kaggle.json

# 4. Build the database (run once)
jupyter notebook notebooks/00_setup.ipynb

# 5. Run any analysis
jupyter notebook notebooks/01_basic_analysis.ipynb
```

---

*Dataset: [Olist @ Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — CC BY-NC-SA 4.0*
