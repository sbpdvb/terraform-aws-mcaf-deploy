module "deployment_bucket" {
  source        = "github.com/schubergphilis/terraform-aws-mcaf-s3?ref=v0.5.0"
  name          = local.deployment_bucket
  force_destroy = true
  versioning    = true
  tags          = var.tags
  logging       = var.logging # tfsec:ignore:aws-s3-enable-bucket-logging
}
