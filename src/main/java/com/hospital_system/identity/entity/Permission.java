package com.hospital_system.identity.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "Permissions")
@AttributeOverride(name = "id", column = @Column(name = "Permissionid"))
public class Permission extends BaseEntity {

  @Column(name = "PermissionCode", nullable = false, length = 50)
  private String permissionCode;

  @Column(name = "PermissionDescription", length = 255)
  private String permissionDescription;

  protected Permission() {}

  public Permission(String permissionCode, String permissionDescription) {
    this.permissionCode = permissionCode;
    this.permissionDescription = permissionDescription;
  }

  public String getPermissionCode() {
    return permissionCode;
  }

  public String getPermissionDescription() {
    return permissionDescription;
  }
}
