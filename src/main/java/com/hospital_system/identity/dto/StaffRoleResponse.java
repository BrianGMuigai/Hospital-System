package com.hospital_system.identity.dto;

import com.hospital_system.identity.entity.StaffRole;
import java.time.LocalDate;

public record StaffRoleResponse(
    Integer staffRoleId,
    Integer staffId,
    Integer roleId,
    String roleName,
    Integer departmentId,
    LocalDate validFrom,
    LocalDate validTo,
    Integer assignedBy) {

  public static StaffRoleResponse from(StaffRole sr) {
    return new StaffRoleResponse(
        sr.getId(),
        sr.getStaffId(),
        sr.getRole().getId(),
        sr.getRole().getRoleName(),
        sr.getDepartmentId(),
        sr.getValidFrom(),
        sr.getValidTo(),
        sr.getAssignedBy());
  }
}
