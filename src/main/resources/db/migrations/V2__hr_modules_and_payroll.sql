-- ============================================================
-- FULL HR MODULE, LICENCES, ATTENDANCE & PAYROLL
-- ============================================================

-- 1. DOCTOR
CREATE TABLE Doctor (
    Doctorid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Staffid INT NOT NULL UNIQUE,
    Speciality VARCHAR(100) NOT NULL,
    ConsultationFee DECIMAL(10, 2) NOT NULL CHECK (ConsultationFee >= 0),

    CONSTRAINT fk_doctor_staff
        FOREIGN KEY (Staffid)
        REFERENCES Staff(StaffId)
        ON DELETE CASCADE
);

-- 2. LICENCES
CREATE TABLE Licences (
    Licenceid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Staffid INT NOT NULL,
    LicenceNumber VARCHAR(50) NOT NULL UNIQUE,
    IssueDate DATE NOT NULL,
    ExpireDate DATE NOT NULL,
    Status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,

    CONSTRAINT fk_licence_staff
        FOREIGN KEY (Staffid)
        REFERENCES Staff(StaffId)
        ON DELETE CASCADE,

    CONSTRAINT chk_licence_dates
        CHECK (ExpireDate > IssueDate),

    CONSTRAINT chk_licence_status
        CHECK (Status IN ('ACTIVE', 'EXPIRED', 'SUSPENDED', 'REVOKED'))
);

-- 3. ATTENDANCE
CREATE TABLE Attendance (
    Attendanceid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Staffid INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    Clockin TIMESTAMPTZ NULL,
    Clockout TIMESTAMPTZ NULL,
    Status VARCHAR(20) NOT NULL,

    CONSTRAINT uq_staff_attendance_date UNIQUE (Staffid, AttendanceDate),

    CONSTRAINT fk_attendance_staff
        FOREIGN KEY (Staffid)
        REFERENCES Staff(StaffId)
        ON DELETE CASCADE,

    CONSTRAINT chk_clock_times
        CHECK (Clockout IS NULL OR Clockout >= Clockin),

    CONSTRAINT chk_attendance_status
        CHECK (Status IN ('PRESENT', 'LATE', 'ABSENT', 'ON_LEAVE'))
);

-- 4. STATUS
CREATE TABLE Status (
    Statusid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StatusName VARCHAR(30) NOT NULL UNIQUE
);

-- 5. LEAVE TYPES
CREATE TABLE LeaveTypes (
    LeaveTypeid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    LeaveName VARCHAR(50) NOT NULL UNIQUE,
    YearlyAllowance INT NOT NULL CHECK (YearlyAllowance >= 0)
);

-- 6. LEAVE REQUESTS
CREATE TABLE LeaveRequest (
    LeaveRequestid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Staffid INT NOT NULL,
    LeaveTypeid INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Statusid INT NOT NULL,
    ApprovedBy INT NULL,

    CONSTRAINT fk_leavereq_staff
        FOREIGN KEY (Staffid)
        REFERENCES Staff(StaffId)
        ON DELETE CASCADE,

    CONSTRAINT fk_leavereq_type
        FOREIGN KEY (LeaveTypeid)
        REFERENCES LeaveTypes(LeaveTypeid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_leavereq_status
        FOREIGN KEY (Statusid)
        REFERENCES Status(Statusid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_leavereq_approver
        FOREIGN KEY (ApprovedBy)
        REFERENCES Staff(StaffId)
        ON DELETE SET NULL,

    CONSTRAINT chk_leave_dates
        CHECK (EndDate >= StartDate)
);

-- 7. PAYROLL RUNS
CREATE TABLE PayRollRun (
    PayRollRunid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PayrollMonth DATE NOT NULL UNIQUE,
    Status VARCHAR(20) DEFAULT 'DRAFT' NOT NULL,
    ProcessDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT chk_payroll_month_first_day
        CHECK (EXTRACT(DAY FROM PayrollMonth) = 1),

    CONSTRAINT chk_payroll_status
        CHECK (Status IN ('DRAFT', 'APPROVED', 'PAID'))
);

-- 8. PAYROLL
CREATE TABLE PayRoll (
    PayRollid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PayRollRunid INT NOT NULL,
    Staffid INT NOT NULL,
    BasicPay DECIMAL(12, 2) NOT NULL CHECK (BasicPay >= 0),
    Allowances DECIMAL(12, 2) DEFAULT 0.00 NOT NULL CHECK (Allowances >= 0),
    Overtime DECIMAL(12, 2) DEFAULT 0.00 NOT NULL CHECK (Overtime >= 0),
    Deductions DECIMAL(12, 2) DEFAULT 0.00 NOT NULL CHECK (Deductions >= 0),
    NetPay DECIMAL(12, 2) NOT NULL CHECK (NetPay >= 0),


    CONSTRAINT uq_run_staff_payslip UNIQUE (PayRollRunid, Staffid),


    CONSTRAINT chk_net_pay_calculation
        CHECK (NetPay = (BasicPay + Allowances + Overtime - Deductions)),

    CONSTRAINT fk_payroll_run
        FOREIGN KEY (PayRollRunid)
        REFERENCES PayRollRun(PayRollRunid)
        ON DELETE CASCADE,

    CONSTRAINT fk_payroll_staff
        FOREIGN KEY (Staffid)
        REFERENCES Staff(StaffId)
        ON DELETE RESTRICT
);

-- INDEXES
CREATE INDEX ix_licences_staff     ON Licences(Staffid);
CREATE INDEX ix_licences_expire    ON Licences(ExpireDate);
CREATE INDEX ix_leavereq_staff     ON LeaveRequest(Staffid, StartDate, EndDate);
CREATE INDEX ix_payroll_staff      ON PayRoll(Staffid);