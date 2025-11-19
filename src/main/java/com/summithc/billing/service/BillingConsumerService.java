package com.summithc.billing.service;

import com.summithc.billing.crypto.FieldEncryptionService;
import com.summithc.billing.dto.BillingConsumerRequest;
import com.summithc.billing.dto.BillingConsumerResponse;
import com.summithc.billing.entity.BillingConsumer;
import com.summithc.billing.repository.BillingConsumerRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Objects;

@Service
@RequiredArgsConstructor
public class BillingConsumerService {

    private final BillingConsumerRepository repository;
    private final FieldEncryptionService encryptionService;

    @Transactional
    public BillingConsumerResponse createConsumer(BillingConsumerRequest request) {
        BillingConsumer consumer = new BillingConsumer();
        consumer.setUserName(request.getUserName());
        consumer.setAge(request.getAge());
        consumer.setDepartment(request.getDepartment());
        consumer.setInsuranceProvider(request.getInsuranceProvider());
        consumer.setContactEmail(request.getContactEmail());
        consumer.setPassword(encryptionService.encrypt(request.getPassword()));
        consumer.setMedicalHistory(encryptionService.encrypt(request.getMedicalHistory()));
        consumer.setNationalId(encryptionService.encrypt(request.getNationalId()));
        BillingConsumer saved = repository.save(consumer);
        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public BillingConsumerResponse getConsumer(Long id) {
        Objects.requireNonNull(id, "id must not be null");
        BillingConsumer consumer = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("BillingConsumer not found: " + id));
        return toResponse(consumer);
    }

    private BillingConsumerResponse toResponse(BillingConsumer consumer) {
        return BillingConsumerResponse.builder()
                .id(consumer.getId())
                .userName(consumer.getUserName())
                .age(consumer.getAge())
                .department(consumer.getDepartment())
                .insuranceProvider(consumer.getInsuranceProvider())
                .contactEmail(consumer.getContactEmail())
                .encryptedPassword(consumer.getPassword())
                .encryptedMedicalHistory(consumer.getMedicalHistory())
                .encryptedNationalId(consumer.getNationalId())
                .createdAt(consumer.getCreatedAt())
                .build();
    }
}

