package com.hospital_system.identity.repository;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.hospital_system.identity.entity.User;
import java.time.OffsetDateTime;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@Transactional
class UserRepositoryTest {

  @Autowired private UserRepository userRepository;

  @Test
  void rejectsADuplicateUserName() {
    userRepository.saveAndFlush(new User("ann", "ann@hospital.test", "hash", OffsetDateTime.now()));

    assertThatThrownBy(() ->
            userRepository.saveAndFlush(
                new User("ann", "other@hospital.test", "hash", OffsetDateTime.now())))
        .isInstanceOf(DataIntegrityViolationException.class);
  }
}
