-- ============================================================
-- IDENTITY, ACCESS CONTROL & ROSTER SCHEMA
-- ============================================================

-- 1. USERS
CREATE TABLE Users (
    UserId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL UNIQUE,
    UserEmail VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    CreatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 2. DEPARTMENTS
CREATE TABLE Departments (
    DepartmentId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE,
    HeadOfDepartment INT NULL
);

-- 2b. EMPLOYEE TYPES
CREATE TABLE EmployeeTypes (
    EmployeeTypeId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL UNIQUE
);

-- 2c. EMPLOYMENT TYPES
CREATE TABLE EmploymentTypes (
    EmploymentTypeId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TypeName VARCHAR(30) NOT NULL UNIQUE
);

-- 3. STAFF
CREATE TABLE Staff (
    StaffId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserId INT NULL UNIQUE,
    EmployeeId VARCHAR(30) NOT NULL UNIQUE,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    EmployeeTypeId INT NOT NULL,
    EmploymentTypeId INT NOT NULL,
    JobTitle VARCHAR(100) NOT NULL,
    DepartmentId INT NOT NULL,
    HireDate DATE NOT NULL,
    Status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    Salary DECIMAL(12, 2) NOT NULL CHECK (Salary >= 0),

    CONSTRAINT fk_staff_user
        FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE SET NULL,
    CONSTRAINT fk_staff_department
        FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId) ON DELETE RESTRICT,
    CONSTRAINT chk_staff_status
        CHECK (Status IN ('ACTIVE', 'INACTIVE', 'TERMINATED', 'SUSPENDED')),
    CONSTRAINT fk_staff_employeetype
        FOREIGN KEY (EmployeeTypeId) REFERENCES EmployeeTypes(EmployeeTypeId) ON DELETE RESTRICT,
    CONSTRAINT fk_staff_employmenttype
        FOREIGN KEY (EmploymentTypeId) REFERENCES EmploymentTypes(EmploymentTypeId) ON DELETE RESTRICT
);

ALTER TABLE Departments
    ADD CONSTRAINT fk_dept_head
    FOREIGN KEY (HeadOfDepartment) REFERENCES Staff(StaffId) ON DELETE SET NULL;

-- 4. ROLES
CREATE TABLE Roles (
    RolesId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL UNIQUE,
    Roledescription VARCHAR(255) NULL
);

-- 5. STAFF ROLES
CREATE TABLE StaffRoles (
    UserRolesId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StaffId INT NOT NULL,
    RolesId INT NOT NULL,
    Departmentid INT NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE NULL,
    AssignedBy INT NULL,

    CONSTRAINT fk_staffroles_staff
        FOREIGN KEY (StaffId) REFERENCES Staff(StaffId) ON DELETE CASCADE,
    CONSTRAINT fk_staffroles_role
        FOREIGN KEY (RolesId) REFERENCES Roles(RolesId) ON DELETE RESTRICT,
    CONSTRAINT fk_staffroles_dept
        FOREIGN KEY (Departmentid) REFERENCES Departments(DepartmentId) ON DELETE RESTRICT,
    CONSTRAINT fk_staffroles_assignedby
        FOREIGN KEY (AssignedBy) REFERENCES Staff(StaffId) ON DELETE SET NULL,
    CONSTRAINT chk_staffroles_dates
        CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom)
);

-- 6. PERMISSIONS
CREATE TABLE Permissions (
    Permissionid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PermissionCode VARCHAR(50) NOT NULL UNIQUE,
    PermissionDescription VARCHAR(255) NULL
);

-- 7. ROLES PERMISSION
CREATE TABLE RolesPermission (
    RolePermissionsid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Rolesid INT NOT NULL,
    Permissionsid INT NOT NULL,

    CONSTRAINT uq_role_permission UNIQUE (Rolesid, Permissionsid),
    CONSTRAINT fk_roleperm_role
        FOREIGN KEY (Rolesid) REFERENCES Roles(RolesId) ON DELETE CASCADE,
    CONSTRAINT fk_roleperm_perm
        FOREIGN KEY (Permissionsid) REFERENCES Permissions(Permissionid) ON DELETE CASCADE
);

-- 8. SHIFTS
CREATE TABLE Shifts (
    Shiftid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
     ShiftName VARCHAR(50) NOT NULL UNIQUE,  -- Morning, Afternoon, Night
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    CONSTRAINT chk_shift_times CHECK (EndTime <> StartTime)
);

-- 9. STAFF ROSTER
CREATE TABLE StaffRoster (
    Rosterid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Staffid INT NOT NULL,
    Departmentid INT NOT NULL,
    Shiftid INT NOT NULL,
    RosterDate DATE NOT NULL,
    IsOnCall BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT uq_staff_shift_date UNIQUE (Staffid, Shiftid, Date),
    CONSTRAINT fk_roster_staff
        FOREIGN KEY (Staffid) REFERENCES Staff(StaffId) ON DELETE CASCADE,
    CONSTRAINT fk_roster_dept
        FOREIGN KEY (Departmentid) REFERENCES Departments(DepartmentId) ON DELETE RESTRICT,
    CONSTRAINT fk_roster_shift
        FOREIGN KEY (Shiftid) REFERENCES Shifts(Shiftid) ON DELETE RESTRICT
);

-- INDEXES
CREATE INDEX ix_staff_department  ON Staff(DepartmentId);
CREATE INDEX ix_staff_employeetype ON Staff(EmployeeTypeId);
CREATE INDEX ix_staff_employmenttype ON Staff(EmploymentTypeId);
CREATE INDEX ix_staffroles_staff  ON StaffRoles(StaffId);
CREATE INDEX ix_roster_dept_date  ON StaffRoster(Departmentid, Date);

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


-- ============================================================
-- PHARMACY & LABORATORY MODULE SCHEMA
-- ============================================================

-- 1. DRUG
CREATE TABLE Drug (
    Drugid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    SKU VARCHAR(50) NOT NULL UNIQUE,
    DrugName VARCHAR(100) NOT NULL,
    UnitOfMeasure VARCHAR(30) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    ReorderLevel INT NOT NULL CHECK (ReorderLevel >= 0)
);

-- 2. DRUG STOCK
CREATE TABLE DrugStock (
    Drugstockid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Drugid INT NOT NULL,
    BatchNumber VARCHAR(50) NOT NULL,
    QuantityInStock INT NOT NULL CHECK (QuantityInStock >= 0),
    ExpiryDate DATE NOT NULL,
    ReceivedDate DATE DEFAULT CURRENT_DATE NOT NULL,

    CONSTRAINT uq_drugstock_batch UNIQUE (Drugid, BatchNumber),

    -- RESTRICT
    CONSTRAINT fk_drugstock_drug
        FOREIGN KEY (Drugid)
        REFERENCES Drug(Drugid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_expiry_date
        CHECK (ExpiryDate > ReceivedDate)
);

-- 3. PRESCRIPTION STATUS
CREATE TABLE PrescriptionStatus (
    Prescriptionstatusid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StatusName VARCHAR(30) NOT NULL UNIQUE
);

-- 4. PRESCRIPTION
CREATE TABLE Prescription (
    Prescriptionid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Patientid INT NOT NULL,
    Doctorid INT NOT NULL,
    Prescriptionstatusid INT NOT NULL,
    PrescriptionDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT fk_prescription_patient
        FOREIGN KEY (Patientid)
        REFERENCES Patient(Patientid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_prescription_doctor
        FOREIGN KEY (Doctorid)
        REFERENCES Doctor(Doctorid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_prescription_status
        FOREIGN KEY (Prescriptionstatusid)
        REFERENCES PrescriptionStatus(Prescriptionstatusid)
        ON DELETE RESTRICT
);

-- 5. PRESCRIPTION ITEM
CREATE TABLE PrescriptionItem (
    Prescriptionitemid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Prescriptionid INT NOT NULL,
    Drugid INT NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    Frequency VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Duration VARCHAR(50) NOT NULL,


    CONSTRAINT uq_prescitem_drug UNIQUE (Prescriptionid, Drugid),

    CONSTRAINT fk_prescitem_prescription
        FOREIGN KEY (Prescriptionid)
        REFERENCES Prescription(Prescriptionid)
        ON DELETE CASCADE,

    CONSTRAINT fk_prescitem_drug
        FOREIGN KEY (Drugid)
        REFERENCES Drug(Drugid)
        ON DELETE RESTRICT
);

-- 6. LAB TEST CATALOG
CREATE TABLE LabTest (
    LabTestid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TestCode VARCHAR(30) NOT NULL UNIQUE,
    TestName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0)
);

-- 7. LAB ORDERS
CREATE TABLE LabOrders (
    LabOrdersid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Patientid INT NOT NULL,
    Doctorid INT NOT NULL,
    Appointmentid INT NOT NULL,
    LabTestid INT NOT NULL,
    OrderDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Status VARCHAR(20) DEFAULT 'ORDERED' NOT NULL,

    CONSTRAINT fk_laborder_patient
        FOREIGN KEY (Patientid)
        REFERENCES Patient(Patientid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_laborder_doctor
        FOREIGN KEY (Doctorid)
        REFERENCES Doctor(Doctorid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_laborder_appt
        FOREIGN KEY (Appointmentid)
        REFERENCES Appointment(Appointmentid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_laborder_test
        FOREIGN KEY (LabTestid)
        REFERENCES LabTest(LabTestid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_laborder_status
        CHECK (Status IN ('ORDERED', 'SAMPLE_COLLECTED', 'COMPLETED', 'CANCELLED'))
);

-- 8. LAB RESULTS
CREATE TABLE LabResult (
    LabResultid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    LabOrdersid INT NOT NULL UNIQUE,
    Technicianid INT NOT NULL,
    ResultValue TEXT NOT NULL,
    ReferenceRange VARCHAR(100) NULL,
    ResultDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,

    -- RESTRICT
    CONSTRAINT fk_labres_order
        FOREIGN KEY (LabOrdersid)
        REFERENCES LabOrders(LabOrdersid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_labres_staff
        FOREIGN KEY (Technicianid)
        REFERENCES Staff(StaffId)
        ON DELETE RESTRICT
);

-- INDEXES
CREATE INDEX ix_drugstock_expiry    ON DrugStock(Drugid, ExpiryDate);
CREATE INDEX ix_prescription_patient ON Prescription(Patientid);
CREATE INDEX ix_prescription_doctor  ON Prescription(Doctorid);
CREATE INDEX ix_prescitem_drug       ON PrescriptionItem(Drugid);
CREATE INDEX ix_laborders_patient    ON LabOrders(Patientid);
CREATE INDEX ix_laborders_appt       ON LabOrders(Appointmentid);
CREATE INDEX ix_laborders_test       ON LabOrders(LabTestid);
CREATE INDEX ix_labresult_tech       ON LabResult(Technicianid);


-- ============================================================
-- PART 5: FINANCE & BILLING MODULE SCHEMA
-- ============================================================

-- 1. SERVICE
CREATE TABLE Service (
    ServiceCatalogid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ServiceName VARCHAR(100) NOT NULL UNIQUE,
    Category VARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0)
);

-- 2. INSURANCE PROVIDERS
CREATE TABLE InsuranceProviders (
    InsuranceProviderid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProviderName VARCHAR(100) NOT NULL UNIQUE,
    ContactPhone VARCHAR(20) NOT NULL,
    ContactEmail VARCHAR(100) NULL,
    Status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,

    CONSTRAINT chk_insprov_status
        CHECK (Status IN ('ACTIVE', 'INACTIVE'))
);

-- 3. PATIENT INSURANCE
CREATE TABLE PatientInsurance (
    Patientinsuranceid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Patientid INT NOT NULL,
    InsuranceProviderid INT NOT NULL,
    PolicyNumber VARCHAR(50) NOT NULL,
    CoveragePercentage DECIMAL(5, 2) NOT NULL CHECK (CoveragePercentage BETWEEN 0 AND 100),
    ValidUntil DATE NOT NULL,


    CONSTRAINT uq_patins_policy UNIQUE (InsuranceProviderid, PolicyNumber),

    CONSTRAINT fk_patins_patient
        FOREIGN KEY (Patientid)
        REFERENCES Patient(Patientid)
        ON DELETE CASCADE,

    CONSTRAINT fk_patins_provider
        FOREIGN KEY (InsuranceProviderid)
        REFERENCES InsuranceProviders(InsuranceProviderid)
        ON DELETE RESTRICT
);


ALTER TABLE Patient
    ADD CONSTRAINT fk_patient_insurance
    FOREIGN KEY (Insuranceid)
    REFERENCES PatientInsurance(Patientinsuranceid)
    ON DELETE SET NULL;

-- 4. INVOICES
CREATE TABLE Invoices (
    Invoiceid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Patientid INT NOT NULL,
    InvoiceDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    TotalAmount DECIMAL(12, 2) NOT NULL CHECK (TotalAmount >= 0),
    DiscountAmount DECIMAL(12, 2) DEFAULT 0.00 NOT NULL CHECK (DiscountAmount >= 0),
    TaxAmount DECIMAL(12, 2) DEFAULT 0.00 NOT NULL CHECK (TaxAmount >= 0),
    NetAmount DECIMAL(12, 2) NOT NULL CHECK (NetAmount >= 0),
    Statusid INT NOT NULL,

    CONSTRAINT fk_invoice_patient
        FOREIGN KEY (Patientid)
        REFERENCES Patient(Patientid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_invoice_status
        FOREIGN KEY (Statusid)
        REFERENCES Status(Statusid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_invoice_discount
        CHECK (DiscountAmount <= TotalAmount),

    -- Net = Total - Discount + Tax
    CONSTRAINT chk_invoice_net
        CHECK (NetAmount = TotalAmount - DiscountAmount + TaxAmount)
);

-- 5. INVOICE ITEMS
CREATE TABLE InvoiceItem (
    Invoiceitemid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Invoiceid INT NOT NULL,
    Serviceid INT NULL,
    Drugid INT NULL,
    LabTestid INT NULL,
    Description VARCHAR(255) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    Subtotal DECIMAL(12, 2) NOT NULL CHECK (Subtotal >= 0),

    CONSTRAINT fk_invitem_invoice
        FOREIGN KEY (Invoiceid)
        REFERENCES Invoices(Invoiceid)
        ON DELETE CASCADE,

    -- RESTRICT
    CONSTRAINT fk_invitem_service
        FOREIGN KEY (Serviceid)
        REFERENCES ServiceCatalog(ServiceCatalogid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_invitem_drug
        FOREIGN KEY (Drugid)
        REFERENCES Drug(Drugid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_invitem_labtest
        FOREIGN KEY (LabTestid)
        REFERENCES LabTest(LabTestid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_invitem_one_link
        CHECK (num_nonnulls(Serviceid, Drugid, LabTestid) <= 1),

    CONSTRAINT chk_invitem_subtotal
        CHECK (Subtotal = Quantity * UnitPrice)
);

-- 6. PAYMENT METHOD
CREATE TABLE PaymentMethod (
    PaymentMethodid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    MethodName VARCHAR(50) NOT NULL UNIQUE
);

-- 7. PAYMENTS
CREATE TABLE Payment (
    Paymentid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Invoiceid INT NOT NULL,
    PaymentDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    AmountPaid DECIMAL(12, 2) NOT NULL CHECK (AmountPaid > 0),
    PaymentMethodid INT NOT NULL,
    TransactionReference VARCHAR(100) NULL UNIQUE,

    CONSTRAINT fk_payment_invoice
        FOREIGN KEY (Invoiceid)
        REFERENCES Invoices(Invoiceid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_payment_method
        FOREIGN KEY (PaymentMethodid)
        REFERENCES PaymentMethod(PaymentMethodid)
        ON DELETE RESTRICT
);

-- 8. REFUNDS
CREATE TABLE Refunds (
    Refundid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Paymentid INT NOT NULL,
    RefundDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Amount DECIMAL(12, 2) NOT NULL CHECK (Amount > 0),
    Reason TEXT NOT NULL,
    ApprovedBy INT NOT NULL,

    CONSTRAINT fk_refund_payment
        FOREIGN KEY (Paymentid)
        REFERENCES Payment(Paymentid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_refund_staff
        FOREIGN KEY (ApprovedBy)
        REFERENCES Staff(StaffId)
        ON DELETE RESTRICT
);

-- 9. INSURANCE CLAIMS
CREATE TABLE InsuranceClaim (
    InsuranceClaimid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Invoiceid INT NOT NULL,
    Patientinsuranceid INT NOT NULL,
    ClaimAmount DECIMAL(12, 2) NOT NULL CHECK (ClaimAmount >= 0),
    ClaimDate DATE DEFAULT CURRENT_DATE NOT NULL,
    Status VARCHAR(20) DEFAULT 'SUBMITTED' NOT NULL,

    CONSTRAINT fk_claim_invoice
        FOREIGN KEY (Invoiceid)
        REFERENCES Invoices(Invoiceid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_claim_patins
        FOREIGN KEY (Patientinsuranceid)
        REFERENCES PatientInsurance(Patientinsuranceid)
        ON DELETE RESTRICT,

    CONSTRAINT chk_claim_status
        CHECK (Status IN ('SUBMITTED', 'APPROVED', 'REJECTED', 'PAID'))
);

-- 10. EXPENSE CATEGORIES
CREATE TABLE ExpenseCategories (
    ExpenseCategoryid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

-- 11. EXPENSES
CREATE TABLE Expenses (
    Expenseid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ExpenseCategoryid INT NOT NULL,
    Amount DECIMAL(12, 2) NOT NULL CHECK (Amount >= 0),
    ExpenseDate DATE DEFAULT CURRENT_DATE NOT NULL,
    Description VARCHAR(255) NOT NULL,
    PaidTo VARCHAR(100) NOT NULL,
    ApprovedBy INT NOT NULL,

    CONSTRAINT fk_expense_cat
        FOREIGN KEY (ExpenseCategoryid)
        REFERENCES ExpenseCategories(ExpenseCategoryid)
        ON DELETE RESTRICT,

    CONSTRAINT fk_expense_staff
        FOREIGN KEY (ApprovedBy)
        REFERENCES Staff(StaffId)
        ON DELETE RESTRICT
);

-- INDEXES
CREATE INDEX ix_patins_patient     ON PatientInsurance(Patientid);
CREATE INDEX ix_patient_insurance  ON Patient(Insuranceid);
CREATE INDEX ix_invoices_patient   ON Invoices(Patientid);
CREATE INDEX ix_invitem_invoice    ON InvoiceItem(Invoiceid);
CREATE INDEX ix_payment_invoice    ON Payment(Invoiceid);
CREATE INDEX ix_refunds_payment    ON Refunds(Paymentid);
CREATE INDEX ix_claim_invoice      ON InsuranceClaim(Invoiceid);
CREATE INDEX ix_claim_patins       ON InsuranceClaim(Patientinsuranceid);
CREATE INDEX ix_expenses_cat_date  ON Expenses(ExpenseCategoryid, ExpenseDate);

-- ============================================================
-- SYSTEM AUDIT & LOGGING MODULE
-- ============================================================

-- 1. AUDIT LOG
CREATE TABLE AuditLog (
    AuditLogId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StaffId INT NULL,
    ActionType VARCHAR(50) NOT NULL,
    TableName VARCHAR(50) NOT NULL,
    RecordId INT NOT NULL,
    OldValues JSONB NULL,
    NewValues JSONB NULL,
    PerformedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT fk_auditlog_staff
        FOREIGN KEY (StaffId)
        REFERENCES Staff(StaffId)
        ON DELETE RESTRICT,

    CONSTRAINT chk_audit_action_type
        CHECK (ActionType IN ('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'APPROVE')),

    CONSTRAINT chk_audit_values
        CHECK (
            (ActionType <> 'INSERT' OR OldValues IS NULL) AND
            (ActionType <> 'DELETE' OR NewValues IS NULL)
        )
);

CREATE INDEX ix_auditlog_record ON AuditLog(TableName, RecordId);
CREATE INDEX ix_auditlog_staff  ON AuditLog(StaffId);
CREATE INDEX ix_auditlog_time   ON AuditLog(PerformedAt);

CREATE FUNCTION fn_auditlog_append_only() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'AuditLog is append-only: % is not allowed', TG_OP;
END;
$$;

CREATE TRIGGER trg_auditlog_no_change
    BEFORE UPDATE OR DELETE ON AuditLog
    FOR EACH ROW EXECUTE FUNCTION fn_auditlog_append_only();

CREATE TRIGGER trg_auditlog_no_truncate
    BEFORE TRUNCATE ON AuditLog
    FOR EACH STATEMENT EXECUTE FUNCTION fn_auditlog_append_only();
