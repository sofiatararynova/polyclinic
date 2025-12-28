--Триггер при записи на прием
-- Функция триггера
CREATE OR REPLACE FUNCTION myschema.tg_update_schedule()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT (SELECT is_available FROM myschema.schedule WHERE schedule_id = NEW.schedule_id) THEN
        RAISE EXCEPTION 'Слот уже занят';
    END IF;
    
    UPDATE myschema.schedule SET is_available = FALSE WHERE schedule_id = NEW.schedule_id;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

-- триггер
CREATE TRIGGER tr_visits_after_insert
AFTER INSERT ON myschema.visits
FOR EACH ROW
EXECUTE FUNCTION myschema.tg_update_schedule();

-- какие есть триггеры 
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers 
WHERE event_object_table = 'visits' 
  AND event_object_schema = 'myschema';

--найти свободный слот для проверки
SELECT * FROM myschema.schedule 
WHERE is_available = TRUE 
LIMIT 1;

-- тест: запись в таблицу
INSERT INTO myschema.visits (schedule_id, patient_id, visit_date_time, status)
VALUES (2, 2, '2024-04-25 10:00:00', 'false');


-- Триггер при отмене визита 
-- Функция триггера
CREATE OR REPLACE FUNCTION myschema.tg_free_schedule_on_cancel()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Если визит отменен, освобождаем слот
    IF NEW.status LIKE 'Отменен%' AND OLD.status NOT LIKE 'Отменен%' THEN
        UPDATE myschema.schedule
        SET is_available = TRUE
        WHERE schedule_id = NEW.schedule_id;
    END IF;
    
    RETURN NEW;
END;
$$;

-- триггер
CREATE TRIGGER tr_visits_on_cancel
AFTER UPDATE ON myschema.visits
FOR EACH ROW
EXECUTE FUNCTION myschema.tg_free_schedule_on_cancel();


-- триггер проверки даты больничного, не может быть датой раньше визита.
-- Функция триггера
CREATE OR REPLACE FUNCTION myschema.tg_check_sick_leave_date()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    visit_date DATE;
BEGIN
    -- Берем дату визита
    SELECT visit_date_time::DATE INTO visit_date
    FROM myschema.visits
    WHERE visit_id = NEW.visit_id;
    
    -- Проверяем
    IF NEW.issue_date < visit_date THEN
        RAISE EXCEPTION 'Дата больничного (%) не может быть раньше визита (%)', 
            NEW.issue_date, visit_date;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Сам триггер
CREATE TRIGGER tr_sick_leaves_before_insert
BEFORE INSERT OR UPDATE ON myschema.sick_leaves
FOR EACH ROW
EXECUTE FUNCTION myschema.tg_check_sick_leave_date();

-- проверка 
-- 1. Проверьте свободный слот
SELECT * FROM myschema.schedule WHERE is_available = TRUE LIMIT 1;

-- 2. Создайте визит напрямую (без процедуры)
INSERT INTO myschema.visits (schedule_id, patient_id, visit_date_time, status)
VALUES (2, 1, '2024-05-20 10:00:00', 'Запланирован');

-- 3. Проверьте, что слот стал занятым
SELECT * FROM myschema.schedule WHERE schedule_id = 2;

-- 4. Отмените визит
UPDATE myschema.visits SET status = 'Отменен' WHERE visit_id = 1;

-- 5. Проверьте, что слот освободился
SELECT * FROM myschema.schedule WHERE schedule_id = 1;
