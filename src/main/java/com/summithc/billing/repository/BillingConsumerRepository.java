package com.summithc.billing.repository;

import com.summithc.billing.entity.BillingConsumer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BillingConsumerRepository extends JpaRepository<BillingConsumer, Long> {
}

