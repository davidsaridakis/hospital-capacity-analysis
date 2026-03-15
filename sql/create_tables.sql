-- Hospital Capacity Analysis
-- Table Creation Script

USE hospital_capacity_db;

-- ---------------
-- Communities 
-- ---------------

CREATE TABLE communities(
    community_id INT AUTO_INCREMENT PRIMARY KEY,
    community_name VARCHAR(100) NOT NULL
);

-- ---------------
-- Provinces 
-- ---------------

CREATE TABLE provinces(
    province_id INT AUTO_INCREMENT PRIMARY KEY,
    province_name VARCHAR(100) NOT NULL,
    community_id INT,

    FOREIGN KEY (community_id) 
    REFERENCES communities(community_id)  
);

-- ---------------
-- Management Types
-- ---------------

CREATE TABLE management_types (
    management_type_id INT AUTO_INCREMENT PRIMARY KEY,
    management_type VARCHAR(100)
);

-- ---------------
-- Center Types 
-- ---------------

CREATE TABLE center_types(
    center_type_id INT AUTO_INCREMENT PRIMARY KEY,
    centre_type VARCHAR(100)
);

-- ---------------
-- Hospitals
-- ---------------

CREATE TABLE hospitals(
    hospital_id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_name VARCHAR(255),
    address VARCHAR(255),
    municipality VARCHAR(100),
    postal_code VARCHAR(10),
    beds INT,

    province_id INT,
    management_type_id INT,
    center_type_id INT,

    FOREIGN KEY (province_id)
        REFERENCES provinces(province_id),

    FOREIGN KEY (management_type_id)
        REFERENCES management_types(management_type_id),

    FOREIGN KEY (center_type_id)
        REFERENCES center_types(center_type_id)
    );