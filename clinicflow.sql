-- ============================================================
-- ClinicFlow — Script de base de données PostgreSQL
-- Gestion Patients & Rendez-vous
-- ============================================================
-- Ce script contient :
--   1. Extensions
--   2. Types ENUM
--   3. Tables (users, patients, appointments, audit_log)
--   4. Index
--   5. Trigger : règle métier "pas 2 RDV confirmés à moins de 30 min"
--   6. Trigger updated_at
--   7. Seed data (1 admin, 2 staff, 5 patients, 10 rendez-vous)
-- ============================================================

-- ------------------------------------------------------------
-- 1) EXTENSIONS
-- ------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- pour gen_random_uuid()

-- ------------------------------------------------------------
-- 2) TYPES ENUM
-- ------------------------------------------------------------
DROP TYPE IF EXISTS user_role CASCADE;
CREATE TYPE user_role AS ENUM ('admin', 'staff');

DROP TYPE IF EXISTS appointment_status CASCADE;
CREATE TYPE appointment_status AS ENUM ('pending', 'confirmed', 'cancelled');

-- ------------------------------------------------------------
-- 3) TABLES
-- ------------------------------------------------------------

-- ===== USERS =====
CREATE TABLE IF NOT EXISTS users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name     VARCHAR(150) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role          user_role NOT NULL DEFAULT 'staff',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at    TIMESTAMPTZ NULL          -- bonus : soft delete
);

-- ===== PATIENTS =====
CREATE TABLE IF NOT EXISTS patients (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name    VARCHAR(150) NOT NULL,
    cin          VARCHAR(30)  NOT NULL UNIQUE,
    phone        VARCHAR(20)  NOT NULL,
    birth_date   DATE NOT NULL,
    address      TEXT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at   TIMESTAMPTZ NULL           -- bonus : soft delete
);

-- ===== APPOINTMENTS =====
CREATE TABLE IF NOT EXISTS appointments (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id        UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    appointment_date  TIMESTAMPTZ NOT NULL,
    status            appointment_status NOT NULL DEFAULT 'pending',
    reason            VARCHAR(255) NOT NULL,
    notes             TEXT NULL,
    created_by        UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ===== AUDIT LOG (bonus) =====
CREATE TABLE IF NOT EXISTS audit_log (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name   VARCHAR(50) NOT NULL,
    record_id    UUID NOT NULL,
    action       VARCHAR(20) NOT NULL,      -- INSERT / UPDATE / DELETE
    performed_by UUID NULL REFERENCES users(id) ON DELETE SET NULL,
    old_data     JSONB NULL,
    new_data     JSONB NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- 4) INDEX (recherche & performance)
-- ------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_patients_full_name ON patients (full_name);
CREATE INDEX IF NOT EXISTS idx_patients_cin       ON patients (cin);

CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON appointments (patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date       ON appointments (appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status     ON appointments (status);

-- ------------------------------------------------------------
-- 5) TRIGGER — Règle métier :
--    Un patient ne peut pas avoir 2 rendez-vous CONFIRMÉS
--    dans une fenêtre de 30 minutes.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_no_double_confirmed_appointment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'confirmed' THEN
        IF EXISTS (
            SELECT 1
            FROM appointments a
            WHERE a.patient_id = NEW.patient_id
              AND a.status = 'confirmed'
              AND a.id <> COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000')
              AND ABS(EXTRACT(EPOCH FROM (a.appointment_date - NEW.appointment_date))) < 1800
        ) THEN
            RAISE EXCEPTION 'Ce patient a déjà un rendez-vous confirmé à moins de 30 minutes de celui-ci.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_double_confirmed ON appointments;
CREATE TRIGGER trg_check_double_confirmed
BEFORE INSERT OR UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION check_no_double_confirmed_appointment();

-- ------------------------------------------------------------
-- 6) TRIGGER — updated_at automatique
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_patients_updated_at ON patients;
CREATE TRIGGER trg_patients_updated_at
BEFORE UPDATE ON patients
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_appointments_updated_at ON appointments;
CREATE TRIGGER trg_appointments_updated_at
BEFORE UPDATE ON appointments
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- 7) SEED DATA
-- ============================================================
-- NB: mots de passe hashés en bcrypt pour "password123"
-- hash généré avec bcrypt (10 rounds) — à adapter/régénérer côté backend
-- Exemple de hash valide bcrypt pour "password123" :
--   $2b$10$vBDcRdb/.q86tY/tNB3OCehTrt7bjRF34YeHoTJuwL4Xb0GfgQib.

INSERT INTO users (id, full_name, email, password_hash, role) VALUES
('11111111-1111-1111-1111-111111111111', 'Amine Admin',   'admin@clinicflow.ma', '$2b$10$vBDcRdb/.q86tY/tNB3OCehTrt7bjRF34YeHoTJuwL4Xb0GfgQib.', 'admin'),
('22222222-2222-2222-2222-222222222222', 'Sara Staff',    'sara.staff@clinicflow.ma',  '$2b$10$vBDcRdb/.q86tY/tNB3OCehTrt7bjRF34YeHoTJuwL4Xb0GfgQib.', 'staff'),
('33333333-3333-3333-3333-333333333333', 'Youssef Staff', 'youssef.staff@clinicflow.ma', '$2b$10$vBDcRdb/.q86tY/tNB3OCehTrt7bjRF34YeHoTJuwL4Xb0GfgQib.', 'staff');

INSERT INTO patients (id, full_name, cin, phone, birth_date, address) VALUES
('a1111111-0000-0000-0000-000000000001', 'Fatima Zahra Idrissi', 'BE123456', '0612345678', '1990-05-14', 'Casablanca'),
('a1111111-0000-0000-0000-000000000002', 'Mohamed Alami',        'BK654321', '0623456789', '1985-11-02', 'Rabat'),
('a1111111-0000-0000-0000-000000000003', 'Khadija Bennani',      'BJ112233', '0634567890', '1978-03-22', NULL),
('a1111111-0000-0000-0000-000000000004', 'Omar Tazi',            'BH445566', '0645678901', '2001-07-09', 'Marrakech'),
('a1111111-0000-0000-0000-000000000005', 'Nadia Chraibi',        'BF778899', '0656789012', '1995-12-30', 'Tanger');

-- 10 rendez-vous (mix pending / confirmed / cancelled)
INSERT INTO appointments (patient_id, appointment_date, status, reason, notes, created_by) VALUES
('a1111111-0000-0000-0000-000000000001', now() + interval '1 day 9 hours',  'confirmed', 'Consultation générale', NULL, '22222222-2222-2222-2222-222222222222'),
('a1111111-0000-0000-0000-000000000001', now() + interval '10 days',       'pending',   'Suivi tension artérielle', NULL, '22222222-2222-2222-2222-222222222222'),
('a1111111-0000-0000-0000-000000000002', now() + interval '2 days 14 hours','confirmed', 'Contrôle post-opératoire', 'Apporter les analyses', '33333333-3333-3333-3333-333333333333'),
('a1111111-0000-0000-0000-000000000002', now() - interval '5 days',        'cancelled', 'Vaccination', 'Patient absent', '33333333-3333-3333-3333-333333333333'),
('a1111111-0000-0000-0000-000000000003', now() + interval '3 days',        'pending',   'Consultation dermatologie', NULL, '22222222-2222-2222-2222-222222222222'),
('a1111111-0000-0000-0000-000000000003', now() + interval '15 days',       'confirmed', 'Bilan annuel', NULL, '11111111-1111-1111-1111-111111111111'),
('a1111111-0000-0000-0000-000000000004', now() + interval '1 day 11 hours','pending',   'Douleurs abdominales', NULL, '33333333-3333-3333-3333-333333333333'),
('a1111111-0000-0000-0000-000000000004', now() - interval '2 days',        'cancelled', 'Consultation ORL', NULL, '22222222-2222-2222-2222-222222222222'),
('a1111111-0000-0000-0000-000000000005', now() + interval '4 days',        'confirmed', 'Suivi grossesse', 'Échographie prévue', '22222222-2222-2222-2222-222222222222'),
('a1111111-0000-0000-0000-000000000005', now() + interval '20 days',       'pending',   'Consultation nutrition', NULL, '11111111-1111-1111-1111-111111111111');

-- ============================================================
-- FIN DU SCRIPT
-- ============================================================