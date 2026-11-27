package com.hospital_system.hr.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "Departments")
@AttributeOverride(name = "id", column = @Column(name = "DepartmentId"))
public class Department extends BaseEntity {

  @Column(name = "DepartmentName", nullable = false, length = 100)
  private String departmentName;

  @Column(name = "headOfDepartment")
  private Integer headOfDepartment;

  protected Department() {}

  public Department(String departmentName) {
    this.departmentName = departmentName;
  }

  public String getDepartmentName() {
    return departmentName;
  }

  public Integer getHeadOfDepartment() {
    return headOfDepartment;
  }

  public void rename(String departmentName) {
    this.departmentName = departmentName;
  }

  public void assignHead(Integer staffId) {
    this.headOfDepartment = staffId;
  }
}
