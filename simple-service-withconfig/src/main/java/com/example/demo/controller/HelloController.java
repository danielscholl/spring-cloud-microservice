package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

  @Value("${application.name:World}")
  private String name;

  @GetMapping("/hello")
  public String hello() {
    return String.format("Hello %s!", name);
  }
}
