WITH combined_transactions AS (
	SELECT owner_id, DATE_FORMAT(transaction_date, "%Y-%m") AS month
		FROM savings_savingsaccount
        UNION ALL
        SELECT owner_id, DATE_FORMAT(created_on, "%Y-%m") AS month
        FROM plans_plan
        ),
	transactions_per_user_month AS (
		SELECT owner_id, COUNT(*) AS tx_count
        FROM combined_transactions
        GROUP BY owner_id, month
        ),
	avg_tx_per_user AS (
		SELECT owner_id, AVG(tx_count) AS avg_tx_per_month
        FROM transactions_per_user_month
        GROUP BY owner_id
        ),
	categorized_users AS (
		SELECT owner_id, avg_tx_per_month,
			CASE 
				WHEN avg_tx_per_month >= 10 THEN "High Frequency"
				WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN "Medium Frequency"
				ELSE "Low Frequency"
			END AS frequency_category
		FROM avg_tx_per_user
        )
	SELECT 
		frequency_category, 
		COUNT(DISTINCT owner_id) AS customer_count,
        ROUND(AVG(avg_tx_per_month), 2) AS avg_transaction_per_month
	FROM categorized_users
    GROUP BY frequency_category
    ORDER BY FIELD(frequency_category, "High Frequency", "Medium Frequency", "Low Frequency");