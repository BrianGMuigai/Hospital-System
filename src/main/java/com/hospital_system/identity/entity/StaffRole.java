package com.hospital_system.identity.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;

@Entity
@Table(name = "StaffRoles")
@AttributeOverride(name = "id", column = @Column(name = "UserRolesId"))
public class StaffRole extends BaseEntity {

  @Column(name = "StaffId", nullable = false)
  private Integer staffId;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "RolesId", nullable = false)
  private Role role;

  @Column(name = "Departmentid", nullable = false)
  private Integer departmentId;

  @Column(name = "ValidFrom", nullable = false)
  private LocalDate validFrom;

  @Column(name = "ValidTo")
  private LocalDate validTo;

  @Column(name = "AssignedBy")
  private Integer assignedBy;

  protected StaffRole() {}

  public StaffRole(
      Integer staffId,
      Role role,
      Integer departmentId,
      LocalDate validFrom,
      LocalDate validTo,
      Integer assignedBy) {
    this.staffId = staffId;
    this.role = role;
    this.departmentId = departmentId;
    this.validFrom = validFrom;
    this.validTo = validTo;
    this.assignedBy = assignedBy;
  }

  public boolean isActiveOn(LocalDate date) {
    return !date.isBefore(validFrom) && (validTo == null || !date.isAfter(validTo));
  }

  public Integer getStaffId() {
    return staffId;
  }

  public Role getRole() {
    return role;
  }

  public Integer getDepartmentId() {
    return departmentId;
  }

  public LocalDate getValidFrom() {
    return validFrom;
  }

  public LocalDate getValidTo() {
    return validTo;
  }

  public Integer getAssignedBy() {
    return assignedBy;
  }
}
