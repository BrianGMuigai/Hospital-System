package com.hospital_system.hr.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "Staff")
@AttributeOverride(name = "id", column = @Column(name = "StaffId"))
public class Staff extends BaseEntity {

  @Column(name = "UserId")
  private Integer userId;

  @Column(name = "EmployeeId", nullable = false, length = 30)
  private String employeeId;

  @Column(name = "FirstName", nullable = false, length = 50)
  private String firstName;

  @Column(name = "LastName", nullable = false, length = 50)
  private String lastName;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "EmployeeTypeId", nullable = false)
  private EmployeeType employeeType;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "EmploymentTypeId", nullable = false)
  private EmploymentType employmentType;

  @Column(name = "JobTitle", nullable = false, length = 100)
  private String jobTitle;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "DepartmentId", nullable = false)
  private Department department;

  @Column(name = "HireDate", nullable = false)
  private LocalDate hireDate;

  @Enumerated(EnumType.STRING)
  @Column(name = "Status", nullable = false, length = 20)
  private StaffStatus status;

  @Column(name = "Salary", nullable = false, precision = 12, scale = 2)
  private BigDecimal salary;

  protected Staff() {}

  public Staff(
      String employeeId,
      String firstName,
      String lastName,
      EmployeeType employeeType,
      EmploymentType employmentType,
      String jobTitle,
      Department department,
      LocalDate hireDate,
      BigDecimal salary) {
    this.employeeId = employeeId;
    this.firstName = firstName;
    this.lastName = lastName;
    this.employeeType = employeeType;
    this.employmentType = employmentType;
    this.jobTitle = jobTitle;
    this.department = department;
    this.hireDate = hireDate;
    this.salary = salary;
    this.status = StaffStatus.ACTIVE;
  }

  public Integer getUserId() {
    return userId;
  }

  public String getEmployeeId() {
    return employeeId;
  }

  public String getFirstName() {
    return firstName;
  }

  public String getLastName() {
    return lastName;
  }

  public EmployeeType getEmployeeType() {
    return employeeType;
  }

  public EmploymentType getEmploymentType() {
    return employmentType;
  }

  public String getJobTitle() {
    return jobTitle;
  }

  public Department getDepartment() {
    return department;
  }

  public LocalDate getHireDate() {
    return hireDate;
  }

  public StaffStatus getStatus() {
    return status;
  }

  public BigDecimal getSalary() {
    return salary;
  }

  public void linkUser(Integer userId) {
    this.userId = userId;
  }

  public void updateDetails(
      String firstName,
      String lastName,
      EmployeeType employeeType,
      EmploymentType employmentType,
      String jobTitle,
      Department department,
      BigDecimal salary) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.employeeType = employeeType;
    this.employmentType = employmentType;
    this.jobTitle = jobTitle;
    this.department = department;
    this.salary = salary;
  }

  public void changeStatus(StaffStatus status) {
    this.status = status;
  }
}
