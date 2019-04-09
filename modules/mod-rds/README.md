# mod-rds

## Passwords and secrets

The module takes two parameters, `rds_master_password` and `secret_name`. Both are optional.

* If `rds_master_password` is given, the given password will be used to instantiate the cluster. If it is an empty string (default behavior), a random password will be generated.
* *This is currently not implemented in the module because of Terraform's brokenness.* If `secret_name` is given, the details of the RDS cluster will be written as a JSON object into the AWS Secrets Manager entry with the given name. If it is an empty value, nothing will be written into the Secrets Manager. The creation of the AWS Secret Manager entry must be managed elsewhere, e.g. outside of the module invocation.
