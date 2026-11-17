package com.hospital_system.common.exception;

import org.springframework.http.HttpStatus;

public class BusinessRuleException extends AppException {
  public BusinessRuleException(String message) {
    super(HttpStatus.UNPROCESSABLE_CONTENT, "BUSINESS_RULE_VIOLATION", message);
  }
}
