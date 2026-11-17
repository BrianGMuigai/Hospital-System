package com.hospital_system.common.time;

import java.time.Clock;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ClockBean {

  @Bean
  public Clock clock() {
    return Clock.systemUTC();
  }
}
