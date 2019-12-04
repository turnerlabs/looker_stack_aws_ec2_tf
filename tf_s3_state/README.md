# Description

This is a terraform script to create the s3 terraform state bucket.

You will need to update the terraform / backend / bucket in the main.tf in tf_existing_network to use this terraform state bucket.

```bash
terraform init
```

```bash
terraform apply
```