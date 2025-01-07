package com.example.satzzdt.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.DynamicUpdate;

@Entity
@Getter
@DynamicUpdate
@Table(name = "users")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User {
    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long serialId;

    @Column(name = "name")
    private String name;

    @Column(name = "nickname")
    private String nickname;

    @Builder
    public User(String name, String nickname) {
        this.name = name;
        this.nickname = nickname;
    }

}
