create database healthcare_analytics;
use healthcare_analytics;
 select * from medical_appointment_no_shows 
 limit 10;
 ALTER TABLE medical_appointment_no_shows
    CHANGE COLUMN Hipertension Hypertension int,
    CHANGE COLUMN Handcap Disability_count int,
    CHANGE COLUMN `No-show` No_show VARCHAR(3);
    
Select 
	ScheduledDay,
    AppointmentDay
From medical_appointment_no_shows
Limit 10;

ALTER TABLE medical_appointment_no_shows
    ADD COLUMN ScheduledDay_clean DATETIME,
    ADD COLUMN AppointmentDay_clean DATE;

-- Disable Safe Update mode
SET SQL_SAFE_UPDATES = 0;

-- Execute the update code
UPDATE medical_appointment_no_shows
SET ScheduledDay_clean = STR_TO_DATE(REPLACE(REPLACE(ScheduledDay, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s'),
    AppointmentDay_clean = STR_TO_DATE(REPLACE(REPLACE(AppointmentDay, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s');


Alter Table medical_appointment_no_shows
Drop column ScheduledDay,
Drop column AppointmentDay;

ALTER TABLE medical_appointment_no_shows
	CHANGE COLUMN ScheduledDay_clean ScheduledDay DATETIME,
	CHANGE COLUMN AppointmentDay_clean AppointmentDay DATE;
    
Select 
	ScheduledDay,
    AppointmentDay
From medical_appointment_no_shows
Limit 10;

SELECT
	MIN(AGE), 
    MAX(AGE)
FROM medical_appointment_no_shows; 

DELETE FROM medical_appointment_no_shows 
WHERE AGE = -1;

SELECT
	MIN(AGE), 
    MAX(AGE)
FROM medical_appointment_no_shows;

ALTER TABLE medical_appointment_no_shows ADD COLUMN lead_time_days INT;

UPDATE medical_appointment_no_shows
SET lead_time_days = DATEDIFF(AppointmentDay, DATE(ScheduledDay));

SELECT
	MIN(lead_time_days), 
    MAX(lead_time_days)
FROM medical_appointment_no_shows;

SELECT * FROM medical_appointment_no_shows
WHERE lead_time_days < 0;

DELETE FROM medical_appointment_no_shows
WHERE lead_time_days < 0;

-- Data Exploration
-- 1: What's our overall no-show rate?
 
SELECT
	no_show, 
    COUNT(*) as total_appointments, 
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM medical_appointment_no_shows), 2) as pct_of_total
FROM medical_appointment_no_shows
GROUP BY no_show;

-- 2: Does the day of the week matter

SELECT
	DAYNAME(AppointmentDay) as appointment_day, 
    COUNT(*) as total_appointments, 
    SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) as no_shows,
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as rate_of_no_shows
FROM medical_appointment_no_shows
GROUP BY DAYNAME(AppointmentDay)
ORDER BY rate_of_no_shows DESC;

-- 3: Does lead time matter

-- same day
-- 1-3 days
-- within a week (4-7 days)
-- long lead (8+ days)

SELECT
	CASE
		WHEN lead_time_days = 0 THEN 'Same Day'
        WHEN lead_time_days BETWEEN 1 AND 3 THEN 'Short (1-3 Days)'
		WHEN lead_time_days BETWEEN 4 AND 7 THEN 'Within a week'
        ELSE 'Long Lead (8+ days)'
	END AS lead_time_bucket, 
	COUNT(*) as total_appointments, 
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as no_show_rate
FROM medical_appointment_no_shows
GROUP BY lead_time_bucket
ORDER BY no_show_rate DESC;

-- 4: Age groups

-- child 0-12
-- teen (13-19)
-- young adult (20-39)
-- adult (40-59)

SELECT
	CASE
		WHEN Age BETWEEN 0 AND 12 THEN 'Child'
		WHEN Age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN Age BETWEEN 20 AND 39 THEN 'Young Adult'
        WHEN Age BETWEEN 40 AND 59 THEN 'Adult'
		ELSE 'Senior'
	END AS age_group, 
    COUNT(*) as total_appointments,
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as no_show_rate
FROM medical_appointment_no_shows
GROUP BY age_group
ORDER BY no_show_rate DESC;

-- 5: Do SMS reminders help
SELECT
	CASE WHEN sms_received = 1 THEN 'Received SMS' ELSE 'No SMS' 
    END AS sms_status,
    COUNT(*) as total_appointments,
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as no_show_rate
FROM medical_appointment_no_shows
GROUP BY sms_status;

-- 6: Which neighborhoods have the highest risk? 

 SELECT
	Neighbourhood, 
    COUNT(*) as total_appointments, 
    ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as no_show_rate, 
    RANK() OVER (ORDER BY ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) DESC) as risk_rank
	FROM medical_appointment_no_shows
    GROUP BY Neighbourhood
    HAVING COUNT(*) >= 100
    ORDER BY no_show_rate DESC
    LIMIT 15;
    
-- Patient-level risk scoring

SELECT
	patientid, 
    appointmentid, 
    appointmentday, 
    no_show, 
    COUNT(*) OVER (
		PARTITION BY PatientID
        ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) as prior_appointments,
	SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) OVER 
		(PARTITION BY PatientID
        ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) as prior_no_shows
	FROM medical_appointment_no_shows
    ORDER BY patientid, appointmentday;
    
    
    
CREATE VIEW v_appointment_risk AS
WITH patient_history AS (
    SELECT
        PatientId,
        AppointmentID,
        AppointmentDay,
        Neighbourhood,
        lead_time_days,
        sms_received,
        Scholarship,
        no_show,
        COUNT(*) OVER (
            PARTITION BY PatientId 
            ORDER BY AppointmentDay 
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_appointments,
        SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) OVER (
            PARTITION BY PatientId 
            ORDER BY AppointmentDay 
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_no_shows
    FROM medical_appointment_no_shows
)
SELECT
    PatientId,
    AppointmentID,
    AppointmentDay,
    Neighbourhood,
    lead_time_days,
    prior_appointments,
    prior_no_shows,
    ROUND(prior_no_shows / NULLIF(prior_appointments, 0), 2) AS prior_no_show_rate,
    CASE
        WHEN prior_appointments = 0 THEN 'New Patient - Monitor'
        WHEN (prior_no_shows / NULLIF(prior_appointments, 0)) >= 0.5 
             OR lead_time_days >= 8 THEN 'High Risk'
        WHEN (prior_no_shows / NULLIF(prior_appointments, 0)) >= 0.2 
             OR lead_time_days BETWEEN 4 AND 7 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_tier
FROM patient_history;

SELECT
* 
FROM v_appointment_risk
WHERE risk_tier = 'High Risk'
ORDER BY AppointmentDay
Limit 50;


select * from medical_appointment_no_shows;
select * from v_appointment_risk;