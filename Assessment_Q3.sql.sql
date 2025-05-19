WITH all_transactions AS (
    SELECT 
        savings_id AS plan_id,
        owner_id,
        'savings' AS type,
        transaction_date AS last_transaction_date
    FROM savings_savingsaccount

    UNION ALL

    SELECT 
        id AS plan_id,
        owner_id,
        'plans' AS type,
        created_on AS last_transaction_date
    FROM plans_plan
),
last_transactions AS (
    SELECT 
        owner_id,
        plan_id,
        type,
        last_transaction_date,
        ROW_NUMBER() OVER (PARTITION BY owner_id ORDER BY last_transaction_date DESC) AS rn
    FROM all_transactions
),
inactive_users AS (
    SELECT 
        owner_id,
        plan_id,
        type,
        last_transaction_date,
        DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
    FROM last_transactions
    WHERE rn = 1
)
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM inactive_users
WHERE inactivity_days >= 365;
