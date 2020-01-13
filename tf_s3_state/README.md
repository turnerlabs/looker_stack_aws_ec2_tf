# Description

This is a [terraform](https://www.terraform.io/) script to create the s3 terraform state bucket.

**You will need to update the terraform / backend / bucket in the main.tf in tf_existing_network to use this terraform state bucket to save your stacks state.**

```bash
terraform init
```

```bash
terraform apply
```
