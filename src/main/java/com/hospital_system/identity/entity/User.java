package com.hospital_system.identity.entity;

import com.hospital_system.common.domain.BaseEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

@Entity
@Table(name = "Users")
@AttributeOverride(name = "id", column = @Column(name = "UserId"))
public class User extends BaseEntity {

  @Column(name = "UserName", nullable = false, length = 50)
  private String userName;

  @Column(name = "UserEmail", nullable = false, length = 100)
  private String userEmail;

  @Column(name = "PasswordHash", nullable = false, length = 255)
  private String passwordHash;

  @Column(name = "IsActive", nullable = false)
  private boolean active;

  @Column(name = "CreatedAt", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  protected User() {}

  public User(String userName, String userEmail, String passwordHash, OffsetDateTime createdAt) {
    this.userName = userName;
    this.userEmail = userEmail;
    this.passwordHash = passwordHash;
    this.active = true;
    this.createdAt = createdAt;
  }

  public String getUserName() {
    return userName;
  }

  public String getUserEmail() {
    return userEmail;
  }

  public String getPasswordHash() {
    return passwordHash;
  }

  public boolean isActive() {
    return active;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }
}
