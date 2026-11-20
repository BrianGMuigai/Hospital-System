package com.hospital_system.identity.event;

import com.hospital_system.common.events.DomainEvent;

public class UserCreated extends DomainEvent {

  private final Integer userId;
  private final String userName;

  public UserCreated(Integer userId, String userName) {
    this.userId = userId;
    this.userName = userName;
  }

  public Integer getUserId() {
    return userId;
  }

  public String getUserName() {
    return userName;
  }
}
