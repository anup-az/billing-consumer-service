package com.summithc.billing.dto;

import lombok.Builder;
import lombok.Value;

import java.time.OffsetDateTime;

@Value
@Builder
public class BillingConsumerResponse {
    Long id;
    String userName;
    Integer age;
    String department;
    String insuranceProvider;
    String contactEmail;
    String encryptedPassword;
    String encryptedMedicalHistory;
    String encryptedNationalId;
    OffsetDateTime createdAt;
}

