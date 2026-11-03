WITH deduplicated AS (
    SELECT
        order_item_id,
        order_id,
        product_id,
        quantity,
        item_price,
        created_at,
        ingest_date,
        ROW_NUMBER() OVER (
            PARTITION BY order_id, product_id, quantity, item_price, created_at
            ORDER BY order_item_id
        ) AS rn
    FROM {{ source('silver', 'order_items') }}
)

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    item_price,
    created_at,
    ingest_date
FROM deduplicated
WHERE rn = 1