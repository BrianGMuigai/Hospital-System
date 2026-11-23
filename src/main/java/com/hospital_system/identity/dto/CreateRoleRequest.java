package com.hospital_system.identity.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateRoleRequest(
    @NotBlank @Size(max = 50) String roleName, @Size(max = 255) String roleDescription) {}
