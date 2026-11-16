CREATE UNIQUE INDEX uq_staffroles_active
    ON StaffRoles(StaffId, RolesId) WHERE ValidTo IS NULL;
