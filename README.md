# Olist E-Commerce Analytics — SQL + Python

> End-to-end business analytics on a real Brazilian e-commerce dataset.
> 15 business questions across 3 difficulty levels, answered with SQL and visualized with Python.

---

## Dataset

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — Kaggle
**~100,000 orders | 9 relational tables | 2016–2018**

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
│   ├── 01_basic.sql          # Q1–Q5   — GROUP BY, JOIN, aggregation
│   ├── 02_intermediate.sql   # Q6–Q10  — CTE, window functions, date ops
│   └── 03_advanced.sql       # Q11–Q15 — RFM, cohort, composite scoring
├── notebooks/
│   ├── 00_setup.ipynb        # Download data + build SQLite DB
│   ├── 01_basic_analysis.ipynb
│   ├── 02_intermediate_analysis.ipynb
│   └── 03_advanced_analysis.ipynb
├── src/
│   └── db_utils.py           # SQLite connection + query helpers
└── requirements.txt
```

---

## 15 Business Questions

### Basic — `GROUP BY · JOIN · CASE WHEN · AVG`

| # | Business Question | Key Finding |
|---|-------------------|-------------|
| Q1 | What are the top product categories by order volume? | |
| Q2 | What is the distribution of order statuses? | |
| Q3 | Which Brazilian states have the most customers? | |
| Q4 | How does average order value vary by payment type? | |
| Q5 | Which categories have the highest customer review scores? | |

### Intermediate — `CTE · WINDOW FUNCTIONS · DATE · NTILE`

| # | Business Question | Key Finding |
|---|-------------------|-------------|
| Q6 | What does monthly revenue look like — best and worst months? | |
| Q7 | How does actual delivery time compare to estimated? | |
| Q8 | What are the top 3 best-selling products in each category? | |
| Q9 | Do the top 10% of sellers drive a disproportionate share of revenue? | |
| Q10 | Do customers order more on weekdays or weekends? | |

### Advanced — `RFM · Cohort · Statistical Testing · LAG()`

| # | Business Question | Key Finding |
|---|-------------------|-------------|
| Q11 | How can we segment customers using RFM scoring? | |
| Q12 | What does customer retention look like across monthly cohorts? | |
| Q13 | Does late delivery have a statistically significant impact on review scores? | |
| Q14 | How can we rank sellers using a composite performance score? | |
| Q15 | Which product categories show the strongest month-over-month revenue growth? | |

---

## SQL Techniques Demonstrated

| Technique | Questions |
|-----------|-----------|
| `GROUP BY` + `ORDER BY` | Q1, Q2, Q3, Q4, Q5 |
| Multi-table `JOIN` | Q1, Q5, Q7 |
| `CASE WHEN` | Q2, Q10, Q11, Q13 |
| `CTE` (Common Table Expressions) | Q6, Q9, Q11, Q12, Q13, Q14, Q15 |
| `RANK()` window function | Q6, Q8 |
| `NTILE()` window function | Q9, Q11, Q14 |
| `LAG()` window function | Q15 |
| `JULIANDAY()` date arithmetic | Q7, Q12, Q14 |
| `STRFTIME()` date formatting | Q6, Q10, Q12, Q15 |
| Statistical significance test (Python) | Q13 |

---

## Tech Stack

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![SQL](https://img.shields.io/badge/SQL-SQLite-lightgrey?logo=sqlite)
![Pandas](https://img.shields.io/badge/Pandas-2.2-blue?logo=pandas)
![Matplotlib](https://img.shields.io/badge/Matplotlib-3.9-orange)
![Seaborn](https://img.shields.io/badge/Seaborn-0.13-teal)
![SciPy](https://img.shields.io/badge/SciPy-1.13-blue)

---

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/sualpsudas/olist-ecommerce-analytics.git
cd olist-ecommerce-analytics

# 2. Install dependencies
pip install -r requirements.txt

# 3. Set up Kaggle API token
# Download kaggle.json from kaggle.com/settings and place at ~/.kaggle/kaggle.json

# 4. Build the database (run once)
jupyter notebook notebooks/00_setup.ipynb

# 5. Open any analysis notebook
jupyter notebook notebooks/01_basic_analysis.ipynb
```

---

## Key Insights

> *(This section will be populated after running the notebooks)*

- **Top categories:** ...
- **Revenue trend:** ...
- **Delivery performance:** ...
- **RFM segments:** ...
- **Late delivery impact:** statistically significant (p < 0.05)

---

*Dataset: [Olist @ Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — licensed under CC BY-NC-SA 4.0*
