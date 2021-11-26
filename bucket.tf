module "deployment_bucket" {
  source        = "github.com/schubergphilis/terraform-aws-mcaf-s3?ref=v0.2.0"
  name          = local.deployment_bucket
  force_destroy = true
  versioning    = true
  tags          = var.tags
  logging       = var.logging
}
