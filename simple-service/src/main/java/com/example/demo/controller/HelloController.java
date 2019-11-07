package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;

@RestController
public class HelloController {

  @GetMapping("/hello")
  public String hello(@RequestParam(defaultValue = "World") String name) {
    return String.format("Hello %s!", name);
  }
}
