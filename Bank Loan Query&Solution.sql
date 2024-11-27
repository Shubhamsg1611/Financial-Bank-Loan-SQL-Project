SELECT * FROM dbo.Loan_Data;

-- Q1. Find Total Loan Applications?

Select Count(id) as Total_Loan_Applications From Loan_Data

-- Q2. Find the total number of loans by loan status:

Select Loan_Status, Count(id) as Total_Loans
From Loan_Data
Group by Loan_Status
Order by Total_Loans desc

-- Q3. How interest rates correlate with loan performance?

Select Loan_Status, Avg(int_rate) as Avg_Interest_Rate
From Loan_Data 
Group by Loan_Status
Order by Avg_Interest_Rate desc

-- Q4. Identify the top states by total loan amount.

Select Address_State, sum(loan_amount) as Total_Loan_Amount
From Loan_Data
Group by Address_State
Order by Total_Loan_Amount Desc 

--Q5. Analyze the average annual income by loan grade.

Select Grade, Avg(Annual_Income) as Avg_Income
From Loan_data
Group by Grade
Order by Avg_Income desc

-- Q6. Find borrowers with high debt-to-income ratios (DTI).

SELECT id, emp_title, annual_income, round(dti*100,2) loan_amount
FROM Loan_Data
Where emp_title is not null
ORDER BY dti DESC;

-- Q7. Find the total payments received for each loan purpose.

Select Purpose, Sum(Loan_Amount) as Total_Loan_Amount
From Loan_Data
Group by Purpose
Order by Total_Loan_Amount desc

-- Q8. Calculate the average loan term by verification status.

Select Verification_Status, Avg( Case
When term = '36 months' Then 36
when term = '60 months' Then 60
End) as Avg_Term
From Loan_Data
Group by Verification_Status

-- Q9. Identify loans with a high risk of default (high interest rates and low payments).

Select id, loan_amount, round(int_rate*100,2) as interest_rate, installment, loan_status
From Loan_Data
Where int_rate > 0.2 and installment < 200 and loan_status = 'Charged Off'

-- Q10. Analyze employment length impact on loan defaults.

Select Emp_length, count(*) as Defaults
From Loan_Data
Where Loan_Status = 'Charged Off'
Group by Emp_Length
Order by Defaults desc

-- Q11. Find the most common employment titles among borrowers.

Select emp_title, Count(*) as borrower_count
From Loan_Data
Group by emp_title
Order by borrower_count desc

-- Q12. Identify the top occupations contributing to high loan amounts.

Select emp_title, Sum(loan_amount) as Total_Loan_Amount, round(Avg(int_rate)*100,2) as Average_Interest_Rate
From Loan_Data
Group by emp_title
Order by Total_Loan_Amount desc

-- Q.13 Calculate the default rate by homeownership type.

SELECT home_ownership,
       COUNT(*) AS total_loans,
       SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults,
       (CAST(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(*)) * 100 AS default_rate
FROM loan_data
GROUP BY home_ownership
ORDER BY default_rate DESC

-- Q14. Segment borrowers by income and loan amount:

SELECT 
    CASE 
        WHEN annual_income < 30000 THEN 'Low Income'
        WHEN annual_income BETWEEN 30000 AND 70000 THEN 'Middle Income'
        ELSE 'High Income'
    END AS income_segment,
    AVG(loan_amount) AS avg_loan_amount,
    COUNT(*) AS total_loans
FROM loan_data
GROUP BY 
    CASE 
        WHEN annual_income < 30000 THEN 'Low Income'
        WHEN annual_income BETWEEN 30000 AND 70000 THEN 'Middle Income'
        ELSE 'High Income'
    END
ORDER BY avg_loan_amount DESC;

-- Q.15 Calculate profitability by loan grade.

SELECT 
    grade, 
    SUM(CAST(loan_amount AS BIGINT)) AS Total_Loan, 
    SUM(CAST(total_payment AS BIGINT)) AS Payment_Received,
    ((SUM(CAST(total_payment AS DECIMAL(18, 2))) - SUM(CAST(loan_amount AS DECIMAL(18, 2)))) / 
     SUM(CAST(loan_amount AS DECIMAL(18, 2)))) * 100 AS Profit_Margin
FROM 
    Loan_Data
GROUP BY 
    grade
ORDER BY 
    Profit_Margin DESC;
	
-- Q.16 Determine lifetime value (LTV) of loans by term.

Select term, avg(total_payment) as Average_Payment, avg(loan_amount) as Average_Loan_Amount, 
       (avg(total_payment) - avg(loan_amount)) as Average_Profit 
From Loan_Data 
Group by term
Order by Average_Profit desc 

-- Q17. Monthly trend of loan issuance by state.

SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, issue_date), 0) AS issue_month, address_state, COUNT(*) AS total_loans
FROM Loan_Data
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, issue_date), 0), address_state
ORDER BY issue_month, total_loans DESC;

--Q.18 Risk-adjusted profitability by loan purpose.

SELECT purpose, COUNT(*) AS total_loans, SUM(total_payment) AS total_received,
    SUM(loan_amount) AS total_loaned, AVG(int_rate) AS avg_interest_rate, (SUM(total_payment) - SUM(loan_amount)) AS profit,
    (CAST(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(*)) * 100 AS default_rate
FROM loan_data
GROUP BY purpose
ORDER BY profit DESC;

-- Q19. Correlation between income and interest rate.

SELECT 
    SUM((annual_income - avg_income) * (int_rate - avg_rate)) / 
    SQRT(SUM(POWER(annual_income - avg_income, 2)) * SUM(POWER(int_rate - avg_rate, 2))) AS income_interest_correlation
FROM 
    (SELECT 
         annual_income, 
         int_rate, 
         (SELECT AVG(annual_income) FROM loan_data) AS avg_income, 
         (SELECT AVG(int_rate) FROM loan_data) AS avg_rate
     FROM 
         loan_data
    ) AS subquery;

-- Q.20 Predict default likelihood by grade and verification status.

SELECT grade, verification_status, COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS defaults,
    CAST(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS DECIMAL(10, 2)) / COUNT(*) * 100 AS default_rate
FROM loan_data
GROUP BY grade, verification_status
ORDER BY default_rate DESC;







