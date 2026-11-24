package com.hospital_system.identity.controller;

import com.hospital_system.common.api.ApiResponse;
import com.hospital_system.common.api.PageResponse;
import com.hospital_system.identity.dto.CreateUserRequest;
import com.hospital_system.identity.dto.UserResponse;
import com.hospital_system.identity.service.UserService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

  private final UserService userService;

  private UserController(UserService userService) {
    this.userService = userService;
  }

  @PostMapping
  public ResponseEntity<ApiResponse<UserResponse>> create(
      @Valid @RequestBody CreateUserRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponse.ok(userService.createUser(request)));
  }

  @GetMapping("/{id}")
  public ApiResponse<UserResponse> get(@PathVariable Integer id) {
    return ApiResponse.ok(userService.getUser(id));
  }

  @GetMapping
  public ApiResponse<PageResponse<UserResponse>> list(
      @PageableDefault(size = 20) Pageable pageable) {
    return ApiResponse.ok(PageResponse.from(userService.listUsers(pageable)));
  }

  @PatchMapping("/{id}/deactivate")
  public ResponseEntity<Void> deactivate(@PathVariable Integer id) {
    userService.deactivateUser(id);
    return ResponseEntity.noContent().build();
  }
}
