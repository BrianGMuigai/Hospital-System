package com.hospital_system.hr.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "EmploymentTypes")
@AttributeOverride(name = "id", column = @Column(name = "EmploymentTypeId"))
public class EmploymentType extends BaseEntity {

  @Column(name = "TypeName", nullable = false, length = 30)
  private String typeName;

  protected EmploymentType() {}

  public EmploymentType(String typeName) {
    this.typeName = typeName;
  }

  public String getTypeName() {
    return typeName;
  }
}
