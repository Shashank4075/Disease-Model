---- Crating Tables
CREATE  TABLE disease_type ( 
	type_code            varchar(5)  NOT NULL  ,
	type_description     varchar(1000)    ,
	ex_other_note        varchar(2000)    ,
	CONSTRAINT pk_disease_type PRIMARY KEY ( type_code )
 );

CREATE  TABLE "location" ( 
	location_id          serial  NOT NULL  ,
	city_name            varchar(100)  NOT NULL  ,
	state_province       varchar(100)    ,
	country_name         varchar(100)  NOT NULL  ,
	developing           boolean    ,
	wealt_rank_number    integer  NOT NULL  ,
	CONSTRAINT pk_tbl PRIMARY KEY ( location_id )
 );

CREATE  TABLE medicine ( 
	medicine_id          serial  NOT NULL  ,
	standard_industry_number varchar(25)    ,
	name                 varchar(250)  NOT NULL  ,
	company              varchar(150)    ,
	active_ingredient_name varchar(100)    ,
	CONSTRAINT pk_medicine PRIMARY KEY ( medicine_id )
 );

CREATE  TABLE public_table ( 
	id                   serial  NOT NULL  ,
	country              char(100)  NOT NULL  ,
	yr                   integer  NOT NULL  ,
	sex                  char(1)  NOT NULL  ,
	child                integer    ,
	elderly              integer    ,
	adult                integer    ,
	CONSTRAINT pk_public_table PRIMARY KEY ( id )
 );

CREATE  TABLE race ( 
	race_code            varchar(5)  NOT NULL  ,
	race_description     varchar(100)  NOT NULL  ,
	CONSTRAINT pk_race PRIMARY KEY ( race_code )
 );

CREATE  TABLE disease ( 
	id                   serial  NOT NULL  ,
	name                 varchar(100)  NOT NULL  ,
	intensity_level_qty  integer    ,
	type_cd              varchar(10)  NOT NULL  ,
	source_disease_cd    integer    ,
	CONSTRAINT pk_disease PRIMARY KEY ( id ),
	CONSTRAINT fk_disease_type_disease FOREIGN KEY ( type_cd ) REFERENCES disease_type( type_code ) ON DELETE CASCADE ON UPDATE CASCADE ,
	CONSTRAINT fk_disease_disease FOREIGN KEY ( source_disease_cd ) REFERENCES disease( id ) ON DELETE CASCADE ON UPDATE CASCADE 
 );

CREATE  TABLE indication ( 
	medicine_id          serial  NOT NULL  ,
	disease_id           integer  NOT NULL  ,
	indication_date      date    ,
	effectiveness_percent double precision    ,
	CONSTRAINT pk_indication PRIMARY KEY ( medicine_id ),
	CONSTRAINT unq_indication_medicine_id UNIQUE ( medicine_id, disease_id ) ,
	CONSTRAINT fk_indication_disease FOREIGN KEY ( disease_id ) REFERENCES disease( id ) ON DELETE CASCADE ON UPDATE CASCADE ,
	CONSTRAINT fk_indication_medicine FOREIGN KEY ( medicine_id ) REFERENCES medicine( medicine_id ) ON DELETE CASCADE ON UPDATE CASCADE 
 );

CREATE  TABLE person ( 
	person_id            serial  NOT NULL  ,
	first_name           varchar(100)    ,
	last_name            varchar(100)  NOT NULL  ,
	gender               varchar(1)  NOT NULL  ,
	primary_location_id  integer    ,
	race_cd              varchar(5)    ,
	CONSTRAINT pk_person PRIMARY KEY ( person_id ),
	CONSTRAINT fk_person_location FOREIGN KEY ( primary_location_id ) REFERENCES "location"( location_id ) ON DELETE CASCADE ON UPDATE CASCADE ,
	CONSTRAINT fk_person_race FOREIGN KEY ( race_cd ) REFERENCES race( race_code ) ON DELETE CASCADE ON UPDATE CASCADE 
 );

CREATE  TABLE race_disease_propensity ( 
	race_code            varchar(5)  NOT NULL  ,
	disease_id           integer    ,
	propensity_value     integer    ,
	CONSTRAINT pk_race_disease_propensity PRIMARY KEY ( race_code ),
	CONSTRAINT unq_race_disease_propensity UNIQUE ( race_code, disease_id ) ,
	CONSTRAINT fk_disease_race_disease_propensity FOREIGN KEY ( disease_id ) REFERENCES disease( id ) ON DELETE CASCADE ON UPDATE CASCADE ,
	CONSTRAINT fk_race_race_disease_propensity FOREIGN KEY ( race_code ) REFERENCES race( race_code ) ON DELETE CASCADE ON UPDATE CASCADE 
 );

CREATE  TABLE diseased_patient ( 
	person_id            integer  NOT NULL  unique,
	disease_id           integer  NOT NULL  unique,
	severity_value       integer DEFAULT 1 NOT NULL  ,
	start_date           date  NOT NULL  ,
	end_date             date    ,
	CONSTRAINT pk_diseased_patient PRIMARY KEY ( person_id ),
	CONSTRAINT unq_diseased_patient UNIQUE ( person_id, disease_id ) ,
	CONSTRAINT fk_disease_diseased_patient FOREIGN KEY ( disease_id ) REFERENCES disease( id ) ON DELETE CASCADE ON UPDATE CASCADE ,
	CONSTRAINT fk_diseased_patient_person FOREIGN KEY ( person_id ) REFERENCES person( person_id ) ON DELETE CASCADE ON UPDATE CASCADE 
 );
-----------------------------------------------------------------------

-- Insert data into Race table
INSERT INTO public.race (race_code, race_description) VALUES
    ('WHITE', 'White'),
    ('BLACK', 'Black or African American'),
    ('HISP', 'Hispanic or Latino'),
    ('ASIAN', 'Asian'),
    ('OTHER', 'Other');

-- Insert data into Disease Type table
INSERT INTO public.disease_type (type_code, type_description, ex_other_note) VALUES
    ('VIRAL', 'Viral Infections', 'N/A'),
    ('METAB', 'Metabolic Disorders', 'N/A'),
    ('CARDV', 'Cardiovascular Diseases', 'N/A'),
    ('RESP', 'Respiratory Disorders', 'N/A'),
    ('IMMUN', 'Immunological Disorders', 'N/A');

-- Insert data into Location table
INSERT INTO public.location (city_name, state_province, country_name, developing, wealt_rank_number) VALUES
    ('New York', 'New York', 'USA', FALSE, 8),
    ('Los Angeles', 'California', 'USA', FALSE, 7),
    ('London', NULL, 'UK', FALSE, 9),
    ('Paris', NULL, 'France', FALSE, 8),
    ('Tokyo', NULL, 'Japan', FALSE, 10),
	('Kathmandu', 'Bagamati', 'Nepal', TRUE, 10);
	
-- Insert data into Person table
INSERT INTO public.person (first_name, last_name, gender, primary_location_id, race_cd) VALUES
    ('John', 'Doe', 'M', 1, 'WHITE'),
    ('Jane', 'Smith', 'F', 2, 'BLACK'),
    ('Michael', 'Johnson', 'M', 3, 'HISP'),
    ('Emily', 'Brown', 'F', 4, 'OTHER'),
    ('David', 'Lee', 'M', 5, 'ASIAN');
	
-- Insert data into Disease table
INSERT INTO public.disease (name, intensity_level_qty, type_cd, source_disease_cd) VALUES
    ('Common Cold', 2, 'VIRAL', NULL),
    ('Diabetes', 3, 'METAB', NULL),
    ('Hypertension', 4, 'CARDV', NULL),
    ('Asthma', 3, 'RESP', NULL),
    ('Arthritis', 2, 'IMMUN', NULL);
	
	
-- Insert data into Diseased Patient table
INSERT INTO public.diseased_patient (person_id, disease_id, severity_value, start_date, end_date) VALUES
    (1, 1, 2, '2024-01-15', NULL),
    (2, 2, 3, '2024-02-20', NULL),
    (3, 3, 4, '2024-03-10', '2024-03-14'),
    (4, 4, 3, '2024-04-05', NULL),
    (5, 5, 2, '2024-05-12', NULL);
	
	
-- Insert data into Race Disease Propensity table
INSERT INTO public.race_disease_propensity (race_code, disease_id, propensity_value) VALUES
    ('WHITE', 1, 80),
    ('BLACK', 2, 75),
    ('HISP', 3, 70),
    ('ASIAN', 4, 85),
    ('OTHER', 5, 80);
	

-- Insert data into Medicine table
INSERT INTO public.medicine (standard_industry_number, name, company, active_ingredient_name) VALUES
    ('123456', 'Tylenol', 'Johnson & Johnson', 'Acetaminophen'),
    ('234567', 'Advil', 'Pfizer', 'Ibuprofen'),
    ('345678', 'Zyrtec', 'Bayer', 'Cetirizine'),
    ('456789', 'Claritin', 'Merck', 'Loratadine'),
    ('567890', 'Benadryl', 'GSK', 'Diphenhydramine');
	

-- Insert data into Indication table
INSERT INTO public.indication (medicine_id, disease_id, indication_date, effectiveness_percent) VALUES
    (1, 1, '2024-01-20', 90.5),
    (2, 2, '2024-02-25', 85.3),
    (3, 3, '2024-03-15', 92.1),
    (4, 4, '2024-04-10', 88.7),
    (5, 5, '2024-05-15', 91.2);


-- Insert data into Public Table
INSERT INTO public.public_table (country, yr, sex, child, elderly, adult) VALUES
    ('USA', 2023, 'M', 100, 50, 150),
    ('USA', 2023, 'F', 90, 60, 140),
    ('UK', 2023, 'M', 80, 40, 120),
    ('UK', 2023, 'F', 70, 45, 115),
    ('Japan', 2023, 'M', 120, 55, 175);
--Add 	date_of_birth in person table
ALTER TABLE public.person
ADD COLUMN date_of_birth DATE;

-- Update date of birth for each person
UPDATE public.person
SET date_of_birth = 
    CASE 
        WHEN person_id = 1 THEN Date'1990-05-15'
        WHEN person_id = 2 THEN Date'1985-08-20'
        WHEN person_id = 3 THEN Date'1978-02-10'
		WHEN person_id = 4 THEN Date'1968-05-11'
		WHEN person_id = 5 THEN Date'1998-02-01'
		WHEN person_id = 6 THEN Date'1975-07-04'
		WHEN person_id = 7 THEN Date'1974-06-05'
		WHEN person_id = 8 THEN Date'1993-06-13'
		WHEN person_id = 9 THEN Date'1982-05-24'
        -- Add more WHEN clauses for each person
        ELSE null  -- Set default value if necessary
    END
WHERE person_id IN (1, 2, 3,4,5,6,7,8,9); -- Specify person IDs here
	

-- Alter the columns in the disease_type table
ALTER TABLE public.disease_type
    ALTER COLUMN type_code TYPE varchar(20),
    ALTER COLUMN type_description TYPE varchar(1000),
    ALTER COLUMN ex_other_note TYPE varchar(2000);

-- Alter the columns in the location table
ALTER TABLE public.location
    ALTER COLUMN city_name TYPE varchar(100),
    ALTER COLUMN state_province TYPE varchar(100),
    ALTER COLUMN country_name TYPE varchar(100);

-- Alter the columns in the person table
ALTER TABLE public.person
    ALTER COLUMN first_name TYPE varchar(100),
    ALTER COLUMN last_name TYPE varchar(100),
    ALTER COLUMN gender TYPE varchar(1),
	Alter COLUMN race_cd Type varchar(100);

-- Alter the columns in the race table
ALTER TABLE public.race
    ALTER COLUMN race_code TYPE varchar(20),
    ALTER COLUMN race_description TYPE varchar(100);

-- Alter the columns in the disease table
ALTER TABLE public.disease
    ALTER COLUMN name TYPE varchar(100),
    ALTER COLUMN type_cd TYPE varchar(10);

-- Alter the columns in the diseased_patient table
ALTER TABLE public.diseased_patient
    ALTER COLUMN start_date TYPE date,
    ALTER COLUMN end_date TYPE date;

-- Alter the columns in the medicine table
ALTER TABLE public.medicine
    ALTER COLUMN standard_industry_number TYPE varchar(25),
    ALTER COLUMN name TYPE varchar(250),
    ALTER COLUMN company TYPE varchar(150),
    ALTER COLUMN active_ingredient_name TYPE varchar(100);

-- Alter the columns in the indication table
ALTER TABLE public.indication
    ALTER COLUMN indication_date TYPE date;

-- Alter the columns in the public_table table
ALTER TABLE public.public_table
    ALTER COLUMN country TYPE char(100);
	
-- Insert 5 more rows into Race table
INSERT INTO public.race (race_code, race_description) VALUES
    ('INDIAN', 'Indian'),
    ('CHINESE', 'Chinese'),
    ('LATINX', 'Latinx'),
    ('MIDDLE_EASTERN', 'Middle Eastern'),
    ('PACIFIC_ISLANDER', 'Pacific Islander');

-- Insert 5 more rows into Disease Type table
INSERT INTO public.disease_type (type_code, type_description, ex_other_note) VALUES
    ('CANCER', 'Cancer', 'N/A'),
    ('NEURO', 'Neurological Disorders', 'N/A'),
    ('DERM', 'Dermatological Disorders', 'N/A'),
    ('GENETIC', 'Genetic Disorders', 'N/A'),
    ('MENTAL', 'Mental Health Disorders', 'N/A');

-- Insert 5 more rows into Location table
INSERT INTO public.location (city_name, state_province, country_name, developing, wealt_rank_number) VALUES
    ('Sydney', NULL, 'Australia', FALSE, 9),
    ('Toronto', 'Ontario', 'Canada', FALSE, 8),
    ('Berlin', NULL, 'Germany', FALSE, 8),
    ('São Paulo', NULL, 'Brazil', TRUE, 7),
    ('Mumbai', 'Maharashtra', 'India', TRUE, 6);

-- Insert 5 more rows into Person table
INSERT INTO public.person (first_name, last_name, gender, primary_location_id, race_cd) VALUES
    ('Maria', 'Garcia', 'F', 6, 'LATINX'),
    ('Chen', 'Wei', 'M', 7, 'CHINESE'),
    ('Satoshi', 'Tanaka', 'M', 8, 'ASIAN'),
    ('Fatima', 'Ali', 'F', 9, 'MIDDLE_EASTERN'),
    ('Rajesh', 'Patel', 'M', 10, 'INDIAN');

-- Insert 5 more rows into Disease table
INSERT INTO public.disease (name, intensity_level_qty, type_cd, source_disease_cd) VALUES
    ('Lung Cancer', 5, 'CANCER', NULL),
    ('Alzheimer''s Disease', 4, 'NEURO', NULL),
    ('Psoriasis', 3, 'DERM', NULL),
    ('Cystic Fibrosis', 4, 'GENETIC', NULL),
    ('Depression', 3, 'MENTAL', NULL);

-- Insert 5 more rows into Diseased Patient table
INSERT INTO public.diseased_patient (person_id, disease_id, severity_value, start_date, end_date) VALUES
    (6, 6, 5, '2024-06-01', NULL),
    (7, 7, 4, '2024-06-15', NULL),
    (8, 8, 3, '2024-07-01', NULL),
    (9, 9, 4, '2024-07-15', NULL),
    (10, 10, 3, '2024-08-01', NULL);

-- Insert 5 more rows into Race Disease Propensity table
INSERT INTO public.race_disease_propensity (race_code, disease_id, propensity_value) VALUES
    ('INDIAN', 6, 70),
    ('CHINESE', 7, 75),
    ('LATINX', 8, 80),
    ('MIDDLE_EASTERN', 9, 65),
    ('PACIFIC_ISLANDER', 10, 70);

-- Insert 5 more rows into Medicine table
INSERT INTO public.medicine (standard_industry_number, name, company, active_ingredient_name) VALUES
    ('678901', 'Aspirin', 'Bayer', 'Acetylsalicylic Acid'),
    ('789012', 'Nexium', 'AstraZeneca', 'Esomeprazole'),
    ('890123', 'Prozac', 'Eli Lilly', 'Fluoxetine'),
    ('901234', 'Adderall', 'Shire', 'Amphetamine'),
    ('012345', 'Lipitor', 'Pfizer', 'Atorvastatin');

-- Insert 5 more rows into Indication table
INSERT INTO public.indication (medicine_id, disease_id, indication_date, effectiveness_percent) VALUES
    (6, 6, '2024-06-05', 88.9),
    (7, 7, '2024-06-20', 85.2),
    (8, 8, '2024-07-05', 90.1),
    (9, 9, '2024-07-20', 86.5),
    (10, 10, '2024-08-05', 91.8);

-- Insert 5 more rows into Public Table
INSERT INTO public.public_table (country, yr, sex, child, elderly, adult) VALUES
    ('Australia', 2023, 'M', 110, 65, 175),
    ('Australia', 2023, 'F', 100, 70, 160),
    ('Canada', 2023, 'M', 90, 55, 145),
    ('Canada', 2023, 'F', 80, 60, 140),
    ('Germany', 2023, 'M', 100, 50, 150);
----------------------------------------------------------------------------------------------------	
--DML Operations and Referential Behavior:

--Let's perform some DML operations to simulate business changes:

--Update a Patient's Disease Severity:
--Let's update the severity of a patient's disease
UPDATE public.diseased_patient
SET severity_value = 2
WHERE person_id = 1;

--Insert a New Disease Type:
--Let's insert a new disease type into the database.
INSERT INTO public.disease_type (type_code, type_description, ex_other_note) 
VALUES ('NEURO', 'Neurological Disorders', 'N/A');

--Delete a Race from the Race Table:
--Let's delete a race from the race table and observe the referential behavior.
DELETE FROM public.race WHERE race_code = 'INDIAN';
---------------------------------------------------------------
--Views
-- View in public schema
CREATE VIEW public.vw_diseased_patients AS
SELECT *
FROM diseased_patient;

-- Call the stored procedure in the public schema
select * from public.vw_diseased_patients;


-- Trigger in public schema
CREATE OR REPLACE FUNCTION public.log_diseased_patient_changes()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO diseased_patient_audit (action, patient_id, action_timestamp)
        VALUES ('INSERT', NEW.id, NOW());
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO diseased_patient_audit (action, patient_id, action_timestamp)
        VALUES ('UPDATE', NEW.id, NOW());
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO diseased_patient_audit (action, patient_id, action_timestamp)
        VALUES ('DELETE', OLD.id, NOW());
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER tr_diseased_patient_changes
AFTER INSERT OR UPDATE OR DELETE ON public.diseased_patient
FOR EACH ROW
EXECUTE FUNCTION public.log_diseased_patient_changes();

-- Stored procedure in public schema
CREATE OR REPLACE FUNCTION public.get_diseased_patient_count()
RETURNS INTEGER AS
$$
DECLARE
    patient_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO patient_count FROM diseased_patient;
    RETURN patient_count;
END;
$$
LANGUAGE plpgsql;
--Calling Function
Select * from  public.get_diseased_patient_count();

---------------------------------------------------------------
--Let's address some potential business problems using SQL queries:

--Identifying High-Risk Patients:
--Problem: The healthcare provider wants to identify patients who are at high risk due to the severity of their diseases.
--Solution: This query selects patients with diseases having a severity level above a certain threshold.

SELECT p.first_name, p.last_name, d.name AS disease_name, dp.severity_value
FROM public.diseased_patient dp
JOIN public.person p ON dp.person_id = p.person_id
JOIN public.disease d ON dp.disease_id = d.id
WHERE dp.severity_value > 3;
--Medicine Effectiveness Analysis:
--Problem: The pharmacy department needs to analyze the effectiveness of different medicines for specific diseases.
--Solution: This query calculates the average effectiveness of each medicine for a particular disease.

SELECT m.name AS medicine_name, d.name AS disease_name, AVG(i.effectiveness_percent) AS avg_effectiveness
FROM public.indication i
JOIN public.medicine m ON i.medicine_id = m.medicine_id
JOIN public.disease d ON i.disease_id = d.id
GROUP BY m.name, d.name;
--Patient Demographics Analysis:
--Problem: The marketing team wants to understand the demographics of patients for targeted campaigns.
--Solution: This query provides demographic insights such as age distribution and race of patients.

SELECT 
    ROUND(EXTRACT(YEAR FROM AGE(current_date, p.date_of_birth)) / 10) * 10 AS age_group,
    r.race_description,
    COUNT(*) AS patient_count
FROM 
    public.person p
JOIN 
    public.race r ON p.race_cd = r.race_code
GROUP BY 
    age_group, r.race_description
ORDER BY 
    age_group, r.race_description;
--Location-Based Disease Prevalence:
--Problem: The public health department wants to identify regions with a high prevalence of certain diseases.
--Solution: This query lists the top diseases and their prevalence in different cities.

SELECT 
    l.city_name, 
    d.name AS disease_name, 
    COUNT(*) AS patient_count
FROM 
    public.diseased_patient dp
JOIN 
    public.person p ON dp.person_id = p.person_id
JOIN 
    public.location l ON p.primary_location_id = l.location_id
JOIN 
    public.disease d ON dp.disease_id = d.id
GROUP BY 
    l.city_name, d.name
ORDER BY 
    l.city_name, patient_count DESC;
--These queries address various business problems by providing actionable insights 
--from the database. Adjustments can be made to these queries based on specific business 
--requirements and data availability.

--Report on Diseased Patients:
--This report lists details about patients who are currently diagnosed with diseases.
SELECT p.first_name, p.last_name, d.name AS disease_name, dp.severity_value, dp.start_date, dp.end_date
FROM public.diseased_patient dp
JOIN public.person p ON dp.person_id = p.person_id
JOIN public.disease d ON dp.disease_id = d.id;

--Report on Medicines and Indications:
--This report lists medicines along with the diseases they're indicated for and their effectiveness.
SELECT m.name AS medicine_name, d.name AS disease_name, i.indication_date, i.effectiveness_percent
FROM public.indication i
JOIN public.medicine m ON i.medicine_id = m.medicine_id
JOIN public.disease d ON i.disease_id = d.id;

--Report on Race Disease Propensity:
--This report shows the propensity of different races towards certain diseases.
SELECT r.race_description, d.name AS disease_name, rdp.propensity_value
FROM public.race_disease_propensity rdp
JOIN public.race r ON rdp.race_code = r.race_code
JOIN public.disease d ON rdp.disease_id = d.id;

--Top Diseases by Severity:
--This query helps identify the most severe diseases based on the average severity level among patients.


SELECT d.name AS disease_name, AVG(dp.severity_value) AS avg_severity
FROM public.diseased_patient dp
JOIN public.disease d ON dp.disease_id = d.id
GROUP BY d.name
ORDER BY avg_severity DESC;

--Distribution of Patients by Race:
--This query provides insights into the distribution of patients across different races.

SELECT r.race_description, COUNT(*) AS patient_count
FROM public.person p
JOIN public.race r ON p.race_cd = r.race_code
GROUP BY r.race_description;

--Effectiveness of Medicines by Disease Type:
--This query shows the average effectiveness of medicines for each disease type.

SELECT dt.type_description, AVG(i.effectiveness_percent) AS avg_effectiveness
FROM public.indication i
JOIN public.disease d ON i.disease_id = d.id
JOIN public.disease_type dt ON d.type_cd = dt.type_code
GROUP BY dt.type_description;
--Population Health Metrics by Country:
--This query provides population health metrics such as the average number of children, elderly, and adults by country.

SELECT country, 
       AVG(child) AS avg_children, 
       AVG(elderly) AS avg_elderly, 
       AVG(adult) AS avg_adult
FROM public.public_table
GROUP BY country;
--Patients with Ongoing Diseases:
--This query identifies patients who are currently suffering from diseases without an end date.

SELECT p.first_name, p.last_name, d.name AS disease_name, dp.severity_value
FROM public.diseased_patient dp
JOIN public.person p ON dp.person_id = p.person_id
JOIN public.disease d ON dp.disease_id = d.id
WHERE dp.end_date IS NULL;
--------------------------------------------------------------------------
select * from indication
select * from person
select * from public.disease
select * from public.disease_type
select * from public.diseased_patient
select * from public.location
select * from public.medicine
select * from public.public_table
select * from public.race
select * from public.race_disease_propensity




