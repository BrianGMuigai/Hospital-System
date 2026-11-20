package com.hospital_system.identity.event;

import com.hospital_system.common.events.DomainEvent;

public class RoleAssigned extends DomainEvent {

  private final Integer staffId;
  private final Integer roleId;
  private final Integer assignedBy;

  public RoleAssigned(Integer staffId, Integer roleId, Integer assignedBy) {
    this.staffId = staffId;
    this.roleId = roleId;
    this.assignedBy = assignedBy;
  }

  public Integer getStaffId() {
    return staffId;
  }

  public Integer getRoleId() {
    return roleId;
  }

  public Integer getassigneBy() {
    return assignedBy;
  }
}
