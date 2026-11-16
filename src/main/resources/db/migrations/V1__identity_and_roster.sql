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

    CONSTRAINT uq_staff_shift_date UNIQUE (Staffid, Shiftid, RosterDate),
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
CREATE INDEX ix_roster_dept_date  ON StaffRoster(Departmentid, RosterDate);
