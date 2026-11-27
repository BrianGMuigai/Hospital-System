package com.hospital_system.identity.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "RolesPermission")
@AttributeOverride(name = "id", column = @Column(name = "RolePermissionsid"))
public class RolePermission extends BaseEntity {

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "Rolesid", nullable = false)
  private Role role;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "Permissionsid", nullable = false)
  private Permission permission;

  protected RolePermission() {}

  public RolePermission(Role role, Permission permission) {
    this.role = role;
    this.permission = permission;
  }

  public Role getRole() {
    return role;
  }

  public Permission getPermission() {
    return permission;
  }
}
