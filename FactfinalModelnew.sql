create schema FactDiseaseModel

-- Create Disease Dimension Table
CREATE TABLE FactDiseaseModel.dim_disease (
    disease_id1 SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    intensity_level_qty INTEGER,
    type_cd VARCHAR(10) NOT NULL,
    CONSTRAINT fk_dim_disease_type FOREIGN KEY (type_cd) REFERENCES FactDiseaseModel.dim_disease_type (type_code)
);

-- Create Person Dimension Table
CREATE TABLE FactDiseaseModel.dim_person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(1) NOT NULL,
    date_of_birth DATE,
    primary_location_id INTEGER,
    race_cd VARCHAR(100),
    CONSTRAINT fk_dim_person_location FOREIGN KEY (primary_location_id) REFERENCES FactDiseaseModel.dim_location(location_id),
    CONSTRAINT fk_dim_person_race FOREIGN KEY (race_cd) REFERENCES FactDiseaseModel.dim_race (race_code)
);


-- Create Location Dimension Table
CREATE TABLE FactDiseaseModel.dim_location (
    location_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100),
    state_province VARCHAR(100),
    country_name VARCHAR(100) NOT NULL,
    developing BOOLEAN,
    wealth_rank_number INTEGER NOT NULL
);

-- Create Race Dimension Table
CREATE TABLE FactDiseaseModel.dim_race (
    race_code VARCHAR(100) PRIMARY KEY,
    race_description VARCHAR(100) NOT NULL
);


-- Create Disease Type Dimension Table
CREATE TABLE FactDiseaseModel.dim_disease_type (
    type_code VARCHAR(100) PRIMARY KEY,
    type_description VARCHAR(1000),
    ex_other_note VARCHAR(2000)
);


-- Create Medicine Dimension Table
CREATE TABLE FactDiseaseModel.dim_medicine (
    medicine_id SERIAL PRIMARY KEY,
    standard_industry_number VARCHAR(25),
    name VARCHAR(250) NOT NULL,
    company VARCHAR(150),
    active_ingredient_name VARCHAR(100),
    CONSTRAINT uk_dim_medicine_name UNIQUE (name) -- Assuming medicine names are unique
);

-- Create Indication Dimension Table
CREATE TABLE FactDiseaseModel.dim_indication (
    medicine_id INTEGER NOT NULL,
    disease_id2 INTEGER NOT NULL,
    indication_date DATE,
    effectiveness_percent DOUBLE PRECISION,
    CONSTRAINT pk_dim_indication PRIMARY KEY (medicine_id, disease_id2),
    CONSTRAINT fk_dim_indication_disease FOREIGN KEY (disease_id2) REFERENCES FactDiseaseModel.dim_disease (disease_id1),
    CONSTRAINT fk_dim_indication_medicine FOREIGN KEY (medicine_id) REFERENCES FactDiseaseModel.dim_medicine (medicine_id)
);




-- Create Disease Patient Fact Table
CREATE TABLE FactDiseaseModel.fact_disease_patient (
    id SERIAL PRIMARY KEY,
    disease_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL,
    severity_value INTEGER DEFAULT 1 NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    indication_date DATE, 
    effectiveness_percent DOUBLE PRECISION, 
    CONSTRAINT fk_fact_disease_patient_disease FOREIGN KEY (disease_id) REFERENCES FactDiseaseModel.dim_disease (disease_id1),
    CONSTRAINT fk_fact_disease_patient_person FOREIGN KEY (person_id) REFERENCES FactDiseaseModel.dim_person (person_id)
);
---Query to make indication_date column unique key
ALTER TABLE FactDiseaseModel.dim_indication
ADD CONSTRAINT unique_indication_date UNIQUE (indication_date);
--Query to make effectiveness_percent column unique key
ALTER TABLE FactDiseaseModel.dim_indication
ADD CONSTRAINT unique_effectiveness_percent UNIQUE (effectiveness_percent);
--Query to make foriegn key in fact table
ALTER TABLE FactDiseaseModel.fact_disease_patient
ADD CONSTRAINT fk_fact_disease_indication
FOREIGN KEY (indication_date) REFERENCES FactDiseaseModel.dim_indication (indication_date);
--Query to make foriegn key in fact table
ALTER TABLE FactDiseaseModel.fact_disease_patient
ADD CONSTRAINT fk_fact_disease_indication1
FOREIGN KEY (effectiveness_percent) REFERENCES FactDiseaseModel.dim_indication (effectiveness_percent);
-----------------------------------------------------------------------
-- Insert data into dim_medicine table from public.medicine table
INSERT INTO FactDiseaseModel.dim_medicine (standard_industry_number, name, company, active_ingredient_name)
SELECT standard_industry_number, name, company, active_ingredient_name
FROM public.medicine;

-- Insert data into dim_indication table from public.indication table
INSERT INTO FactDiseaseModel.dim_indication (medicine_id, disease_id2, indication_date, effectiveness_percent)
SELECT medicine_id, disease_id, indication_date, effectiveness_percent
FROM public.indication;


--Disease Dimension:
INSERT INTO FactDiseaseModel.dim_disease (name, intensity_level_qty, type_cd)
SELECT name, intensity_level_qty, type_cd
FROM public.disease;

--Person Dimension:
INSERT INTO FactDiseaseModel.dim_person (first_name, last_name, gender, date_of_birth, primary_location_id, race_cd)
SELECT first_name, last_name, gender, date_of_birth, primary_location_id, race_cd
FROM public.person;

--Location Dimension:
INSERT INTO FactDiseaseModel.dim_location (city_name, state_province, country_name, developing, wealth_rank_number)
SELECT city_name, state_province, country_name, developing, wealt_rank_number
FROM public.location;

--Race Dimension:

INSERT INTO FactDiseaseModel.dim_race (race_code, race_description)
SELECT race_code, race_description
FROM public.race;

--Disease Type Dimension:

INSERT INTO FactDiseaseModel.dim_disease_type (type_code, type_description, ex_other_note)
SELECT type_code, type_description, ex_other_note
FROM public.disease_type;

--Fact table Insertion

INSERT INTO FactDiseaseModel.fact_disease_patient (disease_id, person_id, severity_value, start_date, end_date, indication_date, effectiveness_percent)
SELECT
    d1.disease_id1, -- disease_id from dim_disease in FactDiseaseModel schema
    p.person_id,    -- person_id from dim_person in FactDiseaseModel schema
    dp.severity_value,
    dp.start_date,
    dp.end_date,
    i.indication_date,
    i.effectiveness_percent
FROM
    public.diseased_patient dp
JOIN
    FactDiseaseModel.dim_disease d1 ON dp.disease_id = d1.disease_id1
JOIN
    FactDiseaseModel.dim_person p ON dp.person_id = p.person_id
LEFT JOIN
    public.indication i ON dp.person_id = i.medicine_id AND dp.disease_id = i.disease_id;
-------------------------------------------
----DML Operations and Referential Behavior:

--INSERT Operation:
-- Insert a new disease into dim_disease
INSERT INTO FactDiseaseModel.dim_disease (name, intensity_level_qty, type_cd)
VALUES ('New Disease', 3, 'TYPE001');

-- Try to insert a patient with the newly inserted disease into fact_disease_patient
INSERT INTO FactDiseaseModel.fact_disease_patient (disease_id, person_id, severity_value, start_date, end_date)
VALUES ((SELECT MAX(disease_id1) FROM FactDiseaseModel.dim_disease), 1, 2, '2024-01-01', '2024-01-15');

--UPDATE Operation:
-- Update disease_id of a patient in fact_disease_patient
UPDATE FactDiseaseModel.fact_disease_patient
SET disease_id = 9999 -- Assume this disease_id does not exist in dim_disease
WHERE person_id = 1;

--DELETE Operation:
-- Try to delete a disease from dim_disease
DELETE FROM FactDiseaseModel.dim_disease
WHERE disease_id1 = 1; -- Assume this disease_id has associated records in fact_disease_patient
-------------------------------------------------
--Analytical FIndings
--Count the number of diseased patients:
SELECT COUNT(*) AS diseased_patient_count
FROM FactDiseaseModel.fact_disease_patient;

--List the top 10 diseases by severity:
SELECT d.name AS disease_name, COUNT(*) AS patient_count, AVG(severity_value) AS average_severity
FROM FactDiseaseModel.fact_disease_patient fp
JOIN FactDiseaseModel.dim_disease d ON fp.disease_id = d.disease_id1
GROUP BY d.name
ORDER BY average_severity DESC
LIMIT 10;

--Calculate the total number of patients by gender:
SELECT p.gender, COUNT(*) AS patient_count
FROM FactDiseaseModel.fact_disease_patient fp
JOIN FactDiseaseModel.dim_person p ON fp.person_id = p.person_id
GROUP BY p.gender;

--Calculate the average severity of diseases by gender:
SELECT p.gender, AVG(fp.severity_value) AS avg_severity
FROM FactDiseaseModel.fact_disease_patient fp
JOIN FactDiseaseModel.dim_person p ON fp.person_id = p.person_id
GROUP BY p.gender;

--Identify the top 5 most common diseases:
SELECT d.name AS disease_name, COUNT(*) AS patient_count
FROM FactDiseaseModel.fact_disease_patient fp
JOIN FactDiseaseModel.dim_disease d ON fp.disease_id = d.disease_id1
GROUP BY d.name
ORDER BY patient_count DESC
LIMIT 5;

--Calculate the average effectiveness of medicines by disease:
SELECT d.name AS disease_name, AVG(di.effectiveness_percent) AS avg_effectiveness
FROM FactDiseaseModel.fact_disease_patient fp
JOIN FactDiseaseModel.dim_indication di ON fp.disease_id = di.disease_id2
JOIN FactDiseaseModel.dim_disease d ON di.disease_id2 = d.disease_id1
GROUP BY d.name;

--Identify the distribution of diseases by country:
SELECT l.country_name, d.name AS disease_name, COUNT(*) AS patient_count
FROM FactDiseaseModel.fact_disease_patient fp
JOIN FactDiseaseModel.dim_person p ON fp.person_id = p.person_id
JOIN FactDiseaseModel.dim_location l ON p.primary_location_id = l.location_id
JOIN FactDiseaseModel.dim_disease d ON fp.disease_id = d.disease_id1
GROUP BY l.country_name, d.name
ORDER BY l.country_name, patient_count DESC;

--Find the average intensity level of diseases:
SELECT d.name AS disease_name, AVG(d.intensity_level_qty) AS avg_intensity_level
FROM FactDiseaseModel.fact_disease_patient fp
JOIN FactDiseaseModel.dim_disease d ON fp.disease_id = d.disease_id1
GROUP BY d.name;
----------------------------------------------------------
------Security
CREATE ROLE ShashankAdmin WITH LOGIN PASSWORD 'my_password' VALID UNTIL '2025-01-01';

--Grant Permissions: Grant appropriate permissions to users or roles for the tables 
--within the schema. For example, you might want to grant SELECT permissions to some users 
--and SELECT, INSERT, UPDATE, DELETE permissions to others.

-- Grant SELECT permission on all tables in the schema
GRANT SELECT ON ALL TABLES IN SCHEMA FactDiseaseModel TO ShashankAdmin;

-- Grant INSERT, UPDATE, DELETE permission on a specific table
GRANT INSERT, UPDATE, DELETE ON FactDiseaseModel.fact_disease_patient TO ShashankAdmin;

-- Revoke unnecessary privileges
REVOKE ALL ON ALL TABLES IN SCHEMA FactDiseaseModel FROM PUBLIC;

--- Set default privileges for future objects created within the schema to ensure 
----consistent access control.

ALTER DEFAULT PRIVILEGES IN SCHEMA FactDiseaseModel
GRANT SELECT ON TABLES TO ShashankAdmin ;
---------------------------------
-- View in FactDiseaseModel schema
CREATE VIEW FactDiseaseModel.vw_diseased_patients AS
SELECT fp.*, d.name AS disease_name, p.first_name, p.last_name
FROM FactDiseaseModel.fact_disease_patient fp
JOIN FactDiseaseModel.dim_disease d ON fp.disease_id = d.disease_id1
JOIN FactDiseaseModel.dim_person p ON fp.person_id = p.person_id;

-- Call views 
Select * from FactDiseaseModel.vw_diseased_patients

-- Trigger in FactDiseaseModel schema
CREATE OR REPLACE FUNCTION FactDiseaseModel.log_diseased_patient_changes()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO fact_disease_patient_audit (action, patient_id, action_timestamp)
        VALUES ('INSERT', NEW.id, NOW());
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO fact_disease_patient_audit (action, patient_id, action_timestamp)
        VALUES ('UPDATE', NEW.id, NOW());
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO fact_disease_patient_audit (action, patient_id, action_timestamp)
        VALUES ('DELETE', OLD.id, NOW());
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER tr_diseased_patient_changes
AFTER INSERT OR UPDATE OR DELETE ON FactDiseaseModel.fact_disease_patient
FOR EACH ROW
EXECUTE FUNCTION FactDiseaseModel.log_diseased_patient_changes();

-- Stored procedure in FactDiseaseModel schema
CREATE OR REPLACE FUNCTION FactDiseaseModel.get1_diseased_patient_count()
RETURNS INTEGER AS
$$
DECLARE
    patient_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO patient_count FROM FactDiseaseModel.fact_disease_patient;
    RETURN patient_count;
END;
$$
LANGUAGE plpgsql;

--Calling Function
Select * from FactDiseaseModel.get1_diseased_patient_count();
-----------------------------------------------------------
--Subquery
--We're joining fact_disease_patient with dim_person and dim_location to get the severity values of diseases for patients from developing countries.
--We filter the rows to include only patients from developing countries (l.developing = true).
--Finally, we calculate the average severity value of diseases for these patients.

SELECT
    AVG(fp.severity_value) AS avg_severity_developing_countries
FROM
    FactDiseaseModel.fact_disease_patient fp
JOIN
    FactDiseaseModel.dim_person p ON fp.person_id = p.person_id
JOIN
    FactDiseaseModel.dim_location l ON p.primary_location_id = l.location_id
WHERE
    l.developing = true;
----------------------------------------------
--CTE Example:
--In this CTE:

--We're calculating the average intensity level of diseases by joining dim_disease with fact_disease_patient on the disease ID.
--Then, in the main query, we select the disease names and their average intensity levels from the CTE.
--We order the results by average intensity level in descending order and limit the output to the top 5 diseases.
WITH DiseaseIntensityCTE AS (
    SELECT
        d.name AS disease_name,
        AVG(d.intensity_level_qty) AS avg_intensity_level
    FROM
        FactDiseaseModel.dim_disease d
    JOIN
        FactDiseaseModel.fact_disease_patient fp ON d.disease_id1 = fp.disease_id
    GROUP BY
        d.name
)
SELECT
    disease_name,
    avg_intensity_level
FROM
    DiseaseIntensityCTE
ORDER BY
    avg_intensity_level DESC
LIMIT
    5;
---------------------------------	


select * from FactDiseaseModel.dim_person
select * from FactDiseaseModel.dim_disease
select * from factdiseasemodel.dim_disease_type
select * from factdiseasemodel.dim_indication
select * from factdiseasemodel.dim_location
select * from factdiseasemodel.dim_medicine
select * from factdiseasemodel.dim_race
select * from factdiseasemodel.fact_disease_patient