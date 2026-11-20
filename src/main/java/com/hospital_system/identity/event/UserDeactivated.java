package com.hospital_system.identity.event;

import com.hospital_system.common.events.DomainEvent;

public class UserDeactivated extends DomainEvent {

  private final Integer userId;

  public UserDeactivated(Integer userId) {
    this.userId = userId;
  }

  public Integer getUserId() {
    return userId;
  }
}
