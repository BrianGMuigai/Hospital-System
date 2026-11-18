package com.hospital_system.common.exception;

import com.hospital_system.common.api.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.List;
import org.hibernate.exception.ConstraintViolationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

  private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

  private final Clock clock;

  public GlobalExceptionHandler(Clock clock) {
    this.clock = clock;
  }

  @ExceptionHandler(AppException.class)
  public ResponseEntity<ErrorResponse> handleApp(AppException ex, HttpServletRequest request) {
    return build(ex.getStatus(), ex.getCode(), ex.getMessage(), request, null);
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<ErrorResponse> handleValidation(
      MethodArgumentNotValidException ex, HttpServletRequest request) {

    List<String> details =
        ex.getBindingResult().getFieldErrors().stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .toList();
    return build(
        HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", "Request validation failed", request, details);
  }

  @ExceptionHandler(DataIntegrityViolationException.class)
  public ResponseEntity<ErrorResponse> handleDataIntegrity(
      DataIntegrityViolationException ex, HttpServletRequest request) {

    String constraint = findConstraintName(ex);
    HttpStatus status = HttpStatus.CONFLICT;
    String code = "DATE_INTEGRITY_VIOLATION";
    String message = "The request conflicts with existing data";

    if (constraint != null) {
      if (constraint.startsWith("uq_") || constraint.endsWith("_key")) {
        code = "DUPLICATE_VALUE";
        message = "A record with the same value already exists";
      } else if (constraint.startsWith("fk_") || constraint.endsWith("_fkey")) {
        code = "REFERENCE_VIOLATION";
        message = "A related record does not exist, or this record is still in use";
      } else if (constraint.startsWith("chk_") || constraint.endsWith("_check")) {
        status = HttpStatus.UNPROCESSABLE_CONTENT;
        code = "RULE_VIOLATION";
        message = "The value breaks a data rule";
      }
    }
    List<String> details = constraint == null ? null : List.of("constraint: " + constraint);
    return build(status, code, message, request, details);
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ErrorResponse> handleUnexpected(Exception ex, HttpServletRequest request) {

    if (ex instanceof org.springframework.web.ErrorResponse springError) {
      HttpStatus status = HttpStatus.valueOf(springError.getStatusCode().value());
      return build(status, status.name(), ex.getMessage(), request, null);
    }
    log.error("Unexpected error on {}", request.getRequestURL(), ex);
    return build(
        HttpStatus.INTERNAL_SERVER_ERROR,
        "INTERNAL_ERROR",
        "An unexpected error occurred",
        request,
        null);
  }

  private String findConstraintName(Throwable ex) {
    Throwable current = ex;
    while (current != null) {
      if (current instanceof ConstraintViolationException violation) {
        String name = violation.getConstraintName();
        return name == null ? null : name.toLowerCase();
      }
      current = current.getCause();
    }
    return null;
  }

  private ResponseEntity<ErrorResponse> build(
      HttpStatus status,
      String code,
      String message,
      HttpServletRequest request,
      List<String> details) {

    ErrorResponse body =
        new ErrorResponse(
            OffsetDateTime.now(clock),
            status.value(),
            code,
            message,
            request.getRequestURI(),
            details);
    return ResponseEntity.status(status).body(body);
  }
}
