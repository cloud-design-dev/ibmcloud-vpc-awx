# Generate a random string if a project prefix was not provided
resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  upper   = false
  numeric = false
}

# Generate a new SSH key if one was not provided
resource "tls_private_key" "ssh" {
  count     = var.existing_ssh_key != "" ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Add a new SSH key to the region if one was created
resource "ibm_is_ssh_key" "generated_key" {
  count          = var.existing_ssh_key != "" ? 0 : 1
  name           = "${local.prefix}-${var.region}-key"
  public_key     = tls_private_key.ssh.0.public_key_openssh
  resource_group = module.resource_group.resource_group_id
  tags           = local.tags
}

# Write private key to file if it was generated
resource "null_resource" "create_private_key" {
  count = var.existing_ssh_key != "" ? 0 : 1
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.ssh.0.private_key_pem}' > ./'${local.prefix}'.pem
      chmod 400 ./'${local.prefix}'.pem
    EOT
  }
}

# IF a resource group was not provided, create a new one
module "resource_group" {
  source                       = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  resource_group_name          = var.existing_resource_group == null ? "${local.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group
}

module "vpc" {
  source                      = "terraform-ibm-modules/vpc/ibm//modules/vpc"
  version                     = "1.1.1"
  create_vpc                  = true
  vpc_name                    = "${local.prefix}-vpc"
  resource_group_id           = module.resource_group.resource_group_id
  classic_access              = var.classic_access
  default_address_prefix      = var.default_address_prefix
  default_network_acl_name    = "${local.prefix}-default-network-acl"
  default_security_group_name = "${local.prefix}-default-security-group"
  default_routing_table_name  = "${local.prefix}-default-routing-table"
  vpc_tags                    = local.tags
  locations                   = [local.vpc_zones[0].zone]
  number_of_addresses         = var.number_of_addresses
  create_gateway              = true
  subnet_name                 = "${local.prefix}-subnet"
  public_gateway_name         = "${local.prefix}-pub-gw"
  gateway_tags                = local.tags
}

module "security_group" {
  source                = "terraform-ibm-modules/vpc/ibm//modules/security-group"
  version               = "1.1.1"
  create_security_group = true
  name                  = "${local.prefix}-frontend-sg"
  vpc_id                = module.vpc.vpc_id[0]
  resource_group_id     = module.resource_group.resource_group_id
  security_group_rules  = local.frontend_rules
}

module "awx_instance" {
  source            = "terraform-ibm-modules/vpc/ibm//modules/instance"
  version           = "1.1.1"
  no_of_instances   = 1
  name              = "${local.prefix}-instance"
  vpc_id            = module.vpc.vpc_id[0]
  resource_group_id = module.resource_group.resource_group_id
  location          = local.vpc_zones[0].zone
  image             = data.ibm_is_image.base.id
  profile           = var.profile
  ssh_keys          = local.ssh_key_ids
  primary_network_interface = [
    {
      interface_name       = "eth0"
      subnet               = module.vpc.subnet_ids[0]
      security_groups      = [module.security_group.security_group_id[0]]
      allow_ip_spoofing    = false
      primary_ipv4_address = null
    }
  ]
  user_data = file("${path.module}/awx_install.sh")
  tags      = local.tags
}

resource "ibm_is_floating_ip" "awx_instance" {
  name           = "${local.prefix}-floating-ip"
  target         = module.awx_instance.primary_network_interfaces[0][0]
  resource_group = module.resource_group.resource_group_id
  tags           = local.tags
}

# Resource to execute awx_install.sh script on VSI
# resource "null_resource" "awxinstall" {
#   connection {
#     type        = "ssh"
#     user        = "root"
#     host        = "${module.vpc_pub_priv.floating_ip_address}"
#     private_key = "${tls_private_key.vision_keypair.private_key_pem}"
#   }

#   provisioner "remote-exec" {
#     script = "awx_install.sh"
#   }
# }




