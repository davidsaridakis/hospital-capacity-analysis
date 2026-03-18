-- =====================================================
-- Hospital Capacity Analysis - Load Data
-- =====================================================

USE hospital_capacity_db;

-- -------------------------------------------
-- Reset tables so script can be rerun safely
-- -------------------------------------------

-- Disable foreign key constrtaints
SET FOREIGN_KEY_CHECKS =0;

-- Remove all rows
TRUNCATE TABLE hospitals;
TRUNCATE TABLE provinces;
TRUNCATE TABLE communities;
TRUNCATE TABLE management_types;
TRUNCATE TABLE center_types;

-- Re-enable foreign key contraints
SET FOREIGN_KEY_CHECKS = 1;


-- Remove staging table if it already exists
DROP TABLE IF EXISTS hospitals_staging;

-- ------------------------------------------------
-- Create staging table for importing CSV data
-- ------------------------------------------------
CREATE TABLE hospitals_staging (
    ccn BIGINT,
    hospital_name VARCHAR(255),
    address VARCHAR(255),
    phone VARCHAR(50),
    municipality VARCHAR(100),
    province VARCHAR(100),
    autonomous_community VARCHAR(100),
    postcode VARCHAR(10),
    beds INT,
    cod_clase_de_centro VARCHAR(20),
    center_type VARCHAR(150),
    cod_dep_funcional VARCHAR(20),
    management_type VARCHAR(150),
    forma_parte_complejo VARCHAR(10),
    codidcom VARCHAR(20),
    nombre_del_complejo VARCHAR(255),
    alta VARCHAR(20),
    email VARCHAR(255)
);

-- ------------------------------------------------
-- Load the CSV file
-- ------------------------------------------------
LOAD DATA LOCAL INFILE '/mnt/c/Users/guada/Desktop/Study/projects/hospital-capacity-analysis/data/cleaned/hospitals_clean.csv'
INTO TABLE hospitals_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
-- Set beds to null if empty to avoid warnings
SET beds = NULLIF(beds, '');


-- ------------------------------------------------
-- Populate communities dimension table
-- ------------------------------------------------
INSERT INTO communities (community_name)
SELECT DISTINCT autonomous_community
FROM hospitals_staging
WHERE autonomous_community IS NOT NULL;


-- ------------------------------------------------
-- Populate provinces dimension table
-- ------------------------------------------------
-- Each province belongs to an autonomous community
INSERT INTO provinces (province_name, community_id)
SELECT DISTINCT
    hs.province,
    c.community_id
FROM hospitals_staging hs

JOIN communities c
    ON hs.autonomous_community = c.community_name
WHERE hs.province IS NOT NULL;


-- ------------------------------------------------
-- Populate management_types dimension table
-- ------------------------------------------------
INSERT INTO management_types (management_type)
SELECT DISTINCT management_type
FROM hospitals_staging
WHERE management_type IS NOT NULL;


-- ------------------------------------------------
-- Populate center_types dimension table
-- ------------------------------------------------
INSERT INTO center_types (center_type)
SELECT DISTINCT center_type
FROM hospitals_staging
WHERE center_type IS NOT NULL;


-- ------------------------------------------------
-- Populate hospitals fact table
-- ------------------------------------------------
INSERT INTO hospitals (
    hospital_name,
    address,
    municipality,
    postal_code,
    beds,
    province_id,
    management_type_id,
    center_type_id
)
SELECT
    hs.hospital_name,
    hs.address,
    hs.municipality,
    hs.postcode,
    hs.beds,
    
    p.province_id,
    mt.management_type_id,
    ct.center_type_id

FROM hospitals_staging hs

JOIN provinces p
    ON hs.province = p.province_name

JOIN management_types mt
    ON hs.management_type = mt.management_type

JOIN center_types ct
    ON hs.center_type = ct.center_type;

-- ------------------------------------------------
-- Validation checks
-- ------------------------------------------------

SELECT 'Staging rows', COUNT(*) 
FROM hospitals_staging;

SELECT 'Communities', COUNT(*) 
FROM communities;

SELECT 'Provinces', COUNT(*) 
FROM provinces;

SELECT 'Hospitals', COUNT(*) 
FROM hospitals;