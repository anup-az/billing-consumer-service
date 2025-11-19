package com.summithc.billing.controller;

import com.summithc.billing.dto.BillingConsumerRequest;
import com.summithc.billing.dto.BillingConsumerResponse;
import com.summithc.billing.service.BillingConsumerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/billing-consumers")
@RequiredArgsConstructor
public class BillingConsumerController {

    private final BillingConsumerService service;

    @PostMapping
    public ResponseEntity<BillingConsumerResponse> create(@Valid @RequestBody BillingConsumerRequest request) {
        BillingConsumerResponse response = service.createConsumer(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<BillingConsumerResponse> getById(@PathVariable Long id) {
        BillingConsumerResponse response = service.getConsumer(id);
        return ResponseEntity.ok(response);
    }
}

