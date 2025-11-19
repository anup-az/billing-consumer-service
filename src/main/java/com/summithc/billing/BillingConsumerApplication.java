package com.summithc.billing;

import com.summithc.billing.config.EncryptionProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(EncryptionProperties.class)
public class BillingConsumerApplication {

    public static void main(String[] args) {
        SpringApplication.run(BillingConsumerApplication.class, args);
    }
}

