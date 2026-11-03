WITH ranked_prices AS (
    SELECT
        product_id,
        product_name,
        supplier_name,
        supplier_cost,
        effective_date,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY effective_date DESC
        ) AS rn
    FROM {{ source('silver', 'supplier_price_list') }}
)

SELECT
    product_id,
    product_name,
    supplier_name,
    supplier_cost,
    effective_date
FROM ranked_prices
WHERE rn = 1