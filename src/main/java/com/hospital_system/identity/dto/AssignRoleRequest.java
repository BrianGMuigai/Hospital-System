package com.hospital_system.identity.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record AssignRoleRequest(
    @NotNull Integer staffId,
    @NotNull Integer roleId,
    @NotNull Integer departmentId,
    @NotNull LocalDate validFrom,
    LocalDate validTo) {}
