package com.example.rendertest;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RenderTestController {
    @GetMapping
    public String hello() {
        return "Hello World";
    }
}
