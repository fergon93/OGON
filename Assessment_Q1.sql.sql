SELECT
	u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COUNT(DISTINCT s.savings_id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,
    COALESCE(SUM(s.confirmed_amount), 0) AS total_deposits
    FROM
		users_customuser u
        LEFT JOIN
			savings_savingsaccount s ON u.id = s.owner_id
		LEFT JOIN
			plans_plan p ON u.id = p.owner_id
		GROUP BY
        u.id, u.first_name, u.last_name;