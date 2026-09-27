# E-Commerce User Events SQL Analysis

A SQL project analyzing user event data to uncover funnel stages, conversion patterns, and marketing channel efficiency. This project demonstrates how to turn raw event logs into actionable business insights using advanced SQL techniques.

## 📊 Dataset

- **File:** `user_events.csv`
- **Columns:** `event_id`, `user_id`, `event_type`, `event_date`, `product_id`, `amount`, `traffic_source`
- **Event Types:** `page_view`, `add_to_cart`, `checkout_start`, `payment_info`, `purchase`
- **Traffic Sources:** `organic`, `social`, `paid_ads`, `email`

## 🛠️ Tech Stack

- **Database:** SQLite (`my_project.sqlite`)
- **Language:** SQL (SQLite dialect)
- **Data Loading:** Python + Pandas (`setup_database.py`)
- **Development Environment:** VS Code + SQLite Extension (alexcvzz)

## 🗂️ Project Structure

```text
sql_project/
├── project.sql             # All SQL queries (Funnel, Channel, Financials)
├── setup_database.py       # Script to load CSV into SQLite
├── user_events.csv         # Raw dataset
├── README.md               # This file
└── .gitignore              # Excludes the generated .sqlite file
```

## 🔍 Queries Included (in `project.sql`)

1. **Funnel Stage Counts:** Counts unique users at each stage (View → Cart → Checkout → Payment → Purchase) over the last 30 days.
2. **Funnel Conversion Rates:** Calculates the percentage drop-off between each stage to pinpoint friction points.
3. **Channel Attribution:** Compares conversion rates across `traffic_source` (Organic, Social, Email, Paid Ads) to determine which channels actually drive revenue, not just traffic.
4. **Time-to-Convert:** Measures the average time (in minutes) users take to move from view → cart → purchase.
5. **Financial KPIs:** Calculates Total Revenue, Average Order Value (AOV), and Revenue per Visitor.

## 💡 Key Insights

- **Checkout is Frictionless:** The conversion rate from `checkout_start` to `purchase` is ~80%+. The technical payment flow is working perfectly.
- **Social Media Traffic is Low Quality:** Social drives ~30% of traffic but has the lowest conversion rate (window shoppers). Email is the highest-converting channel (~13% vs. ~6% for Social).
- **AOV Benchmark:** The Average Order Value is ~$115, meaning Customer Acquisition Cost (CAC) on Paid Ads must stay below $30-$40 to remain profitable.

## 🚀 How to Run This Project

1. **Clone this repo:**
   ```bash
   git clone https://github.com/navya21feb/user-events-sql-analysis.git
   cd user-events-sql-analysis
   ```

2. **Install dependencies:**
   ```bash
   pip install pandas
   ```

3. **Create the SQLite database:**
   ```bash
   python setup_database.py
   ```
   *This generates `my_project.sqlite` from the CSV.*

4. **Open in VS Code:**
   - Open the folder in VS Code.
   - Ensure the **SQLite** extension (by alexcvzz) is installed.
   - Open `my_project.sqlite` in the SQLite Explorer.

5. **Run Queries:**
   - Open `project.sql`.
   - Place your cursor on any query and press `Ctrl + Shift + Q` (or right-click → "Run Query").
   - Results will appear in a side panel.

## 📈 Business Recommendations (Based on Data)

- **UX:** *Do not redesign the checkout page.* It is performing excellently. Focus on improving the `View → Cart` rate instead.
- **Marketing:** *Shift budget away from Social Ads.* Reallocate spend toward Email Marketing, which has a 2x higher conversion rate. Implement email capture popups for social visitors.
- **Financial:** *Set a strict CAC limit.* If Social Media ad spend exceeds $30-$40 per acquisition, the transaction is likely a loss.