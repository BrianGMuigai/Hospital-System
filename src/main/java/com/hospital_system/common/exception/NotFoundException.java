package com.hospital_system.common.exception;

import org.springframework.http.HttpStatus;

public class NotFoundException extends AppException {

  public NotFoundException(String entity, Object id) {
    super(HttpStatus.NOT_FOUND, "NOT_FOUND", entity + " with id " + " was not found");
  }
}
