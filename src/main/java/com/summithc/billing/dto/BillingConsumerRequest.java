package com.summithc.billing.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class BillingConsumerRequest {

    @NotBlank(message = "User name is required")
    private String userName;

    @NotBlank(message = "Password is required")
    private String password;

    @NotBlank(message = "Medical history is required")
    private String medicalHistory;

    @NotNull(message = "Age is required")
    @Min(value = 0, message = "Age must be positive")
    private Integer age;

    @NotBlank(message = "Department is required")
    private String department;

    @Email(message = "Contact email must be valid")
    private String contactEmail;

    @NotBlank(message = "Insurance provider is required")
    private String insuranceProvider;

    @NotBlank(message = "National ID is required")
    private String nationalId;
}

