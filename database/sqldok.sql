SELECT last_name, first_name, birth_date, address
FROM myschema.patients
WHERE address LIKE '%г. Муром%'
ORDER BY last_name;

SELECT doctor_id, last_name, first_name, specialty, experience 
FROM myschema.doctors 
WHERE specialty = 'Хирург';

SELECT p.last_name, p.first_name, p.birth_date
FROM myschema.patients p
WHERE p.patient_id IN (
    SELECT patient_id 
    FROM myschema.sick_leaves 
    WHERE status = 'Открыт'
);

SELECT d.last_name, d.first_name, d.specialty
FROM myschema.doctors d
WHERE d.doctor_id NOT IN (
    SELECT doctor_id 
    FROM myschema.schedule 
    WHERE work_date = '2024-04-25'
);

--Перечень специалистов (список врачей по специальностям)
CREATE VIEW myschema.v_doctors_by_specialty AS
SELECT
    specialty AS "Специальность",
    COUNT(doctor_id) AS "Количество врачей",
    STRING_AGG(last_name || ' ' || LEFT(first_name, 1) || '.' || COALESCE(LEFT(patronymic, 1) || '.', ''), ', ' ORDER BY last_name) AS "Фамилии и инициалы"
FROM myschema.doctors
GROUP BY specialty
ORDER BY specialty;
SELECT * FROM myschema.v_doctors_by_specialty;

--Количество визитов к врачам (за всё время)
CREATE VIEW myschema.v_visit_counts AS
SELECT
    d.last_name AS "Фамилия врача",
    d.first_name AS "Имя врача",
    d.specialty AS "Специальность",
    COUNT(v.visit_id) AS "Количество визитов"
FROM myschema.doctors d
JOIN myschema.schedule s ON d.doctor_id = s.doctor_id
JOIN myschema.visits v ON s.schedule_id = v.schedule_id
GROUP BY d.doctor_id, d.last_name, d.first_name, d.specialty
ORDER BY "Количество визитов" DESC;
SELECT * FROM myschema.v_visit_counts;

--Количество случаев заболевания по каждому диагнозу (по коду МКБ)
CREATE VIEW myschema.v_diagnosis_stats AS
SELECT
    dg.mkb_code AS "Код МКБ",
    dg.description AS "Описание диагноза",
    COUNT(DISTINCT dg.diagnosis_id) AS "Количество случаев"
FROM myschema.diagnoses dg
GROUP BY dg.mkb_code, dg.description
ORDER BY "Количество случаев" DESC;
SELECT * FROM myschema.v_diagnosis_stats;
