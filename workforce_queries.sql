SELECT *
FROM employees
WHERE employment_status = 'Active';

SELECT 
    grade,
    COUNT(employee_id) AS total_employees,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN employee_id END) leavers
FROM employees
GROUP BY grade
ORDER BY leavers DESC;

SELECT 
    grade,
    COUNT(employee_id) AS total_employees,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN employee_id END) AS leavers,
    CAST(
        COUNT(CASE WHEN exit_date IS NOT NULL THEN employee_id END) * 100.0
        / NULLIF(COUNT(employee_id), 0)
    AS DECIMAL(5,2)) AS attrition_rate
FROM employees
GROUP BY grade
ORDER BY attrition_rate DESC;

SELECT 
    YEAR(exit_date) AS exit_year,
    MONTH(exit_date) AS exit_month,
    COUNT(employee_id) AS leavers
FROM employees
WHERE exit_date IS NOT NULL
GROUP BY 
    YEAR(exit_date),
    MONTH(exit_date)
ORDER BY 
    exit_year,
    exit_month;
    
    SELECT 
    skill,
    COUNT(employee_id) AS total_employees,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN employee_id END) AS leavers,
    CAST(
        COUNT(CASE WHEN exit_date IS NOT NULL THEN employee_id END) * 100.0
        / NULLIF(COUNT(employee_id), 0)
    AS DECIMAL(5,2)) AS attrition_rate
FROM employees
GROUP BY skill
ORDER BY attrition_rate DESC;

WITH current_assignment AS (
    SELECT 
        employee_id,
        customer_id,
        project_id,
        assignment_start_date,
        assignment_end_date,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id 
            ORDER BY assignment_end_date DESC
        ) AS rn
    FROM assignments
    WHERE assignment_start_date <= CURDATE()
      AND (
          assignment_end_date IS NULL
          OR assignment_end_date >= CURDATE()
      )
)
SELECT 
    e.employee_id,
    e.grade,
    e.skill,
    e.location,
    CASE 
        WHEN ca.employee_id IS NOT NULL THEN 'Deployed'
        ELSE 'Bench'
    END AS deployment_status,
    ca.customer_id,
    ca.project_id
FROM employees e
LEFT JOIN current_assignment ca
    ON e.employee_id = ca.employee_id
   AND ca.rn = 1
WHERE e.employment_status = 'Active';

WITH last_customer AS (
    SELECT 
        employee_id,
        customer_id,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id 
            ORDER BY assignment_end_date DESC,
                     assignment_start_date DESC
        ) AS rn
    FROM assignments
)

SELECT 
    c.customer_name,
    COUNT(DISTINCT e.employee_id) AS total_employees,
    COUNT(DISTINCT CASE 
        WHEN e.exit_date IS NOT NULL THEN e.employee_id 
    END) AS attrition_count
FROM employees e
LEFT JOIN last_customer lc
    ON e.employee_id = lc.employee_id
   AND lc.rn = 1
LEFT JOIN customers c
    ON lc.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY attrition_count DESC;

SELECT 
    b.employee_id,
    e.grade,
    e.skill,
    e.location,
    b.bench_start_date,
    DATEDIFF(CURDATE(), b.bench_start_date) AS bench_days,
    b.bench_reason
FROM bench_history b
JOIN employees e
    ON b.employee_id = e.employee_id
WHERE b.bench_end_date IS NULL
  AND e.employment_status = 'Active'
ORDER BY bench_days DESC;

SELECT 
    b.employee_id,
    e.skill,
    e.grade,
    DATEDIFF(CURDATE(), b.bench_start_date) AS bench_days,
    CASE 
        WHEN DATEDIFF(CURDATE(), b.bench_start_date) <= 15 THEN '0-15 Days'
        WHEN DATEDIFF(CURDATE(), b.bench_start_date) <= 30 THEN '16-30 Days'
        WHEN DATEDIFF(CURDATE(), b.bench_start_date) <= 60 THEN '31-60 Days'
        WHEN DATEDIFF(CURDATE(), b.bench_start_date) <= 90 THEN '61-90 Days'
        ELSE '90+ Days'
    END AS bench_aging_bucket
FROM bench_history b
JOIN employees e
    ON b.employee_id = e.employee_id
WHERE CURDATE() BETWEEN b.bench_start_date AND b.bench_end_date
  AND e.employment_status = 'Active';
  
  SELECT 
    e.employee_id,
    e.skill,
    e.grade,
    e.location,
    b.bench_start_date,
    DATEDIFF(CURDATE(), b.bench_start_date) AS bench_days
FROM bench_history b
JOIN employees e
    ON b.employee_id = e.employee_id
WHERE CURDATE() BETWEEN b.bench_start_date AND b.bench_end_date
  AND e.employment_status = 'Active'
  AND DATEDIFF(CURDATE(), b.bench_start_date) > 30
ORDER BY bench_days DESC;

SELECT 
    a.employee_id,
    COUNT(a.assignment_id) AS rotations_last_12_months
FROM assignments a
WHERE a.assignment_start_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY a.employee_id
ORDER BY rotations_last_12_months DESC;

WITH recent_assignments AS (
    SELECT 
        employee_id,
        COUNT(assignment_id) AS assignment_count
    FROM assignments
    WHERE assignment_start_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY employee_id
)
SELECT 
    e.employee_id,
    e.skill,
    e.grade,
    e.location,
    IFNULL(ra.assignment_count, 0) AS rotations_last_12_months
FROM employees e
LEFT JOIN recent_assignments ra
    ON e.employee_id = ra.employee_id
WHERE e.employment_status = 'Active'
  AND IFNULL(ra.assignment_count, 0) <= 1
ORDER BY rotations_last_12_months ASC;

SELECT 
    a.employee_id,
    e.skill,
    e.grade,
    c.customer_name,
    p.project_name,
    a.assignment_end_date,
    DATEDIFF(a.assignment_end_date, CURDATE()) AS days_to_end
FROM assignments a
JOIN employees e
    ON a.employee_id = e.employee_id
JOIN customers c
    ON a.customer_id = c.customer_id
JOIN projects p
    ON a.project_id = p.project_id
WHERE e.employment_status = 'Active'
  AND a.assignment_end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 60 DAY)
ORDER BY a.assignment_end_date;

SELECT 
    c.customer_name,
    SUM(b.budget_amount) AS total_budget,
    SUM(b.actual_amount) AS total_actual,
    SUM(b.budget_amount) - SUM(b.actual_amount) AS remaining_budget,
    CAST(
        SUM(b.actual_amount) * 100.0 / NULLIF(SUM(b.budget_amount), 0)
    AS DECIMAL(5,2)) AS burn_rate
FROM budgets b
JOIN customers c
    ON b.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY burn_rate DESC;

SELECT 
    c.customer_name,
    p.project_name,
    SUM(b.budget_amount) AS budget_amount,
    SUM(b.actual_amount) AS actual_amount,
    SUM(b.actual_amount) - SUM(b.budget_amount) AS variance,
    CASE 
        WHEN SUM(b.actual_amount) > SUM(b.budget_amount) THEN 'Over Budget'
        ELSE 'Within Budget'
    END AS budget_status
FROM budgets b
JOIN customers c
    ON b.customer_id = c.customer_id
JOIN projects p
    ON b.project_id = p.project_id
GROUP BY 
    c.customer_name,
    p.project_name
ORDER BY variance DESC;



