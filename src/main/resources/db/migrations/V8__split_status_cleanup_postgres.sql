-- ============================================================
-- V8: split the shared Status table, drop two weak indexes,
-- ============================================================

-- ------------------------------------------------------------
-- 1. LEAVE STATUS
-- ------------------------------------------------------------
CREATE TABLE LeaveStatus (
    Leavestatusid INT GENERATED ALWAYS AS IDENTITY,
    StatusName    VARCHAR(30) NOT NULL,

    CONSTRAINT pk_leavestatus PRIMARY KEY (Leavestatusid),
    CONSTRAINT uq_leavestatus_name UNIQUE (StatusName)
);


INSERT INTO LeaveStatus (StatusName)
SELECT DISTINCT s.StatusName
FROM Status s
JOIN LeaveRequest lr ON lr.Statusid = s.Statusid;

ALTER TABLE LeaveRequest ADD COLUMN Leavestatusid INT;

UPDATE LeaveRequest lr
SET Leavestatusid = ls.Leavestatusid
FROM Status s
JOIN LeaveStatus ls ON ls.StatusName = s.StatusName
WHERE s.Statusid = lr.Statusid;

ALTER TABLE LeaveRequest ALTER COLUMN Leavestatusid SET NOT NULL;

ALTER TABLE LeaveRequest
    ADD CONSTRAINT fk_leavereq_leavestatus
    FOREIGN KEY (Leavestatusid) REFERENCES LeaveStatus(Leavestatusid) ON DELETE RESTRICT;

ALTER TABLE LeaveRequest DROP CONSTRAINT fk_leavereq_status;
ALTER TABLE LeaveRequest DROP COLUMN Statusid;

-- ------------------------------------------------------------
-- 2. INVOICE STATUS
-- ------------------------------------------------------------
CREATE TABLE InvoiceStatus (
    Invoicestatusid INT GENERATED ALWAYS AS IDENTITY,
    StatusName      VARCHAR(30) NOT NULL,

    CONSTRAINT pk_invoicestatus PRIMARY KEY (Invoicestatusid),
    CONSTRAINT uq_invoicestatus_name UNIQUE (StatusName)
);

INSERT INTO InvoiceStatus (StatusName)
SELECT DISTINCT s.StatusName
FROM Status s
JOIN Invoices i ON i.Statusid = s.Statusid;

ALTER TABLE Invoices ADD COLUMN Invoicestatusid INT;

UPDATE Invoices i
SET Invoicestatusid = ist.Invoicestatusid
FROM Status s
JOIN InvoiceStatus ist ON ist.StatusName = s.StatusName
WHERE s.Statusid = i.Statusid;

ALTER TABLE Invoices ALTER COLUMN Invoicestatusid SET NOT NULL;

ALTER TABLE Invoices
    ADD CONSTRAINT fk_invoice_invoicestatus
    FOREIGN KEY (Invoicestatusid) REFERENCES InvoiceStatus(Invoicestatusid) ON DELETE RESTRICT;

ALTER TABLE Invoices DROP CONSTRAINT fk_invoice_status;
ALTER TABLE Invoices DROP COLUMN Statusid;

-- ------------------------------------------------------------
-- 3. Nothing references the shared Status table any more
-- ------------------------------------------------------------
DROP TABLE Status;

-- ------------------------------------------------------------
-- 4. Drop two indexes that are not worth
-- ------------------------------------------------------------
DROP INDEX IF EXISTS ix_staff_employeetype;
DROP INDEX IF EXISTS ix_staff_employmenttype;

