-- ============================================================
-- AI Worker Burnout & Attrition Risk — Dashboard SQL Queries
-- Dataset: ai_worker_burnout_attrition_2026
-- Total Records: 1,500 employees
-- ============================================================
CREATE DATABASE ai_worker;
use ai_worker;

-- ============================================================
-- 0. CREATE TABLE SCHEMA
-- ============================================================

CREATE TABLE burnout_attrition_dataset (
    employee_id                  VARCHAR(10),
    job_role                     VARCHAR(50),
    years_experience             INT,
    education_level              VARCHAR(20),
    country                      VARCHAR(30),
    industry                     VARCHAR(30),
    company_size                 VARCHAR(25),
    remote_work_type             VARCHAR(20),
    team_size                    INT,
    salary_usd_k                 INT,
    primary_ai_tool              VARCHAR(30),
    ai_tools_used_per_day        INT,
    hours_with_ai_assistance_daily FLOAT,
    ai_replaces_my_tasks_pct     INT,
    ai_adoption_stage            VARCHAR(20),
    weekly_ai_upskilling_hrs     FLOAT,
    productivity_score           INT,
    burnout_score                INT,
    job_satisfaction_1_5         FLOAT,
    fear_of_ai_replacement       VARCHAR(10),
    attrition_risk               VARCHAR(10)
);


-- ============================================================
-- KPI 1: Total Employees
-- ============================================================

SELECT COUNT(*) AS total_employees
FROM burnout_attrition_dataset;

-- Result: 1500


-- ============================================================
-- KPI 2: Dominant Attrition Risk Level
-- ============================================================

SELECT attrition_risk,
       COUNT(*) AS count
FROM burnout_attrition_dataset
GROUP BY attrition_risk
ORDER BY count DESC
LIMIT 1;

-- Result: Low (724) — but High is flagged as critical


-- ============================================================
-- KPI 3: Average Burnout Score
-- ============================================================

SELECT ROUND(AVG(burnout_score), 0) AS avg_burnout_score
FROM burnout_attrition_dataset;

-- Result: 50


-- ============================================================
-- KPI 4: Average Job Satisfaction
-- ============================================================

SELECT ROUND(AVG(job_satisfaction_1_5), 2) AS avg_job_satisfaction
FROM burnout_attrition_dataset;

-- Result: 3.33


-- ============================================================
-- CHART 1: Attrition Risk Distribution (Donut Chart)
-- ============================================================

SELECT attrition_risk,
       COUNT(*)                                        AS total,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM burnout_attrition_dataset
GROUP BY attrition_risk
ORDER BY
    CASE attrition_risk
        WHEN 'Low'    THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High'   THEN 3
    END;

-- Results:
-- Low     | 724  | 48.27%
-- Medium  | 691  | 46.07%
-- High    |  85  |  5.67%


-- ============================================================
-- CHART 2: Remote Work Type — Burnout & High Attrition Count
-- ============================================================

SELECT 
    remote_work_type,
    ROUND(AVG(burnout_score), 2) AS avg_burnout_score,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition_risk = 'High' THEN 1 ELSE 0 END) AS high_attrition_count,
    ROUND(SUM(CASE WHEN attrition_risk = 'High' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS high_attrition_pct
FROM burnout_attrition_dataset
GROUP BY remote_work_type
ORDER BY avg_burnout_score DESC;

-- Results:
-- On-site       | 50.57 | 323 | 22 | 6.81%
-- Fully Remote  | 50.22 | 578 | 35 | 6.06%
-- Hybrid        | 49.63 | 599 | 28 | 4.67%


-- ============================================================
-- CHART 3: Average Burnout Score by Industry
-- ============================================================

SELECT industry,
       COUNT(*)                              AS employee_count,
       ROUND(AVG(burnout_score), 2)          AS avg_burnout_score,
       ROUND(AVG(job_satisfaction_1_5), 2)   AS avg_satisfaction,
       SUM(CASE WHEN attrition_risk = 'High'
               THEN 1 ELSE 0 END)            AS high_attrition_count
FROM burnout_attrition_dataset
GROUP BY industry
ORDER BY avg_burnout_score DESC;

-- Results:
-- SaaS          | 134 | 51.31 | 3.30
-- Gaming        | 171 | 50.53 | 3.37
-- E-commerce    | 155 | 50.53 | 3.30
-- EdTech        | 170 | 50.12 | 3.39
-- Healthtech    | 149 | 50.07 | 3.33
-- Media         | 147 | 49.92 | 3.35
-- Fintech       | 138 | 49.83 | 3.37
-- Consulting    | 154 | 49.79 | 3.32
-- Cybersecurity | 128 | 49.77 | 3.25
-- Automotive    | 154 | 48.72 | 3.34


-- ============================================================
-- QUERY 4: Attrition Risk by Job Role
-- ============================================================

SELECT job_role,
       COUNT(*)                                            AS total,
       SUM(CASE WHEN attrition_risk = 'High'   THEN 1 ELSE 0 END) AS high_risk,
       SUM(CASE WHEN attrition_risk = 'Medium' THEN 1 ELSE 0 END) AS medium_risk,
       SUM(CASE WHEN attrition_risk = 'Low'    THEN 1 ELSE 0 END) AS low_risk,
       ROUND(SUM(CASE WHEN attrition_risk = 'High'
                   THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2)      AS high_risk_pct,
       ROUND(AVG(burnout_score), 2)                                AS avg_burnout
FROM burnout_attrition_dataset
GROUP BY job_role
ORDER BY high_risk DESC;

-- Top high-risk roles: AI Ethics Officer (13), DevOps (9), Backend Engineer (9)


-- ============================================================
-- QUERY 5: Fear of AI Replacement — Impact on Attrition
-- ============================================================

SELECT fear_of_ai_replacement,
       COUNT(*)                                           AS total,
       ROUND(AVG(burnout_score), 2)                      AS avg_burnout,
       ROUND(AVG(job_satisfaction_1_5), 2)               AS avg_satisfaction,
       ROUND(SUM(CASE WHEN attrition_risk = 'High'
               THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2) AS high_attrition_pct
FROM burnout_attrition_dataset
GROUP BY fear_of_ai_replacement
ORDER BY
    CASE fear_of_ai_replacement
        WHEN 'High'   THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low'    THEN 3
    END;

-- Results:
-- High   | 358 | 49.39 | 3.37 | 22.07%  ← Critical insight
-- Medium | 619 | 50.16 | 3.32 |  0.32%
-- Low    | 523 | 50.40 | 3.33 |  0.76%


-- ============================================================
-- QUERY 6: Salary Analysis by Attrition Risk
-- ============================================================

SELECT attrition_risk,
       COUNT(*)                          AS employees,
       ROUND(AVG(salary_usd_k), 2)       AS avg_salary_k,
       MIN(salary_usd_k)                 AS min_salary_k,
       MAX(salary_usd_k)                 AS max_salary_k,
       ROUND(AVG(burnout_score), 2)      AS avg_burnout
FROM burnout_attrition_dataset
GROUP BY attrition_risk
ORDER BY avg_burnout DESC;

-- High risk employees earn LESS ($138.6k) but burn out the most (60.8)


-- ============================================================
-- QUERY 7: Country-Level Burnout Rankings
-- ============================================================

SELECT country,
       COUNT(*)                              AS headcount,
       ROUND(AVG(burnout_score), 2)          AS avg_burnout,
       ROUND(AVG(job_satisfaction_1_5), 2)   AS avg_satisfaction,
       SUM(CASE WHEN attrition_risk = 'High'
               THEN 1 ELSE 0 END)            AS high_attrition_count
FROM burnout_attrition_dataset
GROUP BY country
ORDER BY avg_burnout DESC;

-- Most burned out: Brazil (51.47), Singapore (51.38), Netherlands (51.10)
-- Least burned out: UK (48.57), USA (49.17), India (49.47)


-- ============================================================
-- QUERY 8: AI Adoption Stage vs Productivity & Burnout
-- ============================================================

SELECT ai_adoption_stage,
       COUNT(*)                              AS employees,
       ROUND(AVG(productivity_score), 2)     AS avg_productivity,
       ROUND(AVG(burnout_score), 2)          AS avg_burnout,
       ROUND(AVG(job_satisfaction_1_5), 2)   AS avg_satisfaction
FROM burnout_attrition_dataset
GROUP BY ai_adoption_stage
ORDER BY avg_productivity DESC;

-- Results:
-- Experimenting | avg_productivity: 58.07 | avg_burnout: 49.67
-- Optimizing    | avg_productivity: 57.70 | avg_burnout: 50.00
-- Integrating   | avg_productivity: 57.59 | avg_burnout: 50.17
-- AI-First      | avg_productivity: 56.46 | avg_burnout: 50.49


-- ============================================================
-- QUERY 9: Company Size vs Burnout & Attrition
-- ============================================================

SELECT company_size,
       COUNT(*)                                           AS employees,
       ROUND(AVG(burnout_score), 2)                      AS avg_burnout,
       ROUND(SUM(CASE WHEN attrition_risk = 'High'
               THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2) AS high_attrition_pct
FROM burnout_attrition_dataset
GROUP BY company_size
ORDER BY high_attrition_pct DESC;

-- Highest attrition: Small (6.57%), Mid (6.31%), Enterprise (6.09%)
-- Lowest attrition:  Startup (4.18%), Large (5.24%)


-- ============================================================
-- QUERY 10: High-Risk Employee Deep Dive
-- ============================================================

SELECT employee_id,
       job_role,
       country,
       industry,
       salary_usd_k,
       burnout_score,
       job_satisfaction_1_5,
       fear_of_ai_replacement,
       remote_work_type,
       ai_adoption_stage
FROM burnout_attrition_dataset
WHERE attrition_risk = 'High'
ORDER BY burnout_score DESC;

-- Returns all 85 high-risk employees with full profile


-- ============================================================
-- QUERY 11: Correlation — Burnout Score Buckets vs Attrition
-- ============================================================

SELECT
    CASE
        WHEN burnout_score < 30 THEN '< 30 (Low)'
        WHEN burnout_score BETWEEN 30 AND 49 THEN '30–49 (Moderate)'
        WHEN burnout_score BETWEEN 50 AND 69 THEN '50–69 (High)'
        ELSE '70+ (Critical)'
    END AS burnout_bucket,
    COUNT(*)                                           AS total,
    SUM(CASE WHEN attrition_risk = 'High' THEN 1 ELSE 0 END) AS high_attrition,
    ROUND(SUM(CASE WHEN attrition_risk = 'High'
            THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2)  AS high_attrition_pct
FROM burnout_attrition_dataset
GROUP BY burnout_bucket
ORDER BY MIN(burnout_score);


-- ============================================================
-- END OF FILE
-- ============================================================