# Development environment configuration
project_id                = "hybrid-dolphin-478706-q8"
region                    = "asia-south1"
environment               = "dev"
image_tag                 = "dev-latest"
min_instances             = 0
max_instances             = 5
db_name                   = "billing_consumer"
db_username               = "billing_consumer_app"
cloud_sql_connection_name = "hybrid-dolphin-478706-q8:asia-south1:lc-billing-app"
allow_public_access       = true

