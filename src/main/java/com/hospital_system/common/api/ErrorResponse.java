package com.hospital_system.common.api;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.OffsetDateTime;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ErrorResponse(
    OffsetDateTime timesamp,
    int status,
    String code,
    String message,
    String path,
    List<String> details) {}
