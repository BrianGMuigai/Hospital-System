package com.hospital_system.security;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;

final class SecurityErrorWriter {

  private SecurityErrorWriter() {}

  static void write(
      HttpServletResponse response, HttpStatus status, String code, String message, String path)
      throws IOException {
    response.setStatus(status.value());
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    response.setCharacterEncoding("UTF-8");
    String safePath = path.replace("\\", "\\\\").replace("\"", "\\\"");
    response
        .getWriter()
        .write(
            String.format(
                "{\"timestamp\":\"%s\",\"status\":%d,\"code\":\"%s\",\"message\":\"%s\",\"path\":\"%s\"}",
                Instant.now(), status.value(), code, message, safePath));
  }
}
