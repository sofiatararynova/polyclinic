CREATE TABLE myschema.doctors (
    doctor_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    patronymic VARCHAR(100),
    specialty VARCHAR(200) NOT NULL,
    experience INTEGER NOT NULL,
    birth_date DATE NOT NULL,
    address TEXT NOT NULL
);

CREATE TABLE myschema.role_doctor (
	doctor_id INTEGER NOT NULL UNIQUE REFERENCES myschema.doctors(doctor_id) ON DELETE RESTRICT,
	login VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    user_type VARCHAR(20) DEFAULT 'doctor'
);

CREATE TABLE myschema.administrators (
    admin_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    patronymic VARCHAR(100),
    birth_date DATE NOT NULL,
    address TEXT NOT NULL
    );

CREATE TABLE myschema.role_administrator (
    admin_id INTEGER NOT NULL UNIQUE REFERENCES myschema.administrators(admin_id) ON DELETE RESTRICT,
    login VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    user_type VARCHAR(20) DEFAULT 'admin'
);
	
CREATE TABLE myschema.patients (
    patient_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    patronymic VARCHAR(100),
    birth_date DATE NOT NULL,
    address TEXT NOT NULL,
    CONSTRAINT chk_patient_birth_date CHECK (birth_date <= CURRENT_DATE)
);

CREATE TABLE myschema.schedule (
    schedule_id SERIAL PRIMARY KEY,
    doctor_id INTEGER NOT NULL REFERENCES myschema.doctors(doctor_id) ON DELETE RESTRICT,
    admin_id INTEGER NOT NULL REFERENCES myschema.administrators(admin_id) ON DELETE RESTRICT,
    work_date DATE NOT NULL,
    time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE myschema.visits (
    visit_id SERIAL PRIMARY KEY,
    schedule_id INTEGER NOT NULL REFERENCES myschema.schedule(schedule_id) ON DELETE RESTRICT,
    patient_id INTEGER NOT NULL REFERENCES myschema.patients(patient_id) ON DELETE RESTRICT,
    visit_date_time TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    CONSTRAINT unique_visit_datetime UNIQUE (patient_id, visit_date_time)
);

CREATE TABLE myschema.sick_leaves (
    sick_leave_id SERIAL PRIMARY KEY,
    issue_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
	content TEXT NOT NULL,
    patient_id INTEGER NOT NULL REFERENCES myschema.patients(patient_id) ON DELETE RESTRICT,
	visit_id INTEGER NOT NULL REFERENCES myschema.visits(visit_id) ON DELETE RESTRICT
);

CREATE TABLE myschema.diagnoses (
    diagnosis_id SERIAL PRIMARY KEY,
	sick_leave_id INTEGER REFERENCES myschema.sick_leaves(sick_leave_id) ON DELETE RESTRICT,
    mkb_code VARCHAR(20) NOT NULL,
    description TEXT NOT NULL
);
