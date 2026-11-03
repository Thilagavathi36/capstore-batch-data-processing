SELECT
    customer_id,
    customer_name,
    email,
    city,
    signup_date,
    updated_at,
    is_test
FROM {{ source('silver', 'customers') }}