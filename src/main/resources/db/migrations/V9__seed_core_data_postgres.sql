-- ============================================================
-- V9: seed data needed to log in and to use the system
-- ===========================================================
-- ------------------------------------------------------------
-- 1. LOOKUP VALUES
-- ------------------------------------------------------------
INSERT INTO EmployeeTypes (TypeName) VALUES
    ('Doctor'),
    ('Nurse'),
    ('Administrator'),
    ('Pharmacist'),
    ('Lab Technician'),
    ('Receptionist'),
    ('Accountant')
ON CONFLICT DO NOTHING;

INSERT INTO EmploymentTypes (TypeName) VALUES
    ('Full-time'),
    ('Part-time'),
    ('Contract'),
    ('Intern')
ON CONFLICT DO NOTHING;

INSERT INTO Departments (DepartmentName) VALUES
    ('Administration'),
    ('Outpatient'),
    ('Inpatient'),
    ('Pharmacy'),
    ('Laboratory'),
    ('Finance')
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 2. ROLES
-- ------------------------------------------------------------
INSERT INTO Roles (RoleName, Roledescription) VALUES
    ('ADMIN',        'Full access to the system'),
    ('DOCTOR',       'Diagnoses and treats patients'),
    ('NURSE',        'Cares for patients and records vitals'),
    ('RECEPTIONIST', 'Registers patients and books appointments'),
    ('PHARMACIST',   'Dispenses prescriptions and manages drug stock'),
    ('LAB_TECH',     'Processes lab orders and records results'),
    ('ACCOUNTANT',   'Handles invoices and payments')
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3. PERMISSIONS (identity module; later slices add their own)
-- ------------------------------------------------------------
INSERT INTO Permissions (PermissionCode, PermissionDescription) VALUES
    ('USER_READ',       'View users'),
    ('USER_WRITE',      'Create and deactivate users'),
    ('ROLE_READ',       'View roles and role assignments'),
    ('ROLE_WRITE',      'Create roles, change role permissions, assign roles'),
    ('PERMISSION_READ', 'View the list of permissions')
ON CONFLICT DO NOTHING;

-- ADMIN gets every permission that exists
INSERT INTO RolesPermission (RolesId, PermissionsId)
SELECT r.RolesId, p.Permissionid
FROM Roles r
CROSS JOIN Permissions p
WHERE r.RoleName = 'ADMIN'
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 4. DEMO ADMIN ACCOUNT
-- ------------------------------------------------------------
INSERT INTO Users (UserName, UserEmail, PasswordHash)
VALUES ('admin', 'admin@hospital.local',
        '$2a$10$9kJyFKOXQbFWyoI/gH.lg.P7z4ViEUYGJI3yp0AWDQnl3xe3uPDNK')
ON CONFLICT DO NOTHING;

INSERT INTO Staff (UserId, EmployeeId, FirstName, LastName, EmployeeTypeId,
                   EmploymentTypeId, JobTitle, DepartmentId, HireDate, Salary)
SELECT u.UserId, 'EMP-0001', 'System', 'Administrator', et.EmployeeTypeId,
       emt.EmploymentTypeId, 'System Administrator', d.DepartmentId, CURRENT_DATE, 0
FROM Users u
CROSS JOIN EmployeeTypes et
CROSS JOIN EmploymentTypes emt
CROSS JOIN Departments d
WHERE u.UserName = 'admin'
  AND et.TypeName = 'Administrator'
  AND emt.TypeName = 'Full-time'
  AND d.DepartmentName = 'Administration'
ON CONFLICT DO NOTHING;

INSERT INTO StaffRoles (StaffId, RolesId, DepartmentId, ValidFrom)
SELECT s.StaffId, r.RolesId, s.DepartmentId, CURRENT_DATE
FROM Staff s
JOIN Users u ON u.UserId = s.UserId
CROSS JOIN Roles r
WHERE u.UserName = 'admin'
  AND r.RoleName = 'ADMIN'
  AND NOT EXISTS (
      SELECT 1 FROM StaffRoles sr
      WHERE sr.StaffId = s.StaffId
        AND sr.RolesId = r.RolesId
        AND sr.ValidTo IS NULL);
