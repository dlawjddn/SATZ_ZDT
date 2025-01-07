package com.example.satzzdt.service;

import com.example.satzzdt.domain.User;
import com.example.satzzdt.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    @Transactional
    public void saveUser() {
        for (int i = 0; i < 100; i++) {
            userRepository.save(
                    User.builder()
                            .name("임정우" + String.valueOf(i))
                            .nickname("dlawjddn " + String.valueOf(i))
                            .build()
            );
        }
    }

    public List<String> getAllUsername() {
        return userRepository.findAllUsername();
    }

    public List<String> getAllUserNickname() {
        return userRepository.findAllUserNickname();
    }

}
