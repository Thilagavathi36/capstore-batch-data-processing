SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.order_amount,
    o.created_at,
    o.updated_at,
    o.ingest_date
FROM {{ source('silver', 'orders') }} o
INNER JOIN {{ ref('stg_customers') }} c
    ON o.customer_id = c.customer_id
WHERE c.is_test = false