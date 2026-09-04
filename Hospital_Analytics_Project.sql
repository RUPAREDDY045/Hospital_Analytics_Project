# Hospital Patient Care Operations Analytics

CREATE DATABASE hostital_analytics;
USE hostital_analytics;

-- 1. Doctors

CREATE TABLE doctors (
	doctor_id VARCHAR(10) PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    speciality VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    rating DECIMAL(3, 2),
    employement_type VARCHAR(20) NOT NULL,
    is_active VARCHAR(3)
);

-- 2. Patients

CREATE TABLE patients (
	patient_id VARCHAR(20) PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    city VARCHAR(50) NOT NULL,
    patient_type VARCHAR(20) NOT NULL,
    preferred_time_slot VARCHAR(20) NOT NULL,
    registration_date DATE NOT NULL
);

-- 3. Rooms

CREATE TABLE rooms (
	room_id VARCHAR(10) PRIMARY KEY,
    room_type VARCHAR(30) NOT NULL,
    floor INT NOT NULL,
    eqipment_type VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    last_maintenance_data DATE,
    is_available VARCHAR(3)
);

-- 4. Appointments

CREATE TABLE appointments (
	appointment_id VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(20) NOT NULL,
    appointment_date DATE NOT NULL,
    doctor_id VARCHAR(10) NOT NULL,
    service_type VARCHAR(30) NOT NULL,
    priority VARCHAR(10) NOT NULL,
    estimatied_cost DECIMAL(10, 2) NOT NULL,
    booking_channel VARCHAR(20) NOT NULL,
    CONSTRAINT fk_appointments_patients
	FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id),
    CONSTRAINT fk_appointments_doctors
    FOREIGN KEY (doctor_id)
    REFERENCES doctors(doctor_id)
);

-- 5. Treatments

CREATE TABLE treatments (
	treatment_id VARCHAR(20) PRIMARY KEY,
    appointment_id VARCHAR(20) NOT NULL,
    doctor_id VARCHAR(10) NOT NULL,
    room_id VARCHAR(10) NOT NULL,
    actual_treatment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    treatment_attempt INT NOT NULL,
    treatment_duration_min INT NOT NULL,
    waiting_time_min INT NOT NULL,
    treatment_cost DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_treatments_appointments
    FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id),
    CONSTRAINT fk_treatments_doctors
    FOREIGN KEY (doctor_id)
    REFERENCES doctors(doctor_id),
    CONSTRAINT fk_treatments_rooms
    FOREIGN KEY (room_id)
    REFERENCES rooms(room_id)
);

select * from doctors;
select * from patients;
select * from rooms;
select * from appointments;
select * from treatments;

-- Sprint 3: Basic Analysis / Data Exploration
-- 1. What is the total number of patients?
select count(distinct patient_id) as total_patients from patients;

-- 2. What is the total number of appointments?
select count(*) as total_appointments from appointments;

-- 3. What is the total number of treatment records?
select count(*) as total_treatments from treatments;

-- 4. What are the different medical service types?
select distinct service_type from appointments;

-- 5. How many doctors are currently active?
select count(*) as active_doctors from doctors where is_active = 'yes';

-- 6. What are the different room types?
select distinct room_type from rooms;

-- 7. What is the total estimated appointment value?
select sum(estimatied_cost) as total_estimated_value from appointments;

-- 8. What is the average treatment duration?
select avg(treatment_duration_min) as average_treatment_time from treatments;

-- SPRINT 4
-- 4.1 Understand Patient and Appointment Demand
-- Compare appointment volume across cities.
select p.city, count(a.appointment_id) as appointment_count from 
appointments as a join patients as p on a.patient_id = p.patient_id 
group by p.city order by appointment_count desc;

-- Compare appointments across service types and priorities.
select service_type, priority, count(*) as appointment_count from 
appointments group by service_type, priority order by service_type, priority;

-- Examine appointment volume over time.
select date_format(appointment_date, '%Y-%m') as month, count(*) as appointment_count
from appointments group by month order by month;

-- Compare estimated appointment value across patient types.
select p.patient_type, sum(a.estimatied_cost) as total_appointment_value from appointments as a
join patients as p on a.patient_id = p.patient_id group by p.patient_type;

-- Examine booking channels and their contribution to demand.
select booking_channel, count(*) as appointment_count, sum(estimatied_cost) as 
total_value from appointments group by booking_channel order by appointment_count desc;

-- 4.2 Understand Ptient Appointment Behaviour
-- Compare patients by number of appointments.
select patient_id, count(*) as appointment_count from appointments
group by patient_id order by appointment_count desc limit 10;

-- Identify patients with higher cumlative estimated appointment value.
select patient_id, sum(estimatied_cost) as appointment_value 
from appointments group by patient_id
order by appointment_value desc limit 10;

-- Compare patient activity across cities.
select p.city, count(a.appointment_id) as appointment_count from appointments as a
join patients as p on a.patient_id = p.patient_id group by p.city;

-- Compare General, Corporate, and Insurance patients.
select p.patient_type, count(a.appointment_id) as appointment_count, 
sum(a.estimatied_cost) as total_value from appointments 
as a join patients as p on a.patient_id = p.patient_id
group by p.patient_type;

-- Examine patient booking patterns over time.
select date_format(appointment_date, '%Y-%m') as month, count(*) as appointment_count
from appointments group by month;

-- 4.3 Evaluate treatment Performace
-- Compare treatment outcomes across cities.
select p.city, t.status, count(*) as treatment_count from treatments as t
join appointments as a on t.appointment_id = a.appointment_id
join patients as p on a.patient_id = p.patient_id group by p.city, t.status;

-- Examine treatment duration and waiting time.
select avg(treatment_duration_min) as avg_duration, 
avg(waiting_time_min) as avg_waiting from treatments;

-- Compare Completed, Cancelled, No-Show, Rescheduled, and In Pregress outcomes.
select status, count(*) as count from treatments group by status;

-- Identify areas with higher treatment activity or proper outcomes.
select p.city, count(t.treatment_id) as treatment_count from treatments as t
join appointments as a on t.appointment_id = a.appointment_id
join patients as p on a.patient_id = p.patient_id group by p.city
order by treatment_count desc;



-- 4.4 Understand doctor and Room Performance
-- Compare the number of treatments handled by doctors.
select doctor_id, count(*) as treatment_count from treatments group by doctor_id
order by treatment_count desc;

-- Compare doctor performance across treatment oucomes.
select doctor_id, status, count(*) as count from treatments group by doctor_id, status;

-- Examine treatment duration across doctors.
select doctor_id, avg(treatment_duration_min) as avg_duration from treatments group by doctor_id;

-- Compare room usage across room types and equipment types.
select r.room_type, r.eqipment_type, count(t.treatment_id) as usage_count from treatments as t
join rooms as r on t.room_id = r.room_id group by r.room_type, r.eqipment_type;

-- 4.5 Identify Treatment and Appointment Prolems
-- Identify appointments requiring multiple treatment attempts.
select appointment_id, count(*) as attempts from treatments
group by appointment_id having attempts > 1;

-- Find common problem statuses and patterns.
select status, count(*) as count from treatments 
group by status order by count desc;

-- Compare waiting time for appointments with multiple attempts.
select appointment_id, avg(waiting_time_min) as avg_waiting from treatments
group by appointment_id having count(*) > 1;

-- Identify cities or service types with more cancellations, no-shows, or rescheduling.
select a.service_type, t.status, count(*) as count_status from appointments as a
join treatments as t on a.appointment_id = t.appointment_id
where t.status in ('Cancelled','No-Show','Rescheduled') group by a.service_type, t.status;

-- Investigate whether priority level is associated with waiting time or treatment outcomes.
select a.priority, avg(t.waiting_time_min) as avg_waiting, t.status from appointments as a
join treatments t on a.appointment_id = t.appointment_id group by a.priority, t.status;