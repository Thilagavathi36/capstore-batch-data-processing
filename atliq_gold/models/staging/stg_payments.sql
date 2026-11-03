WITH ranked_payments AS (
    SELECT
        payment_id,
        order_id,
        amount,
        method,
        paid_at,
        updated_at,
        ingest_date,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY paid_at ASC NULLS LAST, payment_id ASC
        ) AS rn
    FROM {{ source('silver', 'payments') }}
)

SELECT
    payment_id,
    order_id,
    amount,
    method,
    paid_at,
    updated_at,
    ingest_date
FROM ranked_payments
WHERE rn = 1