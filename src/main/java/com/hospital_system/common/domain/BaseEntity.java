package com.hospital_system.common.domain;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import org.hibernate.Hibernate;

@MappedSuperclass
public abstract class BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  public Integer getId() {
    return id;
  }

  @Override
  public boolean equals(Object other) {
    if (this == other) return true;
    if (other == null || Hibernate.getClass(this) != Hibernate.getClass(other)) return false;
    BaseEntity that = (BaseEntity) other;
    return id != null && id.equals(that.id);
  }

  @Override
  public int hashCode() {
    return Hibernate.getClass(this).hashCode();
  }
}
