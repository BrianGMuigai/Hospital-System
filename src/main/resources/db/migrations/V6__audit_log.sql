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

