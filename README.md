# 🏠 Airbnb Data Engineering Pipeline

A end-to-end data engineering pipeline that ingests raw Airbnb data (listings, bookings, hosts), loads it into **Snowflake**, and transforms it using **dbt** — all orchestrated on **AWS**.

---

## 📐 Architecture Overview

```
CSV Source Files (listings, bookings, hosts)
            │
            ▼
        AWS (S3 Staging)
            │
            ▼
     Snowflake (Raw Layer)
            │
            ▼
    dbt (Staging → Marts)
            │
            ▼
  Analytics-Ready Data Models
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| **Python 3.11+** | Scripting & pipeline orchestration |
| **AWS (S3)** | Cloud storage & data staging |
| **Snowflake** | Cloud data warehouse |
| **dbt (Core + Snowflake adapter)** | Data transformation & modeling |
| **uv** | Fast Python package manager |

---

## 📁 Project Structure

```
Airbnb_DE_Pipeline/
│
├── Snowflake/                      # Snowflake setup scripts (DDL, stages, roles)
│
├── aws_dbt_snowflake_project/      # dbt project directory
│   ├── models/
│   │   ├── staging/                # Staging models (raw → cleaned)
│   │   └── marts/                  # Mart models (business-level aggregations)
│   ├── tests/                      # dbt data quality tests
│   ├── macros/                     # Reusable SQL macros
│   └── dbt_project.yml             # dbt project config
│
├── logs/                           # dbt run logs
│
├── bookings.csv                    # Raw bookings data (5000 records)
├── hosts.csv                       # Raw hosts data
├── listings.csv                    # Raw listings data (500 records)
│
├── main.py                         # Pipeline entry point
├── pyproject.toml                  # Python project & dependency config
├── .python-version                 # Pinned Python version
└── uv.lock                         # Locked dependency file
```

---

## 📊 Data Sources

### `listings.csv`
Property listing details including location, room type, pricing, and availability.

| Column | Description |
|---|---|
| `listing_id` | Unique identifier for the listing |
| `host_id` | ID of the host who owns the listing |
| `neighbourhood` | Neighbourhood/area of the property |
| `room_type` | Type of room (Entire home, Private room, etc.) |
| `price` | Nightly price |
| `minimum_nights` | Minimum booking duration |
| `availability_365` | Number of available days in the year |

### `bookings.csv`
Booking transaction records (~5000 rows) containing guest stays and revenue info.

| Column | Description |
|---|---|
| `booking_id` | Unique booking identifier |
| `listing_id` | FK to listings |
| `guest_id` | Guest who made the booking |
| `check_in` | Check-in date |
| `check_out` | Check-out date |
| `total_price` | Total booking revenue |
| `status` | Booking status (confirmed, cancelled, etc.) |

### `hosts.csv`
Host profile information including registration details and response behaviour.

| Column | Description |
|---|---|
| `host_id` | Unique host identifier |
| `host_name` | Name of the host |
| `host_since` | Date host joined Airbnb |
| `response_rate` | Host response rate (%) |
| `superhost` | Whether host is a Superhost (boolean) |

---

## ⚙️ Setup & Installation

### Prerequisites

- Python 3.11+
- [uv](https://github.com/astral-sh/uv) package manager
- Snowflake account
- AWS account with S3 access

### 1. Clone the Repository

```bash
git clone https://github.com/Shashvat207/Airbnb_DE_Pipeline.git
cd Airbnb_DE_Pipeline
```

### 2. Install Dependencies

```bash
uv sync
```

Or with pip:

```bash
pip install dbt-core dbt-snowflake
```

### 3. Configure Snowflake

Run the setup scripts in the `Snowflake/` directory to create the required database, schemas, roles, and stages:

```bash
# Connect to your Snowflake instance and execute:
# Snowflake/setup.sql  (or equivalent scripts in the folder)
```

### 4. Configure dbt Profile

Create or update your `~/.dbt/profiles.yml` with your Snowflake credentials:

```yaml
aws_dbt_snowflake_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_snowflake_account>
      user: <your_username>
      password: <your_password>
      role: <your_role>
      database: AIRBNB_DB
      warehouse: <your_warehouse>
      schema: DEV
      threads: 4
```

### 5. Load Raw Data into Snowflake

Upload the source CSVs to an S3 bucket and use Snowflake's `COPY INTO` command (or run the scripts in `Snowflake/`) to load them into raw tables.

### 6. Run dbt Models

```bash
cd aws_dbt_snowflake_project

# Test the connection
dbt debug

# Install dbt packages
dbt deps

# Run all models
dbt run

# Run tests
dbt test

# Generate and serve docs
dbt docs generate
dbt docs serve
```

---

## 🔄 Pipeline Flow

```
1. Raw CSVs uploaded to S3
        ↓
2. Snowflake COPY INTO → raw tables (bookings_raw, listings_raw, hosts_raw)
        ↓
3. dbt staging models → cleaned, typed, renamed columns
        ↓
4. dbt mart models → business aggregations
           ├── dim_listings   (listing dimension)
           ├── dim_hosts      (host dimension)
           └── fct_bookings   (bookings fact table)
        ↓
5. Analytics / BI Tools query Snowflake marts
```

---

## 🧪 Data Quality Tests

dbt tests are configured to validate:

- **Not null** checks on primary keys
- **Unique** constraints on IDs
- **Accepted values** for categorical fields (e.g., `room_type`, `status`)
- **Referential integrity** between bookings → listings and bookings → hosts

Run all tests with:

```bash
dbt test
```

---

## 📦 Dependencies

Defined in `pyproject.toml`:

```toml
[project]
name = "aws-dbt-snowflake"
requires-python = ">=3.11"

dependencies = [
    "dbt-core>=1.11.8",
    "dbt-snowflake>=1.11.4",
]
```

---

## 🗂️ Snowflake Layer Design

| Layer | Schema | Description |
|---|---|---|
| **Raw** | `RAW` | Unmodified data loaded from S3 |
| **Staging** | `STAGING` | Cleaned, typed, renamed columns |
| **Marts** | `MARTS` | Business-ready fact & dimension tables |

---

## 🚀 Running the Entry Point

```bash
python main.py
```

> Note: `main.py` currently serves as a placeholder. Full pipeline orchestration logic (e.g., triggering S3 uploads and dbt runs) can be added here.

---

## 📌 Future Enhancements

- [ ] Add Apache Airflow / AWS Step Functions for pipeline orchestration
- [ ] Automate S3 uploads via AWS Lambda or Glue
- [ ] Add incremental dbt models for large-scale bookings data
- [ ] Connect a BI tool (e.g., Metabase, Tableau, Preset) to Snowflake marts
- [ ] Add CI/CD with GitHub Actions for automated dbt runs on push
- [ ] Add dbt snapshots for slowly changing dimensions (hosts, listings)

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

---
