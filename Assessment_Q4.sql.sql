WITH savings_data AS (
    SELECT 
        owner_id,
        COUNT(*) AS savings_tx_count,
        SUM(0.001 * amount) AS savings_profit
    FROM savings_savingsaccount
    GROUP BY owner_id
),
plans_data AS (
    SELECT 
        owner_id,
        COUNT(*) AS plans_tx_count,
        SUM(0.001 * amount) AS plans_profit  -- Replace 'amount' with actual column name if different
    FROM plans_plan
    GROUP BY owner_id
),
aggregated AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
        COALESCE(s.savings_tx_count, 0) + COALESCE(p.plans_tx_count, 0) AS total_transactions,
        COALESCE(s.savings_profit, 0) + COALESCE(p.plans_profit, 0) AS total_profit
    FROM users_customuser u
    LEFT JOIN savings_data s ON u.id = s.owner_id
    LEFT JOIN plans_data p ON u.id = p.owner_id
)
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND(
        CASE 
            WHEN tenure_months > 0 THEN (total_transactions / tenure_months) * 12 * (total_profit / total_transactions)
            ELSE 0
        END, 2
    ) AS clv
FROM aggregated
ORDER BY clv DESC;