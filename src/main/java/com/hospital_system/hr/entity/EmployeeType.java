package com.hospital_system.hr.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "EmployeeTypes")
@AttributeOverride(name = "id", column = @Column(name = "EmployeeTypeId"))
public class EmployeeType extends BaseEntity {

  @Column(name = "TypeName", nullable = false, length = 50)
  private String typeName;

  protected EmployeeType() {}

  public EmployeeType(String typeName) {
    this.typeName = typeName;
  }

  public String getTypeName() {
    return typeName;
  }
}
