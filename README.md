# terraform-aws-mcaf-deploy

MCAF deployment module.

## Documentation
The working of the Use Case deployment is described on [Confluence](https://sbp-heineken.atlassian.net/wiki/spaces/HOME/pages/964723249/Use+Case+development).

# Terraform module usage

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| github | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| subnet\_ids | The subnet ID list used for deployment | `list(string)` | n/a | yes |
| tags | A mapping of tags to assign to the resources | `map(string)` | n/a | yes |
| workload\_environment | The environment this workload is being deployed in | `string` | n/a | yes |
| workload\_name | The workload name | `string` | n/a | yes |
| workload\_repository | Repository full name of the GitHub repository | `string` | n/a | yes |
| workload\_version | The version of the workload to deploy | `string` | n/a | yes |
| buildspec\_functions | Custom buildspec file for deploying functions | `string` | `null` | no |
| buildspec\_gluejobs | Custom buildspec file for deploying gluejobs | `string` | `null` | no |
| environment\_variables | Environment variables for the build and deploy scripts. Valid values for type: PARAMETER\_STORE, PLAINTEXT. | <pre>map(<br>    object({<br>      type  = string<br>      value = string<br>    })<br>  )</pre> | `{}` | no |
| gluejob\_iam\_role\_arn | IAM Role used to deploy Glue Jobs | `string` | `null` | no |
| logging | Logging configuration | <pre>object({<br>    target_bucket = string<br>    target_prefix = string<br>  })</pre> | `null` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->
