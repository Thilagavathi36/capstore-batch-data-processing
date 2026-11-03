SELECT
    oi.order_item_id,
    oi.order_id,
    o.customer_id,
    oi.product_id,
    o.order_date,
    CAST(DATE_FORMAT(o.order_date, 'yyyyMMdd') AS INT) AS date_key,
    o.status,
    oi.quantity,
    oi.item_price,
    oi.quantity * oi.item_price AS gross_revenue
FROM {{ ref('stg_order_items') }} oi
INNER JOIN {{ ref('stg_orders') }} o
    ON oi.order_id = o.order_id