-- =====================================================
-- Hospital Capacity Analysis - Analytical Queries
-- =====================================================
--
-- Description:
-- This script contains analytical SQL queries used to
-- explore hospital capacity across Spain.
--
-- Focus Areas:
-- - Distribution of hospitals by region
-- - Capacity (beds) analysis
-- - Public vs private hospital breakdown
-- - Identification of largest hospitals
--
-- =====================================================

USE hospital_capacity_db;

-- ------------------------------------------------
-- Create reusable view
-- ------------------------------------------------
CREATE OR REPLACE VIEW hospital_full_data AS
SELECT
    h.hospital_id,
    h.hospital_name,
    h.municipality,
    h.beds,
    p.province_name,
    c.community_name,
    mt.management_type,
    ct.center_type

FROM hospitals h

JOIN provinces p
    ON h.province_id = p.province_id

JOIN communities c
    ON p.community_id = c.community_id

JOIN management_types mt
    ON h.management_type_id = mt.management_type_id

JOIN center_types ct
    ON h.center_type_id = ct.center_type_id;

-- ------------------------------------------------
-- Hospital per Autonomous Community (using explicit joins)
-- ------------------------------------------------
SELECT
    c.community_name,
    COUNT(h.hospital_id) AS total_hospitals
FROM hospitals h

JOIN provinces p
    ON h.province_id = p.province_id

JOIN communities c
    ON p.community_id = c.community_id

GROUP BY c.community_name

ORDER BY total_hospitals DESC;


-- ------------------------------------------------
-- Total Hospital Beds per Autonomous Community (using view)
-- ------------------------------------------------
SELECT
    community_name,
    SUM(beds) AS total_beds
FROM hospital_full_data
GROUP BY community_name
ORDER BY total_beds DESC;


-- ------------------------------------------------
-- Average Beds per Hospital by Autonomous Community
-- ------------------------------------------------
SELECT 
    community_name,
    ROUND(AVG(beds), 2) AS avg_beds_per_hospital
FROM hospital_full_data
GROUP BY community_name
ORDER BY avg_beds_per_hospital DESC;


-- ------------------------------------------------
-- Top 10 Largest Hospitals by Bed Count
-- ------------------------------------------------
SELECT 
    hospital_name,
    municipality,
    beds
FROM hospital_full_data

ORDER BY beds DESC

LIMIT 10;


-- ------------------------------------------------
-- Hospital Distribution by Management Type
-- (Public v Private)
-- ------------------------------------------------
SELECT
    CASE
        WHEN management_type = 'privados' THEN 'Private'
        ELSE 'Public / Other'    
    END AS management_group,
    COUNT(*) AS total_hospitals
FROM hospital_full_data
GROUP BY management_group
ORDER BY total_hospitals DESC;


-- ------------------------------------------------
-- Total Beds by Management Type
-- ------------------------------------------------
SELECT
    CASE
        WHEN management_type = 'privados' THEN 'Private'
        ELSE 'Public / Other'    
    END AS management_group,
    SUM(beds) AS total_beds
FROM hospital_full_data
GROUP BY management_group
ORDER BY total_beds DESC;


-- ------------------------------------------------
-- Hospitals per Province
-- ------------------------------------------------
SELECT
    province_name,
    COUNT(*) AS total_hospitals
FROM hospital_full_data
GROUP BY province_name
ORDER BY total_hospitals DESC;
