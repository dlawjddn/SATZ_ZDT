package com.example.satzzdt.controller;

import com.example.satzzdt.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping
    public void saveUser() {
        userService.saveUser();
    }

    @GetMapping("/name")
    public List<String> getAllUserName() {
        return userService.getAllUsername();
    }

    @GetMapping("/nickname")
    public List<String> getAllUserNickname() {
        return userService.getAllUserNickname();
    }
}
