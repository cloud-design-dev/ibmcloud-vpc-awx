# Deploy an AWX server on IBM Cloud VPC <img src="./images/redhat.svg" width="25" height="25"></a> <img src="./images/plus.svg" width="25" height="25"></a>  <img src="./images/CloudVPC.svg" width="25" height="25">

## Overview

Use this template to provision AWX on Virtual Private Cloud (VPC) Infrastructure in IBM Cloud by using [Terraform][] or IBM Clouds hosted Terraform solution, [Schematics][]. The AWX instance is automatically configured along with security groups so that it can be readily accessible after installation using your virtual server instance's floating IP address.

## Prerequisites

If you are deploying this template via IBM Cloud Schematics, you can skip this section and move on to the [deployment](#deployment) section.

### Local Prerequisites

If you are running this code from your local machine, you will need to ensure you have the following software installed:

- IBM Cloud API Key. See [here][create-api-key] for instructions on how to create one via the Portal.
- Recent version of [Terraform][terraform-install] installed. This guide was tested on `terraform 1.5.3`.
- `(Optional)` - [tfswitch][tfswitch-install] installed. The `tfswitch` utility allows you to run multiple versions of Terraform on the same system. If you do not have a particular version of terraform installed, tfswitch will download the version you select from an interactive menu.

![tfswitch](https://dsc.cloud/quickshare/tfswitch-cloudshell.gif)

## Deployment

The Terraform performs the following deployment Steps

- Provision VPC Infrastructure with one VSI 
- Deploy AWX on the provisioned VSI 

The deployment of AWX on IBM Cloud VPC can be done in two ways

### IBM Cloud Schematics

- [ ] **TODO** - Add Schematics instructions 
- [ ] **TODO** - Add Schematics deploy button

### Local Machine using Terraform CLI

With our local prerequisites installed, we can now deploy the AWX template. The following steps will walk you through the deployment process.

1. Clone this repo and `cd` into the `terraform-ibm-awx` directory.

    ```bash
    git clone https://github.com/greyhoundforty/terraform-ibm-awx.git
    cd terraform-ibm-awx
    ```

1. Copy the `tfvars-example` to `terraform.tfvars` file and update the values as needed. See the [Required Variables](#required-variables) section for .

    ```bash
    cp tfvars-example terraform.tfvars
    ```

1. Initialize Terraform:

    ```bash
    terraform init -upgrade
    ```

1. Run a Terraform plan:

    ```bash
    terraform plan -out default.tfplan 
    ```

1. Run Terraform apply:

    ```bash
    terraform apply default.tfplan
    ```

1. Once the apply completes, you will see the URL for the deployed AWX instance in the Terraform output:

    ```text
    Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

    Outputs:

    awx_access = "Access AWX via browser http://<your-floating-ip>"
    ```

## Required Variables

| Name | Description | Type | 
|------|-------------|------|
| <a name="input_owner"></a> [owner](#input\_owner) | Owner declaration for resource tags. e.g. 'ryantiffany' | `string` |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | Represents a name of the VPC that awx will be deployed into. Resources associated with awx will be prepended with this name. | `string` |
| <a name="input_region"></a> [region](#input\_region) | The region to create your VPC in, such as `us-south`. To get a list of all regions, run `ibmcloud is regions`. | `string` |

## Output

| Name | Description | 
|------|-------------|
| <a name="output_awx_access"></a> [awx\_access](#output\_awx\_access) | The AWX web server address |

## Destroying the deployed Infrastructure and AWX

### On a Standalone machine using Terraform CLI

Using below command the deployed Infrastructure and AWX can be destroyed

  ```shell
  terraform destroy
  ```

### Using IBM Cloud Schematics

Select option Actions in the created workspace and choose Destroy Resources/Destroy workspace.

- [ ] **TODO** - Add Schematics destroy button image/gif

## Additional Resources

https://www.ibm.com/cloud/garage/tutorials/public-cloud-infrastructure

https://github.com/ibm-cloud-architecture/refarch-vsi-on-vpc

https://cloud.ibm.com/docs/tutorials?topic=solution-tutorials-strategies-for-resilient-applications

https://github.com/ansible/awx/blob/devel/INSTALL.md

https://github.com/Crazy450/terraform-aws-awx

https://cloud.ibm.com/docs/vpc-on-classic?topic=vpc-on-classic-about&locale=en

https://github.com/IBM-Cloud/vpc-tutorials

## Costs

When you apply template, the infrastructure resources that you create incur charges as follows. To clean up the resources, you can [delete your Schematics workspace or your instance](https://cloud.ibm.com/docs/schematics?topic=schematics-manage-lifecycle#destroy-resources). Removing the workspace or the instance cannot be undone. Make sure that you back up any data that you must keep before you start the deletion process.

* **VPC**: VPC charges are incurred for the infrastructure resources within the VPC, as well as network traffic for internet data transfer. For more information, see [Pricing for VPC](https://cloud.ibm.com/docs/vpc-on-classic?topic=vpc-on-classic-pricing-for-vpc).
* **VPC virtual servers**: The price for your virtual server instances depends on the flavor of the instances, how many you provision, and how long the instances are run. For more information, see [Pricing for Virtual Servers for VPC](https://cloud.ibm.com/docs/infrastructure/vpc-on-classic?topic=vpc-on-classic-pricing-for-vpc#pricing-for-virtual-servers-for-vpc).



[ansible-install]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible
[terraform-install]: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
[tfswitch-install]: https://tfswitch.warrensbox.com/
[create-api-key]: https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key