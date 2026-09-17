# PricePoint Source Manifest

## Source family

M5 retail forecasting dataset.

This repository does **not** contain the raw M5 CSV files. Third-party source files remain subject to their original rights and terms.

## Local MySQL target

```text
schema: pricepoint
```

## Raw source tables

### `raw_calendar`

Observed imported row count:

```text
1,969
```

Import record reported:

```text
Skipped: 0
Warnings: 0
```

### `raw_sell_prices`

Observed imported row count:

```text
6,841,121
```

Import record reported:

```text
Skipped: 0
Warnings: 0
```

### `raw_sales_evaluation`

Observed row count:

```text
30,490
```

Each row represents one product-store sales series with identifier fields:

```text
id
item_id
dept_id
cat_id
store_id
state_id
```

Daily sales history is stored in:

```text
sales_history JSON
```

The source wide file contained:

```text
1,941 daily columns
first: d_1
last:  d_1941
```

The wide CSV was mechanically converted to a tab-delimited import file in R, preserving the six identifier columns and serializing the 1,941 daily values into a JSON array.

Observed conversion facts:

```text
source series: 30,490
JSON values per series: 1,941
converted TSV size: ~116.14 MB
```

## Required verification record

Before analytical Stage 4 relies on a source package, preserve evidence for:

- current raw-table row counts;
- uniqueness of the series `id` where expected;
- minimum/maximum `JSON_LENGTH(sales_history)`;
- `d_1` ↔ JSON position 0 and `d_1941` ↔ JSON position 1940 mapping;
- calendar key coverage;
- price table key coverage;
- missingness and duplicate behavior relevant to the locked Stage 3 contract;
- source version / retrieval record when available.

## Important distinction

Raw-source verification and the Stage 4 SQL Source Gate are different controls:

- **raw-source verification** establishes that the downloaded source was faithfully represented in local MySQL;
- **SQL Source Gate** establishes that the bounded source package delivered to R-A and R-B faithfully represents the authorized Stage 3 delivery contract.

Neither substitutes for the other.
