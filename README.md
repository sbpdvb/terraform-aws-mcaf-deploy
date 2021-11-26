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
| opco | The operational company | `string` | n/a | yes |
| site\_code | The site code | `string` | n/a | yes |
| subnet\_ids | The subnet ID list used for deployment | `list(string)` | n/a | yes |
| tags | A mapping of tags to assign to the resources | `map(string)` | n/a | yes |
| usecase\_code | The usecase code | `string` | n/a | yes |
| usecase\_version | The version of the usecase to deploy | `string` | n/a | yes |
| alert\_notifiers | Notifiers of the codebuild failure alerts | `list(string)` | <pre>[<br>  "@mon-heineken@schubergphilis.com",<br>  "@opsgenie-heineken"<br>]</pre> | no |
| buildspec\_docker | Custom buildspec file for deploying docker | `string` | `null` | no |
| buildspec\_frontend | Custom buildspec file for deploying frontend | `string` | `null` | no |
| buildspec\_functions | Custom buildspec file for deploying functions | `string` | `null` | no |
| buildspec\_migrations | Custom buildspec file for deploying database migrations | `string` | `null` | no |
| buildspec\_streams | Custom buildspec file for deploying streams | `string` | `null` | no |
| environment\_variables | Environment variables for the build and deploy scripts. Valid values for type: PARAMETER\_STORE, PLAINTEXT. | <pre>map(<br>    object({<br>      type  = string<br>      value = string<br>    })<br>  )</pre> | `{}` | no |
| restore\_kinesis\_state | Option to restore the Kinesis Analytics state | `bool` | `true` | no |
| usecase\_repository | Optional repository name if the GitHub repository has a non-default name | `string` | `null` | no |
| usecase\_repository\_owner | The GitHub repository owner of the usecase to be deployed | `string` | `"connectedbrewery"` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->
