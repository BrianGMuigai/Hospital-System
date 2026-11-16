-- ============================================================
-- OUTPATIENT & INPATIENT MODULE SCHEMA
-- ============================================================

-- 1. PATIENT
CREATE TABLE Patient (
    Patientid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    MRN VARCHAR(30) NOT NULL UNIQUE,
    FullName VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender VARCHAR(15) NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE,
    EmergencyContact VARCHAR(50) NOT NULL,
    Nationalid VARCHAR(30) NOT NULL UNIQUE,
    Insuranceid INT NULL,

    CONSTRAINT chk_patient_gender
        CHECK (Gender IN ('MALE', 'FEMALE', 'OTHER')),

    CONSTRAINT chk_patient_dob
        CHECK (DOB <= CURRENT_DATE)
);

-- 2. DOCTOR SCHEDULE
CREATE TABLE DoctorSchedule (
    Doctorscheduleid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Doctorid INT NOT NULL,
    ScheduleDay VARCHAR(15) NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    Status VARCHAR(20) DEFAULT 'AVAILABLE' NOT NULL,

    CONSTRAINT uq_docsch_slot UNIQUE (Doctorid, ScheduleDay, StartTime),

    CONSTRAINT fk_docsch_doctor
        FOREIGN KEY (Doctorid)
        REFERENCES Doctor(Doctorid)
        ON DELETE CASCADE,

    CONSTRAINT chk_docsch_times
        CHECK (EndTime > StartTime),

    CONSTRAINT chk_docsch_day
        CHECK (ScheduleDay IN ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY')),

    CONSTRAINT chk_docsch_status
        CHECK (Status IN ('AVAILABLE', 'UNAVAILABLE', 'ON_LEAVE'))
);

-- 3. APPOINTMENT STATUS
CREATE TABLE AppointmentStatus (
    Appointmentstatusid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StatusName VARCHAR(30) NOT NULL UNIQUE
);

-- 4. APPOINTMENT
CREATE TABLE Appointment (
    Appointmentid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Patientid INT NOT NULL,
    Doctorid INT NOT NULL,
    Appointmentstatusid INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,

    CONSTRAINT fk_appt_patient
        FOREIGN KEY (Patientid)
        REFERENCES Patient(Patientid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_appt_doctor
        FOREIGN KEY (Doctorid)
        REFERENCES Doctor(Doctorid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_appt_status
        FOREIGN KEY (Appointmentstatusid)
        REFERENCES AppointmentStatus(Appointmentstatusid)
        ON DELETE RESTRICT
);

-- 5. VISIT NOTE
CREATE TABLE VisitNote (
    Visitnoteid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Patientid INT NOT NULL,
    Doctorid INT NOT NULL,
    Appointmentid INT NOT NULL UNIQUE, -- 1-to-1 with Appointment
    Visitdate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ChiefComplaint TEXT NOT NULL,
    AppointmentTime TIME NOT NULL,
    Symptoms TEXT NOT NULL,
    Diagnosis TEXT NOT NULL,
    TreatmentPlan TEXT NULL,

    CONSTRAINT fk_visitnote_patient
        FOREIGN KEY (Patientid)
        REFERENCES Patient(Patientid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_visitnote_doctor
        FOREIGN KEY (Doctorid)
        REFERENCES Doctor(Doctorid)
        ON DELETE RESTRICT,


    CONSTRAINT fk_visitnote_appt
        FOREIGN KEY (Appointmentid)
        REFERENCES Appointment(Appointmentid)
        ON DELETE RESTRICT
);

-- 6. REMINDER TYPE
CREATE TABLE ReminderType (
    Remindertypeid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TypeName VARCHAR(30) NOT NULL UNIQUE
);

-- 7. REMINDERS
CREATE TABLE Reminders (
    Reminderid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Appointmentid INT NOT NULL,
    Patientid INT NOT NULL,
    Remindertypeid INT NOT NULL,
    ScheduleTime TIMESTAMPTZ NOT NULL,
    SentTime TIMESTAMPTZ NULL,
    Status VARCHAR(20) DEFAULT 'PENDING' NOT NULL,

    CONSTRAINT fk_reminder_appt
        FOREIGN KEY (Appointmentid)
        REFERENCES Appointment(Appointmentid)
        ON DELETE CASCADE,

    CONSTRAINT fk_reminder_patient
        FOREIGN KEY (Patientid)
        REFERENCES Patient(Patientid)
        ON DELETE CASCADE,

    CONSTRAINT fk_reminder_type
        FOREIGN KEY (Remindertypeid)
        REFERENCES ReminderType(Remindertypeid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_reminder_status
        CHECK (Status IN ('PENDING', 'SENT', 'FAILED', 'CANCELLED'))
);

-- 8. WARD STATUS
CREATE TABLE WardStatus (
    Wardstatusid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StatusName VARCHAR(30) NOT NULL UNIQUE
);

-- 9. WARD
CREATE TABLE Ward (
    Wardid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Wardstatusid INT NOT NULL,
    Departmentid INT NOT NULL,
    WardName VARCHAR(100) NOT NULL UNIQUE,
    Capacity INT NOT NULL CHECK (Capacity > 0),

    CONSTRAINT fk_ward_status
        FOREIGN KEY (Wardstatusid)
        REFERENCES WardStatus(Wardstatusid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_ward_dept
        FOREIGN KEY (Departmentid)
        REFERENCES Departments(DepartmentId)
        ON DELETE RESTRICT
);

-- 10. BED STATUS
CREATE TABLE BedStatus (
    Bedstatusid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StatusName VARCHAR(30) NOT NULL UNIQUE
);

-- 11. BED
CREATE TABLE Bed (
    Bedid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Wardid INT NOT NULL,
    Bedstatusid INT NOT NULL,
    BedNumber VARCHAR(20) NOT NULL,

    CONSTRAINT uq_ward_bed_num UNIQUE (Wardid, BedNumber),

    CONSTRAINT fk_bed_ward
        FOREIGN KEY (Wardid)
        REFERENCES Ward(Wardid)
        ON DELETE CASCADE,

    CONSTRAINT fk_bed_status
        FOREIGN KEY (Bedstatusid)
        REFERENCES BedStatus(Bedstatusid)
        ON DELETE RESTRICT
);

-- 12. ADMISSION
CREATE TABLE Admission (
    Admissionid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Patientid INT NOT NULL,
    Bedid INT NOT NULL,
    AdmittingDoctorid INT NOT NULL,
    AdmissionDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    DischargeDate TIMESTAMPTZ NULL,
    Status VARCHAR(20) DEFAULT 'ADMITTED' NOT NULL,

    CONSTRAINT fk_admission_patient
        FOREIGN KEY (Patientid)
        REFERENCES Patient(Patientid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_admission_bed
        FOREIGN KEY (Bedid)
        REFERENCES Bed(Bedid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_admission_doctor
        FOREIGN KEY (AdmittingDoctorid)
        REFERENCES Doctor(Doctorid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_admission_dates
        CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate),

    CONSTRAINT chk_admission_status
        CHECK (Status IN ('ADMITTED', 'DISCHARGED', 'TRANSFERRED'))
);

CREATE UNIQUE INDEX uq_admission_active_bed
    ON Admission(Bedid) WHERE DischargeDate IS NULL;
CREATE UNIQUE INDEX uq_admission_active_patient
    ON Admission(Patientid) WHERE DischargeDate IS NULL;

-- INDEXES
CREATE INDEX ix_appt_patient      ON Appointment(Patientid);
CREATE INDEX ix_appt_doctor_date  ON Appointment(Doctorid, AppointmentDate);
CREATE INDEX ix_visitnote_patient ON VisitNote(Patientid);
CREATE INDEX ix_visitnote_doctor  ON VisitNote(Doctorid);
CREATE INDEX ix_reminders_appt    ON Reminders(Appointmentid);
CREATE INDEX ix_ward_dept         ON Ward(Departmentid);
CREATE INDEX ix_admission_patient ON Admission(Patientid);