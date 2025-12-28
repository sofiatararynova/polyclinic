CREATE OR REPLACE PROCEDURE myschema.book_appointment(
    p_patient_id INTEGER,
    p_doctor_id INTEGER,
    p_desired_date DATE,
    p_desired_time TIME
) AS $$
DECLARE v_schedule_id INTEGER;
BEGIN
    SELECT schedule_id INTO v_schedule_id
    FROM myschema.schedule
    WHERE doctor_id = p_doctor_id
      AND work_date = p_desired_date
      AND time = p_desired_time
      AND is_available = TRUE
    LIMIT 1;

    IF v_schedule_id IS NULL THEN
        RAISE EXCEPTION 'Свободный слот не найден';
    END IF;

    INSERT INTO myschema.visits (schedule_id, patient_id, visit_date_time, status)
    VALUES (v_schedule_id, p_patient_id, (p_desired_date + p_desired_time)::TIMESTAMP, 'Запланирован');
END; $$ LANGUAGE plpgsql;


--найти свободный слот 
SELECT s.*, d.last_name AS врач
FROM myschema.schedule s
JOIN myschema.doctors d ON s.doctor_id = d.doctor_id
WHERE s.is_available = TRUE
ORDER BY s.work_date, s.time;

CALL myschema.book_appointment(3, 1, '2024-04-25', '09:00:00');
