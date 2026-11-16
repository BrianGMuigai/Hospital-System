-- ============================================================
--  FINANCE & BILLING MODULE SCHEMA
-- ============================================================

-- 1. SERVICE CATALOG
CREATE TABLE Service (
    Serviceid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
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
        REFERENCES Service(Serviceid)
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
