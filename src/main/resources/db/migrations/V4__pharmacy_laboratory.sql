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
