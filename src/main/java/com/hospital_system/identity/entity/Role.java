package com.hospital_system.identity.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "Roles")
@AttributeOverride(name = "id", column = @Column(name = "RolesId"))
public class Role extends BaseEntity {

  @Column(name = "RoleName", nullable = false, length = 50)
  private String roleName;

  @Column(name = "Roledescription", length = 255)
  private String roleDescription;

  protected Role() {}

  public Role(String roleName, String roleDescription) {
    this.roleName = roleName;
    this.roleDescription = roleDescription;
  }

  public void update(String roleName, String roleDescription) {
    this.roleName = roleName;
    this.roleDescription = roleDescription;
  }

  public String getRoleName() {
    return roleName;
  }

  public String getRoleDescription() {
    return roleDescription;
  }
}
