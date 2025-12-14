CREATE OR REPLACE FUNCTION myschema.fn_doctor_patients_report(
    p_doctor_id INTEGER,
    p_date_from DATE,
    p_date_to DATE
)
RETURNS TABLE (
    "Фамилия пациента" VARCHAR(100),
    "Имя пациента" VARCHAR(100),
    "Отчество пациента" VARCHAR(100),
    "Дата рождения" DATE,
    "Дата и время визита" TIMESTAMP,
    "Код диагноза" VARCHAR(20),
    "Диагноз" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.last_name,
        p.first_name,
        p.patronymic,
        p.birth_date,
        v.visit_date_time,
        COALESCE(dg.mkb_code, 'Нет диагноза'),
        COALESCE(dg.description, 'Диагноз не поставлен')
    FROM myschema.visits v
    JOIN myschema.schedule sc ON v.schedule_id = sc.schedule_id
    JOIN myschema.patients p ON v.patient_id = p.patient_id
    LEFT JOIN myschema.sick_leaves sl ON v.visit_id = sl.visit_id
    LEFT JOIN myschema.diagnoses dg ON sl.sick_leave_id = dg.sick_leave_id
    WHERE sc.doctor_id = p_doctor_id
      AND v.visit_date_time::DATE BETWEEN p_date_from AND p_date_to
    ORDER BY v.visit_date_time;
END;
$$;

SELECT * FROM myschema.fn_doctor_patients_report(1, '2024-04-25', '2024-04-25');